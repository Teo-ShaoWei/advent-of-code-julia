using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

import AdventOfCode:
    AdventOfCode,
    CI, CIS,
    make_smallest_boundary,
    parse_matrix,
    print_matrix

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))

Base.show(io::IO, ::MIME"text/plain", v::Base.Iterators.Enumerate) = foreach((x,) -> println(io, "{ ", x[1], ": ", x[2], " }"), v)
Base.show(io::IO, v::Base.Iterators.Enumerate) = show(io, "text/plain", v)

# Base.show(io::IO, ::MIME"text/plain", v::Vector) = print(io, "[", join(v, ", "), "]")
# Base.show(io::IO, ::MIME"text/plain", v::Vector{Vector{T}} where {T}) = show(io, enumerate(v))
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
        split("")
        @. parse_char
    end
end

function parse_char(s)
    return only(s)
end


## Part 1

function get_move(c)
    Dict(
        '(' => 1,
        ')' => -1,
    )[c]
end

function result1(pd)
    @chain pd begin
        @. get_move
        sum
    end
end


## Part 2

function result2(pd)
    @chain pd begin
        @. get_move
        cumsum
        findfirst(<(0), _)
    end
end
