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
        split("\n\n")
        @. parse_elf
    end
end

function parse_elf(s)
    @chain s begin
        split("\n")
        parse.(Int, _)
    end
end


## Part 1

function result1(pd)
    @chain pd begin
        @. sum
        maximum
    end
end


## Part 2

function result2(pd)
    @chain pd begin
        @. sum
        sort(; rev = true)
        sum(_[1:3])
    end
end
