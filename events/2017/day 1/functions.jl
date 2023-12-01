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

# Base.show(io::IO, ::MIME"text/plain", v::Vector) = print(io, "[", join(v, ", "), "]")
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
        collect
        parse.(Int, _)
    end
end

function parse_puzzle_line(s)
    @chain s begin
        string
    end
end


## Part 1

function result1(pd::Vector{Int})
    delta_pd = [pd[2:end]; pd[1]]
    map(zip(pd, delta_pd)) do (x1, x2)
        x1 == x2 ? x1 : 0
    end |> sum
end


## Part 2

function result2(pd)
    half = length(pd) ÷ 2
    delta_pd = [pd[(half + 1):end]; pd[1:half]]
    map(zip(pd, delta_pd)) do (x1, x2)
        x1 == x2 ? x1 : 0
    end |> sum
end
