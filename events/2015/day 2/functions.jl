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
        split("x")
        parse.(Int, _)
    end
end


## Part 1

function get_slack_area(dims)
    @chain dims begin
        sort!
        _[1: 2]
        prod
    end
end

function get_surface_area((l, w, h))
    2 * l * w + 2 * w * h + 2 * h * l
end

function result1(pd)
    @chain pd begin
        [get_slack_area(dims) + get_surface_area(dims) for dims in _]
        sum
    end
end


## Part 2

function get_ribbon_wrap(dims)
    @chain dims begin
        sort!
        _[1:2]
        sum
        _ * 2
    end
end

function get_ribbon_bow(dims)
    prod(dims)
end

function result2(pd)
    @chain pd begin
        [get_ribbon_wrap(dims) + get_ribbon_bow(dims) for dims in _]
        sum
    end
end
