import Chain: @chain
import DataStructures: PriorityQueue, dequeue!
import OffsetArrays: OffsetVector
import Mods: Mod, value


## Helpers

import AdventOfCode:
    AdventOfCode,
    CI, CIS,
    parse_matrix

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)

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
        parse_matrix(; elem_dlm = "")
        @. only
        _[2:(end - 1), 2:(end - 1)]
        (_,) .|> (parse_blizzard, size)
        (:blizzards, :maze_size) .=> _
        NamedTuple
    end
end

function parse_directional_blizzard(area; char::Char, move_dim::Int, lane_dim::Int, dir::Int)
    v = OffsetVector(
        [[Int[] for _ in axes(area, lane_dim)] for _ in axes(area, move_dim)],
        -1,
    )

    for ci in CIS(area)
        if area[ci] == char
            for k in 0:(size(area, move_dim) - 1)
                loc = mod(ci[move_dim] + dir * k - 1, size(area, move_dim)) + 1
                push!(v[k][ci[lane_dim]], loc)
            end
        end
    end

    return v
end

function parse_blizzard(area)
    return (;
        r = parse_directional_blizzard(area; char = '>', move_dim = 2, lane_dim = 1, dir = 1),
        d = parse_directional_blizzard(area; char = 'v', move_dim = 1, lane_dim = 2, dir = 1),
        l = parse_directional_blizzard(area; char = '<', move_dim = 2, lane_dim = 1, dir = -1),
        u = parse_directional_blizzard(area; char = '^', move_dim = 1, lane_dim = 2, dir = -1),
    )
end

function move_blizzards(blizzards::Vector{Vector{Int}}, modulo::Int, dir::Int)
    map(blizzards) do b
        [mod(x + dir - 1, modulo) + 1 for x in b]
    end
end

## Part 1

function is_at_endpoints(ci::CI, maze_size::Tuple{Int, Int})
    (ci == CI(0, 1)) || (ci == CI(maze_size) + CI(1, 0))
end

function get_neighbours(ci::CI, maze_size::Tuple{Int, Int})
    # 2D plus with itself
    offsets = [
        CI( 0,  0),
        CI(-1,  0),
        CI( 1,  0),
        CI( 0, -1),
        CI( 0,  1),
    ]

    neighbours = Ref(ci) .+ offsets
    neighbours = filter(nci ->  all(Tuple(nci) .∈ [1:s for s in maze_size]), neighbours)
    is_at_endpoints(ci, maze_size) && push!(neighbours, ci)
    return neighbours
end

function is_in_blizzard((; ci, row_cycle, col_cycle), blizzards)
    return any((
        (ci[2] ∈ blizzards.r[value(col_cycle)][ci[1]]),
        (ci[1] ∈ blizzards.d[value(row_cycle)][ci[2]]),
        (ci[2] ∈ blizzards.l[value(col_cycle)][ci[1]]),
        (ci[1] ∈ blizzards.u[value(row_cycle)][ci[2]]),
    ))
end

function find_best_path((; blizzards, maze_size))
    initial_state = (;
        ci = CI(1, 1),
        row_cycle = Mod{maze_size[1]}(1),
        col_cycle = Mod{maze_size[2]}(1),
    )
    seen = Dict(initial_state => 1)
    pq = PriorityQueue(
        initial_state => 1
    )

    while !isempty(pq)
        state = dequeue!(pq)
        timing = seen[state]
        for nci in get_neighbours(state.ci, maze_size)
            next_state = (;
                ci = nci,
                row_cycle = state.row_cycle + 1,
                col_cycle = state.col_cycle + 1
            )

            haskey(seen, next_state) && continue
            is_in_blizzard(next_state, blizzards) && continue
            seen[next_state] = timing + 1
            (nci == CI(maze_size)) && return (; seen, final_state = next_state)

            pq[next_state] = timing + 1
        end
    end

    @warn "incomplete!"
    return seen
end

function result1(pd)
    (; seen, final_state) = find_best_path(pd)
    return seen[final_state] + 1
end


## Part 2

function find_best_tft_path((; blizzards, maze_size))
    initial_state = (;
        ci = CI(1, 1),
        row_cycle = Mod{maze_size[1]}(1),
        col_cycle = Mod{maze_size[2]}(1),
        trip_portion = 1,
    )
    seen = Dict(initial_state => 1)
    pq = PriorityQueue(
        initial_state => 1
    )

    while !isempty(pq)
        state = dequeue!(pq)
        timing = seen[state]
        for nci in get_neighbours(state.ci, maze_size)

            next_state = (;
                ci = nci,
                row_cycle = state.row_cycle + 1,
                col_cycle = state.col_cycle + 1,
                state.trip_portion,
            )

            haskey(seen, next_state) && continue


            if !is_at_endpoints(nci, maze_size) && is_in_blizzard(next_state, blizzards)
                continue
            end

            next_timing = timing + 1
            seen[next_state] = next_timing

            if (nci == CI(maze_size)) && (mod(next_state.trip_portion, 2) == 1)
                next_state = (;
                    ci = next_state.ci + CI(1, 0),
                    row_cycle = next_state.row_cycle + 1,
                    col_cycle = next_state.col_cycle + 1,
                    trip_portion = next_state.trip_portion + 1,
                )

                haskey(seen, next_state) && continue
                next_timing += 1
                seen[next_state] = next_timing

            elseif (nci == CI(1, 1)) && (mod(next_state.trip_portion, 2) == 0)
                next_state = (;
                    ci = next_state.ci - CI(1, 0),
                    row_cycle = next_state.row_cycle + 1,
                    col_cycle = next_state.col_cycle + 1,
                    trip_portion = next_state.trip_portion + 1,
                )

                haskey(seen, next_state) && continue
                next_timing += 1
                seen[next_state] = next_timing
            end

            if next_state.trip_portion == 4
                return (; seen, final_state = next_state)
            end

            pq[next_state] = next_timing
        end
    end

    @warn "incomplete!"
    return seen
end

function result2(pd)
    (; seen, final_state) = find_best_tft_path(pd)
    return seen[final_state]
end
