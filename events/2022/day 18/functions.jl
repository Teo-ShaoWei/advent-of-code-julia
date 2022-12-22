import Chain: @chain
import Combinatorics
import DataStructures: PriorityQueue, dequeue!

## Helpers

import AdventOfCode:
    AdventOfCode,
    CI, CIS,
    make_smallest_boundary

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)


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
        join("CI($(_))")
        Meta.parse
        eval
    end
end


## Part 1

function get_distance(ci::CI{3})
    @chain ci begin
        Tuple
        @. abs
        sum
    end
end

function is_adjacent(ci1, ci2)
    get_distance(ci1 - ci2) == 1
end

function result1(scan)
    total_faces = 6 * length(scan)

    stuck_faces = @chain scan begin
        Combinatorics.combinations(2)
        [is_adjacent(ci1, ci2) for (ci1, ci2) in _]
        count
        *(2)
    end

    return total_faces - stuck_faces
end


## Part 2

"""
Given coordinate is within the given rectangular area.
"""
is_within_area(c::CI, area) = all(Tuple(c) .∈ axes(area))

"""
Neighbours doesn't include itself.
"""
function get_neighbours(c::CI, area)
    # 3D plus
    offsets = [
        CI(-1,  0,  0),
        CI( 1,  0,  0),
        CI( 0, -1,  0),
        CI( 0,  1,  0),
        CI( 0,  0, -1),
        CI( 0,  0,  1),
    ]

    neighbours = Ref(c) .+ offsets
    return filter(c -> is_within_area(c, area), neighbours)
end

function fill_cube!(state, scan)
    state[scan] .= 1
    return state
end

function queue_state_boundary(state)
    return @chain state begin
        CIS
        [
            _[begin, :, :],
            _[end, :, :],
            _[:, begin, :],
            _[:, end, :],
            _[:, :, begin],
            _[:, :, end],
        ]
        @. collect
        Iterators.flatten
        collect
        unique!
        sort!
        PriorityQueue(_ .=> 0)
    end
end

function fill_water!(state)
    queue = queue_state_boundary(state)

    while !isempty(queue)
        ci = dequeue!(queue)
        state[ci] = 2

        for nci in get_neighbours(ci, state)
            (state[nci] == 0) || continue
            queue[nci] = 0
        end
    end

    return state
end

function init_state(scan)
    return @chain scan begin
        make_smallest_boundary(; margin = (1, 1, 1))
        zeros(Int, _)
        fill_cube!(scan)
        fill_water!
    end
end

function result2(scan)
    @chain scan begin
        @aside state = init_state(_)
        map(ci -> 6 - count(!=(2), state[get_neighbours(ci, state)]), _)
        sum
    end
end
