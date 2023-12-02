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
        split(": ")
        _[2]
        split("; ")
        @. parse_dices
    end
end

function parse_dices(s)::Vector{Int}
    r = 0; g = 0; b = 0;
    for dice_str in split(s, ", ")
        (count_str, colour) = split(dice_str, " ")
        count = parse(Int, count_str)
        (colour == "red") && (r = count)
        (colour == "green") && (g = count)
        (colour == "blue") && (b = count)
    end
    return [r, g, b]
end


## Part 1

function is_possible(round::Vector{Int})
    @chain round begin
        .≤([12, 13, 14])
        all
    end
end

function is_possible(game::Vector{Vector{Int}})
    @chain game begin
        @. is_possible
        all
    end
end

function result1(pd)
    @chain pd begin
        @. is_possible
        enumerate
        @. prod
        sum
    end
end


## Part 2

function get_min_dices(game)
    @chain game begin
        zip(_...)
        @. maximum
    end
end

function result2(pd)
    @chain pd begin
        @. get_min_dices
        @. prod
        sum
    end
end
