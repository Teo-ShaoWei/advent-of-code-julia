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
    print_area,
    parse_matrix

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
        split(" -> ")
        @. parse_coord
    end
end

function parse_coord(s)
    @chain s begin
        "CI($(_))"
        Meta.parse
        eval
    end
end


## Part 1

# state convention:
# 0 - empty
# 1 - rock
# 2 - sand

function print_state(state::OffsetArray{Int})
    print_area(
        permutedims(state, (2, 1)),
    )
end

function init_state(paths, starting_ci)
    (yrange, xrange) = @chain paths begin
        Iterators.flatten
        collect
        make_smallest_boundary
    end

    # because sand falls in a traingle shape.

    lower_left_corner = CI((
        x = last(xrange),
        y = min(first(yrange), 500 - last(xrange)),
    ))

    lower_right_corner = CI((
        x = last(xrange),
        y = max(last(yrange), 500 + last(xrange)),
    ))

    @chain begin
        make_smallest_boundary([starting_ci, lower_left_corner, lower_right_corner])
        zeros(Int, _)
        block_rocks_with_paths!(paths)
    end
end

function block_rocks_with_paths!(state::OffsetMatrix{Int}, paths::Vector{Vector{CI{2}}})
    for path in paths
        for k in 2:length(path)
            for ci in CIS(make_smallest_boundary([path[k - 1], path[k]]))
                block_rock!(state, ci)
            end
        end
    end

    return state
end

function block_rock!(state::OffsetMatrix{Int}, ci::CI{2})
    state[ci] = 1
end

function block_sand!(state::OffsetMatrix{Int}, ci::CI{2})
    state[ci] = 2
end

function count_sand(state)
    count(==(2), state)
end

function is_blocked(state::OffsetArray{Int}, ci::CI{2})
    return state[ci] != 0
end

function next_sand(state::OffsetArray{Int}, starting_ci)::CI{2}
    ci = starting_ci

    while true
        ci.x == lastindex(state, 2) && return ci

        next_ci = ci + CI((x = 1, y = 0))
        if !is_blocked(state, next_ci)
            ci = next_ci
            continue
        end

        next_ci = ci + CI((x = 1, y = -1))
        if !is_blocked(state, next_ci)
            ci = next_ci
            continue
        end

        next_ci = ci + CI((x = 1, y = 1))
        if !is_blocked(state, next_ci)
            ci = next_ci
            continue
        end

        return ci
    end
end

function fill_sand_part1(paths)
    starting_ci = CI((x = 0, y = 500))
    state = init_state(paths, starting_ci)

    for c in Iterators.countfrom(1)
        ci = next_sand(state, starting_ci)
        ci.x == lastindex(state, 2) && break
        block_sand!(state, ci)

        # (c > 10) && (println("manual break!"); println(); break)
    end

    return state
end

function result1(paths)
    state = fill_sand_part1(paths)
    return count_sand(state)
end


## Part 2

function add_floor(state)
    new_state = zeros(
        Int,
        range(
            start = firstindex(state, 1) - 1,
            stop = lastindex(state, 1) + 1,
        ),
        range(
            start = firstindex(state, 2),
            stop = lastindex(state, 2) + 1,
        ),
    )
    new_state[CIS(state)] = state

    return new_state
end

function fill_sand_part2(paths)
    starting_ci = CI((x = 0, y = 500))

    state = @chain paths begin
        init_state(starting_ci)
        add_floor
    end

    for c in Iterators.countfrom(1)
        ci = next_sand(state, starting_ci)
        is_blocked(state, starting_ci) && break
        block_sand!(state, ci)

        # (c > 10) && (println("manual break!"); println(); break)
    end

    return state
end

function result2(paths)
    state = fill_sand_part2(paths)
    return count_sand(state)
end
