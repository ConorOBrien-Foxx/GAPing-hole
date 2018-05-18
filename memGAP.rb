require 'digest'

def all_ascii
    Enumerator.new { |g|
        c = [32]
        size = 1
        loop {
            ind = c.size - 1
            g << c.map(&:chr).join
            c[ind] += 1
            while c[ind] > 126
                c[ind] = 32
                if ind == 0
                    size += 1
                    c = [32] * size
                    break
                end
                ind -= 1
                c[ind] += 1
            end
        }
    }
end

MD5 = Digest::MD5.new
def md5(text)
    MD5.reset
    MD5 << text
    MD5.hexdigest
end

# brute force by running two concurrent searches
def unmd5(hash)
    # search one: lowercase search
    lower = "a"
    # search two: ascii brute force
    gen = all_ascii
    
    loop {
        break lower if md5(lower) == hash
        lower.next!
        
        cur = gen.next
        break cur if md5(cur) == hash
    }
end

class GAPing
    def GAPing.tokenize(code)
        res = code.scan(/\h{1,32}/).to_a
        raise "invalid code sequence" if res.any? { |e| e.size != 32 }
        memo = {}
        res.map { |e|
            p "command: #{e}"
            memo[e] ||= unmd5 e
            p "finished."
        }
    end
    def GAPing.encode(commands)
        commands = commands.split rescue commands
        memo = {}
        commands.map { |e|
            memo[e] ||= md5 e
        }.join " "
    end
    
    def initialize(code)
        @tokens = GAPing.tokenize(code) rescue code
        @stack = []
        @ip = 0
        @jump = {}
        call = []
        @tokens.each.with_index { |tok, i|
            if tok == "open"
                call << i
            elsif tok == "shut"
                a = call.pop
                @jump[a] = i
                @jump[i] = a
            end
        }
    end
    
    def GAPing.truthy?(e)
        !e.empty? rescue e != 0
    end
    
    def exec(token)
        case token
            when "size"
                @stack.push @stack.pop.size
            when "add"
                @stack.push @stack.pop(2).inject { |a, c| a + c }
            when "neg"
                @stack.push -@stack.pop
            when "rep"
                @stack.push "1" * @stack.pop
            when "swap"
                @stack.push *@stack.pop(2).reverse
            when "bub"
                n = @stack.pop
                @stack.push *@stack.pop(n).rotate
            when "char"
                @stack.push @stack.pop.chr
            when "out"
                print @stack.pop
            when "dup"
                @stack.push @stack.last
            when "pop"
                @stack.pop
            when "nil"
                @stack.push 0
            when "len"
                @stack.push @stack.size
            when "open"
                @ip = @jump[@ip] unless GAPing.truthy? @stack.last
            when "shut"
                @ip = @jump[@ip] if GAPing.truthy? @stack.last
            when "?"
                p self
            when "in"
                @stack << STDIN.gets
            when "#"
                @stack << STDIN.gets.to_i
            when "btwn"
                n, lo, hi = @stack.pop(3)
                @stack << (lo <= n && n <= hi ? 1 : 0)
            else
                @stack.push token
        end
    end
    
    def run
        while @tokens[@ip]
            exec @tokens[@ip]
            @ip += 1
        end
    end
end

def splitify(code)
    code[1..-1].split(code[0]).map{|e|e.gsub(/\r|\n/,"")}
end

code = ARGV[0]
mode = :run

if code[0] == "-"
    mode = {
        "e" => :encode,
        "r" => :raw
    }[code[1]]
    raise "no such cmd argument #{code}" if mode.nil?
    code = ARGV[1]
end

code = File.read(code) rescue code

case mode
    when :run
        GAPing.new(code).run
    when :raw
        GAPing.new(splitify code).run
    when :encode
        toks = splitify code
        toks.keep_if { |e| !e.empty? }
        puts GAPing.encode toks
end