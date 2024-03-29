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
        split("\n")
        @. parse_puzzle_line
    end
end

function parse_puzzle_line(s)
    string(s)
end

function get_priority(c::Char)
    if c ∈ 'a':'z'
        return c - 'a' + 1
    elseif c ∈ 'A':'Z'
        return c - 'A' + 27
    end
end


## Part 1

function get_sacks(group)
    mid = length(group) ÷ 2
    Iterators.partition(group, mid)
end

function get_common_elem(v)
    @chain v begin
        ∩(_...)
        only
    end
end

function result1(pd)
    @chain pd begin
        @. get_sacks
        @. get_common_elem
        @. get_priority
        sum
    end
end


## Part 2

function result2(pd)
    @chain pd begin
        Iterators.partition(3)
        @. get_common_elem
        @. get_priority
        sum
    end
end
