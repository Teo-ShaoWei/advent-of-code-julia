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

function AdventOfCode.CI((; x, y)::@NamedTuple{x::Int, y::Int})
    return CI(y, x)
end

function Base.getproperty(ci::CI{2}, sym::Symbol)
    (sym == :x) && return ci[2]
    (sym == :y) && return ci[1]

    # CI has fields (:I,)
    return getfield(ci, sym)
end

# Does not conflict with existing defintion for showing CI{N}.
Base.show(io::IO, ::MIME"text/plain", ci::CI{2}) = print(io, "CI(", (; ci.x, ci.y), ")")

function turn_right(ci::CI{2})
    return CI((x = ci.y, y = -ci.x))
end

function turn_left(ci::CI{2})
    return CI((x = -ci.y, y = ci.x))
end


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
        split(", ")
        @. parse_move
    end
end

function parse_move(s)
    (; direction = s[1], magnitude = parse(Int, s[2:end]))
end


## Part 1

function go_next_direction(current_direction, step)
    turn_func = (step.direction == 'R' ? turn_right : turn_left)
    return turn_func(current_direction)
end

function get_directed_moves(pd)
    current_direction = CI((x = 0, y = 1))
    map(pd) do step
        current_direction = go_next_direction(current_direction, step)
        step.magnitude * current_direction
    end
end

function get_blocks_away(ci::CI{2})
    @chain ci begin
        Tuple
        collect
        @. abs
        sum
    end
end

function result1(pd)
    @chain pd begin
        get_directed_moves
        sum
        get_blocks_away
    end
end


## Part 2

function get_first_repeated_location(pd)
    current_direction = CI((x = 0, y = 1))
    current_location = CI((x = 0, y = 0))
    seen_locations = Set([current_location])

    for step in Iterators.cycle(pd)
        current_direction = go_next_direction(current_direction, step)

        for _ in 1:step.magnitude
            current_location += current_direction
            (current_location ∈ seen_locations) && return current_location
            push!(seen_locations, current_location)
        end
    end
end

function result2(pd)
    @chain pd begin
        get_first_repeated_location
        get_blocks_away
    end
end
