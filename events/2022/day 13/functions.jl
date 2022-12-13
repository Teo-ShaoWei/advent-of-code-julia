using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

import AdventOfCode: AdventOfCode, print_area, parse_matrix

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


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
    ordered_check = [lhs < rhs for (lhs, rhs) in pairs]
    sum(prod.(enumerate(ordered_check)))
end


## Part 2

function result2(pairs)
    divider_packets = [[[2]], [[6]]]
    sorted_packets = @chain pairs begin
        Iterators.flatten
        collect
        append!(divider_packets)
        sort!
    end

    prod(indexin(divider_packets, sorted_packets))
end
