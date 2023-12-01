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
        collect
        @. Symbol
    end
end


## Part 1

function get_code(ci::CI{2})
    [
        '1' '2' '3';
        '4' '5' '6';
        '7' '8' '9';
    ][ci]
end

function move(ci::CI{2}, ::Val{:U})
    (ci[1] == 1) && return ci
    return ci - CI(1, 0)
end
function move(ci::CI{2}, ::Val{:D})
    (ci[1] == 3) && return ci
    return ci + CI(1, 0)
end
function move(ci::CI{2}, ::Val{:L})
    (ci[2] == 1) && return ci
    return ci - CI(0, 1)
end
function move(ci::CI{2}, ::Val{:R})
    (ci[2] == 3) && return ci
    return ci + CI(0, 1)
end

function go_next(ci::CI{2}, rule::Vector{Symbol})
    for c in rule
        ci = move(ci, Val(c))
    end
    return ci
end

function result1(pd)
    ci = CI(2, 2)
    digits = map(pd) do rule
        ci = go_next(ci, rule)
        get_code(ci)
    end

    join(digits)
end


## Part 2

function get_fancy_code(ci::CI{2})
    [
        ' ' ' ' '1' ' ' ' ';
        ' ' '2' '3' '4' ' ';
        '5' '6' '7' '8' '9';
        ' ' 'A' 'B' 'C' ' ';
        ' ' ' ' 'D' ' ' ' ';
    ][ci]
end

function move_fancy(ci::CI{2}, ::Val{:U})
    (ci[1] + ci[2] == 4) && return ci
    (ci[2] - ci[1] == 2) && return ci
    return ci - CI(1, 0)
end
function move_fancy(ci::CI{2}, ::Val{:D})
    (ci[1] + ci[2] == 8) && return ci
    (ci[1] - ci[2] == 2) && return ci
    return ci + CI(1, 0)
end
function move_fancy(ci::CI{2}, ::Val{:L})
    (ci[1] + ci[2] == 4) && return ci
    (ci[1] - ci[2] == 2) && return ci
    return ci - CI(0, 1)
end
function move_fancy(ci::CI{2}, ::Val{:R})
    (ci[1] + ci[2] == 8) && return ci
    (ci[2] - ci[1] == 2) && return ci
    return ci + CI(0, 1)
end

function go_next_fancy(ci::CI{2}, rule::Vector{Symbol})
    for c in rule
        ci = move_fancy(ci, Val(c))
    end
    return ci
end

function result2(pd)
    ci = CI(3, 1)
    digits = map(pd) do rule
        ci = go_next_fancy(ci, rule)
        get_fancy_code(ci)
    end

    join(digits)
end
