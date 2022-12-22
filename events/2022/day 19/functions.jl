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
    regex_str = r"Blueprint \d+: Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian."
    @chain s begin
        match(regex_str, _)
        collect
        parse.(Int, _)
        [
            _[1] _[2] _[3] _[5]
               0    0 _[4]    0
               0    0    0 _[6]
               0    0    0    0
        ]
    end
end


## Part 1

function init_state(bp; time_limit)
    return (;
        robots = [1, 0, 0, 0],
        resources = [0, 0, 0, 0],
        timing = 0,
        time_limit,
        max_robots = derive_max_robots(bp; time_limit),
    )
end

function derive_max_robots(bp; time_limit)
    result = vec(mapslices(maximum, bp; dims = 2))
    result[4] = time_limit
    return result
end

function add_robot(robots, rt::Int)
    robots = copy(robots)
    robots[rt] += 1
    return robots
end

function remove_resources(resources, cost)
    return resources .- cost
end

function has_enough_robots(state, bp)
    (; robots, resources, timing, time_limit, max_robots) = state
    enough_resources = resources .≥ bp * min.(time_limit - timing, max_robots .- robots)
    enough_resources[4] = 0

    enough_robots = robots .≥ max_robots

    return enough_robots .|| enough_resources
end

function derive_time_to_build_robot(state, bp, rt::Int)::Union{Nothing, Int}
    costs = bp[:, rt]

    max_timing = 0
    for (cost, robot, resource) in zip(costs, state.robots, state.resources)
        cost == 0 && continue
        robot == 0 && return nothing
        timing = fld(max(0, cost - resource) - 1, robot) + 2
        (max_timing < timing) && (max_timing = timing)
    end
    return max_timing
end

function mine_resources(resource, robots, timing::Int)
    return resource .+ timing .* robots
end

function make_next_state(state, bp, δtiming, rt)
    costs = bp[:, rt]

    resources = @chain state.resources begin
        mine_resources(state.robots, δtiming)
        remove_resources(costs)
    end

    return (;
        robots = add_robot(state.robots, rt),
        resources,
        timing = state.timing + δtiming,
        state.time_limit,
        state.max_robots,
    )
end

function derive_possibilities(
        bp,
        ;
        time_limit,
        state = init_state(bp; time_limit),
    )

    max_robots = derive_max_robots(bp; time_limit)
    seen = Dict(Int[] => state)
    pq = PriorityQueue(Int[] => 0)

    while !isempty(pq)
        decisions = dequeue!(pq)
        state = seen[decisions]

        enough_robots = has_enough_robots(state, bp)
        for rt in 1:4
            enough_robots[rt] && continue

            δtiming = derive_time_to_build_robot(state, bp, rt)
            isnothing(δtiming) && continue

            next_timing = state.timing + δtiming
            (next_timing > time_limit) && continue

            next_decisions = [decisions; rt]
            next_state = make_next_state(state, bp, δtiming, rt)

            seen[next_decisions] = next_state
            pq[next_decisions] = 0
        end
    end
    return seen
end

function harvest_till_time_up(state)
    return (;
        state.robots,
        resources = mine_resources(
            state.resources, state.robots, state.time_limit - state.timing
        ),
        state.timing,
        state.time_limit,
        state.max_robots,
    )
end

function derive_geode_count(bp; time_limit)
    return @chain bp begin
        derive_possibilities(; time_limit)
        values
        @. harvest_till_time_up
        [resources[4] for (; resources) in _]
        maximum
    end
end

function result1(bps)
    time_limit = 24

    return @chain bps begin
        [derive_geode_count(bp; time_limit) for bp in _]
        .*(1:length(bps))
        sum
    end

    sum(geode_counts .* (1:length(bps)))
end
