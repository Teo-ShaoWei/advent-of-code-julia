using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

import AdventOfCode:
    AdventOfCode,
    CI, CIS, print_area, parse_matrix

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


## Part 1

function get_distance(ci::CI{2})
    return abs(ci.x) + abs(ci.y)
end

function get_beacon_dist(sensor)
    return get_distance(sensor.beacon_ci - sensor.ci)
end

function get_calm_xrange(
        sensor,
        y::Int,
        beacon_dist::Int = get_beacon_dist(sensor),
        confined_range::Union{Nothing, UnitRange{Int}} = nothing,
    )

    y_dist = abs(sensor.ci.y - y)
    width = beacon_dist - y_dist
    result = range(
        start = sensor.ci.x - width,
        stop = sensor.ci.x + width,
    )

    isnothing(confined_range) || (result = result ∩ confined_range)
    return result
end

function get_xs_without_beacon(sensors, y::Int)
    sorted_sensors = sort(sensors, by = s -> (s.ci.x, s.ci.y))

    calm_xranges = get_calm_xrange.(sorted_sensors, y)

    calm_xs = union(calm_xranges...)
    beacon_xs = [s.beacon_ci.x for s in sorted_sensors if s.beacon_ci.y == y]

    return setdiff(calm_xs, beacon_xs)
end

function result1(sensors, y::Int)
    return length(get_xs_without_beacon(sensors, y))
end


## Part 2

function get_distress_index(ranges::Vector{UnitRange{Int}}, confined_range::UnitRange{Int})::Union{Nothing, Int}
    x = first(confined_range)
    for r in ranges
        isempty(r) && continue
        x < first(r) && continue
        x ≤ last(r) && (x = last(r) + 1)
        x > last(confined_range) && return nothing
    end
    return x
end

function candidate_distress_beacon_in_range(sorted_sensors, sorted_beacon_dists, y::Int, confined_range)
    calm_xranges = get_calm_xrange.(sorted_sensors, y, sorted_beacon_dists, (confined_range,))

    distress_index = get_distress_index(calm_xranges, confined_range)

    return isnothing(distress_index) ? nothing : CI((; x = distress_index, y))
end

function derive_distress_ci(sensors, (search_space_x, search_space_y))
    sorted_sensors = sort(sensors, by = s -> (s.ci.x, s.ci.y))
    sorted_beacon_dists = get_beacon_dist.(sorted_sensors)
    for y in search_space_y
        ci = candidate_distress_beacon_in_range(sorted_sensors, sorted_beacon_dists, y, search_space_x)
        isnothing(ci) || return ci

        # (y % 100000 == 0) && print(y)
    end
end

function result2(sensors, (search_space_x, search_space_y))
    ci = derive_distress_ci(sensors, (search_space_x, search_space_y))
    return ci.x * 4000000 + ci.y
end
