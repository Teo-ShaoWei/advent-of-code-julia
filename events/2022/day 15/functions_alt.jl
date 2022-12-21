# This implementation is idea from Daniel González on Julia Zulip AoC discussion [here](https://julialang.zulipchat.com/#narrow/stream/357313-advent-of-code-.282022.29/topic/day.2015/near/316151594).

import Chain: @chain
import Combinatorics


## Helpers

import AdventOfCode:
    AdventOfCode,
    CI, CIS, print_matrix, parse_matrix

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
        match(r"Sensor at (.+): closest beacon is at (.+)", _)
        collect
        @. parse_ci
        (ci = _[1], beacon_ci = _[2])
    end
end

function parse_ci(s)
    @chain s begin
        "CI(($(_)))"
        Meta.parse
        eval
    end
end


## Part 2 only

function get_distance(ci::CI{2})
    return abs(ci.x) + abs(ci.y)
end

function get_beacon_dist(sensor)
    return get_distance(sensor.beacon_ci - sensor.ci)
end

function get_slash_constant(ci::CI{2})
    ci.x + ci.y
end

function get_backslash_constant(ci::CI{2})
    ci.x - ci.y
end

function get_boundary_range(
        (sensor1, beacon_dist1),
        (sensor2, beacon_dist2);
        get_constant
    )
    c1 = get_constant(sensor1.ci)
    c2 = get_constant(sensor2.ci)

    return if c1 < c2
        range(
            start = c1 + beacon_dist1 + 1,
            stop = c2 - beacon_dist2 - 1,
        )
    else  # c1 ≥ c2
        range(
            start = c2 + beacon_dist2 + 1,
            stop = c1 - beacon_dist1 - 1,
        )
    end
end

function derive_line_boundary_ranges(sensors; get_constant)
    ranges = Int[]
    beacon_dists = get_beacon_dist.(sensors)
    for (i, j) in Combinatorics.combinations(1:length(sensors), 2)
        range = get_boundary_range(
            (sensors[i], beacon_dists[i]),
            (sensors[j], beacon_dists[j]),
            ;
            get_constant,
        )

        length(range) == 1 && push!(ranges, first(range))
    end
    return unique!(sort!(ranges))
end

function derive_ci_from_slashes(slash_constant, backslash_constant)
    return CI((
        x = (slash_constant + backslash_constant) ÷ 2,
        y = (slash_constant - backslash_constant) ÷ 2,
    ))
end

function in_beacon_area(ci, sensor, beacon_dist)
    get_distance(ci - sensor.ci) ≤ beacon_dist
end

function derive_candidate_distress_cis(sensors, (search_space_x, search_space_y))
    beacon_dists = get_beacon_dist.(sensors)
    slash_lines = derive_line_boundary_ranges(sensors; get_constant = get_slash_constant)
    backslash_lines = derive_line_boundary_ranges(sensors; get_constant = get_backslash_constant)

    for (slash_constant, backslash_constant) in Iterators.product(slash_lines, backslash_lines)
        ci = derive_ci_from_slashes(slash_constant, backslash_constant)
        all(Tuple(ci) .∈ (search_space_x, search_space_y)) || continue
        any(in_beacon_area.((ci,), sensors, beacon_dists)) && continue
        return ci
    end
end

function result2(sensors, (search_space_x, search_space_y))
    ci = derive_candidate_distress_cis(sensors, (search_space_x, search_space_y))
    return ci.x * 4000000 + ci.y
end
