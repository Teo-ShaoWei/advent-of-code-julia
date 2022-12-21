import Chain: @chain
import DataStructures: PriorityQueue, dequeue!


## Helpers

import AdventOfCode: CI, CIS, parse_matrix

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


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
        parse_matrix(; elem_dlm = "")
        @. only
    end
end


## Part 1

function find_char(area, char)
    findfirst(==(char), area)
end

"""
Given coordinate is within the given rectangular area.
"""
is_within_area(c::CI, area) = all(Tuple(c) .∈ axes(area))

"""
Neighbours doesn't include itself.
"""
function get_neighbours(c::CI, area)
    # 2D plus
    offsets = [
        CI(-1,  0),
        CI( 1,  0),
        CI( 0, -1),
        CI( 0,  1),
    ]

    neighbours = Ref(c) .+ offsets
    return filter(c -> is_within_area(c, area), neighbours)
end

function init_steps(area, start_index)::Matrix{Union{Nothing, Int}}
    map(CIS(area)) do I
        (I == start_index) ? 0 : nothing
    end
end

function get_height(char)
    (char == 'S') && (char = 'a')
    (char == 'E') && (char = 'z')
    return char - 'a'
end

function can_go_up(src_char, tgt_char)
    get_height(tgt_char) ≤ get_height(src_char) + 1
end

function search_fastest_path(area; start_char, can_move, is_done)
    start_index = find_char(area, start_char)
    steps = init_steps(area, start_index)

    pq = PriorityQueue{CI{2}, Int}(start_index => 0)
    for k in Iterators.countfrom(1)  # easy breaking =P
        i = dequeue!(pq)
        next_step_count = steps[i] + 1
        for ni in get_neighbours(i, area)
            isnothing(steps[ni]) || continue
            can_move(area[i], area[ni]) || continue

            steps[ni] = next_step_count
            pq[ni] = next_step_count

            is_done(ni, area) && return steps[ni]
        end

        # (k == 4) && break
    end
end

function result1(area)
    search_fastest_path(
        area;
        start_char = 'S',
        can_move = can_go_up,
        is_done = (i, area) -> area[i] == 'E',
    )
end


## Part 2

function can_go_down(src_char, tgt_char)
    get_height(src_char) ≤ get_height(tgt_char) + 1
end

function result2(area)
    search_fastest_path(
        area;
        start_char = 'E',
        can_move = can_go_down,
        is_done = (i, area) -> area[i] ∈ ('a', 'S'),
    )
end
