import Chain: @chain


## Parse input

function parse_puzzle_file(filename::String)
    @chain filename begin
        readchomp
        parse_puzzle_data
    end
end

macro pd_str(s::String)
    @chain s begin
        chomp
        parse_puzzle_data
    end
end

function parse_puzzle_data(s)
    @chain s begin
        string
    end
end

function first_consecutive(msg, n)
    for i in n:length(msg)
        i_range = range(start = i - n + 1, stop = i)
        (length(Set(msg[i_range])) == n) && return i
    end
end


## Part 1

function result1(pd)
    first_consecutive(pd, 4)
end


## Part 2

function result2(pd)
    first_consecutive(pd, 14)
end
