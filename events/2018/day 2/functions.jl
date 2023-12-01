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
        split("\n")
        @. parse_puzzle_line
    end
end

function parse_puzzle_line(s)
    @chain s begin
        string
    end
end


## Part 1

function gather_chars(s::String)
    d = DataStructures.DefaultDict{Char, Int}(0)
    foreach(s) do c
        d[c] += 1
    end
    return d
end

function has_multi_char(s::String, n::Int)
    @chain s begin
        gather_chars
        values
        n ∈ _
    end
end

function result1(pd)
    count(has_multi_char.(pd, 2)) * count(has_multi_char.(pd, 3))
end


## Part 2

function is_target_boxes(s1, s2)
    count(collect(s1) .!= collect(s2)) == 1
end

function get_common_letters(s1, s2)
    collect(s1)[collect(s1) .== collect(s2)] |> join
end

function result2(pd)
    for (s1, s2) in Combinatorics.combinations(pd, 2)
        is_target_boxes(s1, s2) && return get_common_letters(s1, s2)
    end
end
