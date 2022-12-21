import Chain: @chain


## Helpers

Base.show(io::IO, v::Vector) = print(io, "[", join(v, ", "), "]")


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
        @. parse_puzzle_group
    end
end

function parse_puzzle_group(s)
    @chain s begin
        split("\n")
        @. parse_packet
        Tuple
    end
end

function parse_packet(s)
    @chain s begin
        Meta.parse
        eval
    end
end


## Part 1

function Base.isless(lhs::Int, rhs::Vector)
    [lhs] < rhs
end

function Base.isless(lhs::Vector, rhs::Int)
    lhs < [rhs]
end

function Base.:(==)(lhs::Int, rhs::Vector)
    [lhs] == rhs
end

function Base.:(==)(lhs::Vector, rhs::Int)
    lhs == [rhs]
end

function result1(pairs)
    @chain pairs begin
        [lhs < rhs for (lhs, rhs) in _]
        enumerate
        @. prod
        sum
    end
end


## Part 2

function result2(pairs)
    divider_packets = [[[2]], [[6]]]
    @chain pairs begin
        Iterators.flatten
        collect
        append!(divider_packets)
        sort!
        indexin(divider_packets, _)
        prod
    end
end
