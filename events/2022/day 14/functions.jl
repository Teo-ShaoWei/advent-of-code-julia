import Chain: @chain
import OffsetArrays: OffsetArray, OffsetMatrix

## Helpers

import AdventOfCode:
    AdventOfCode,
    CI, CIS,
    make_smallest_boundary,
    print_matrix

function AdventOfCode.CI((; x, y)::@NamedTuple{x::Int, y::Int})
    return CI(x, y)
end

function Base.getproperty(ci::CI{2}, sym::Symbol)
    (sym == :x) && return ci[1]
    (sym == :y) && return ci[2]

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

# area convention:
# 0 - empty
# 1 - rock
# 2 - sand

function print_state((; area, starting_ci))
    println("starting_ci: ", starting_ci)
    println()
    print_matrix(
        permutedims(area, (2, 1)),
    )
end

function init_state(paths; margin = (0, 0))
    starting_ci = CI((x = 500, y = 0))

    (xrange, yrange) = @chain paths begin
        Iterators.flatten
        collect
        make_smallest_boundary(; margin)
    end

    # because sand falls in a traingle shape from (x = 500, y = 0).
    # as depth is yrange[end], the lower corners CIs are as follows:

    lower_left_corner = CI((
        x = min(xrange[begin], 500 - yrange[end]),
        y = yrange[end],
    ))

    lower_right_corner = CI((
        x = max(xrange[end], 500 + yrange[end]),
        y = yrange[end],
    ))

    area = @chain begin
        make_smallest_boundary([starting_ci, lower_left_corner, lower_right_corner])
        zeros(Int, _)
        block_rocks_with_paths!(paths)
    end

    return (; area, starting_ci)
end

function block_rocks_with_paths!(area::OffsetMatrix{Int}, paths::Vector{Vector{CI{2}}})
    for path in paths
        for k in 2:length(path)
            for ci in CIS(make_smallest_boundary([path[k - 1], path[k]]))
                block_rock!(area, ci)
            end
        end
    end

    return area
end

function block_rock!(area::OffsetMatrix{Int}, ci::CI{2})
    area[ci] = 1
end

function block_sand!(area::OffsetMatrix{Int}, ci::CI{2})
    area[ci] = 2
end

function is_blocked(area::OffsetArray{Int}, ci::CI{2})
    return area[ci] != 0
end

function count_sand(area)
    count(==(2), area)
end

function next_sand((; area, starting_ci))::CI{2}
    ci = starting_ci
    while ci.y != lastindex(area, 2)
        next_ci = ci + CI((x = 0, y = 1))
        if !is_blocked(area, next_ci)
            ci = next_ci
            continue
        end

        next_ci = ci + CI((x = -1, y = 1))
        if !is_blocked(area, next_ci)
            ci = next_ci
            continue
        end

        next_ci = ci + CI((x = 1, y = 1))
        if !is_blocked(area, next_ci)
            ci = next_ci
            continue
        end

        break
    end
    return ci
end

function fill_sand_part1(paths)
    state = init_state(paths)

    for c in Iterators.countfrom(1)
        ci = next_sand(state)
        ci.y == lastindex(state.area, 2) && break
        block_sand!(state.area, ci)

        # (c > 10) && (println("manual break!"); println(); break)
    end

    return state
end

function result1(paths)
    @chain paths begin
        fill_sand_part1
        count_sand(_.area)
    end
end


## Part 2

function fill_sand_part2(paths)
    state = init_state(paths; margin = (1, 1))

    for c in Iterators.countfrom(1)
        ci = next_sand(state)
        is_blocked(state.area, state.starting_ci) && break
        block_sand!(state.area, ci)

        # (c > 10) && (println("manual break!"); println(); break)
    end

    return state
end

function result2(paths)
    @chain paths begin
        fill_sand_part2
        count_sand(_.area)
    end
end
