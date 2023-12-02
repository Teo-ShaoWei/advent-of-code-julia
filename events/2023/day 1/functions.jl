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

function find_first_digit(s::String)
    @chain s begin
        match(r".*?(\d).*", _)
        collect
        only
    end
end

function find_last_digit(s::String)
    @chain s begin
        match(r".*(\d).*?", _)
        collect
        only
    end
end

function make_calibration_value(s::String)::Int
    parse(Int, find_first_digit(s) * find_last_digit(s))
end

function result1(pd)
    @chain pd begin
        @. make_calibration_value
        sum
    end
end


## Part 2

function parse_digit_string(d::String)::Char
    (d[1] ∈ "123456789") && return d[1]
    return Dict(
        [
            "one",
            "two",
            "three",
            "four",
            "five",
            "six",
            "seven",
            "eight",
            "nine",
        ] .=> '1':'9'
    )[d]
end

function find_first_digit_new(s::String)::Char
    @chain s begin
        match(r".*?(\d|one|two|three|four|five|six|seven|eight|nine).*", _)
        collect
        only
        string
        parse_digit_string
    end
end

function find_last_digit_new(s::String)::Char
    @chain s begin
        match(r".*(\d|one|two|three|four|five|six|seven|eight|nine).*?", _)
        collect
        only
        string
        parse_digit_string
    end
end

function make_calibration_value_new(s::String)::Int
    parse(Int, find_first_digit_new(s) * find_last_digit_new(s))
end

function result2(pd)
    @chain pd begin
        @. make_calibration_value_new
        sum
    end
end
