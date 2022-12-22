import Chain: @chain
import Mods: Mod
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
        split("")
        @. only
    end
end


## Part 1

function print_area(area)
    AdventOfCode.print_matrix(area) do state
        @chain state begin
            @. Int
            rotl90
        end
    end
end

function print_area(area, rock)
    state = Int.(area)
    state[axes(rock)...] .+= 2 * Int.(rock)
    print_area(state)
end

function prepare_rock(rock, height)
    return OffsetMatrix(rock, 2, height + 3)
end

function init_state(jet_pattern, shapes)
    jet_pattern_iter = @chain jet_pattern begin
        Iterators.cycle
        Iterators.enumerate
        Iterators.Stateful
    end

    shapes_iter = @chain shapes begin
        Iterators.cycle
        Iterators.enumerate
        Iterators.Stateful
    end

    return (;
        jet_pattern_iter,
        shapes_iter,
        area = falses(1:7, 1:1),
        heights = Int[],
        final_rock_origins = CI{2}[],
        shape_indices = Mod{length(shapes)}[],
        jet_pattern_indices = Mod{length(jet_pattern)}[],
    )
end

function expand_area(old_area, rock)
    dl = CI((x = 1, y = 1))
    dr = CI((x = 7, y = 1))
    heighest_ci = CI((x = 1, y = max(lastindex(old_area, 2), lastindex(rock, 2))))

    area = falses(make_smallest_boundary([dl, dr, heighest_ci]))
    area[CIS(old_area)] .= old_area
    return area
end

function get_blow_direction(jet_char)
    return if jet_char == '<'
        -1
    elseif jet_char == '>'
        1
    else
        throw(error("invalid jet_char"))
    end
end

function is_hitting_floor(rock)
    firstindex(rock, 2) < 1
end

function is_hitting_wall(rock)
    x_range = axes(rock, 1)
    x_range ∩ (1:7) != x_range
end

function is_hitting_other_rocks(area, rock)
    !iszero(rock .& area[axes(rock)...])
end

function blow_rock(area, rock, jet_char)
    new_rock = OffsetArray(rock, get_blow_direction(jet_char), 0)

    if is_hitting_wall(new_rock) || is_hitting_other_rocks(area, new_rock)
        return (; is_moved = false, rock)
    end
    return (; is_moved = true, rock = new_rock)
end

function fall_rock(area, rock)
    new_rock = OffsetArray(rock, 0, -1)
    if is_hitting_floor(new_rock) || is_hitting_other_rocks(area, new_rock)
        return (; is_moved = false, rock)
    end
    return (; is_moved = true, rock = new_rock)
end

function fix_rock!(area, rock)
    area[axes(rock)...] .|= rock
    return area
end

function add_next_rock!(state)
    shape_index, shape = popfirst!(state.shapes_iter)
    height = isempty(state.heights) ? 0 : state.heights[end]
    rock = prepare_rock(shape, height)
    area = expand_area(state.area, rock)

    # print_area(area, rock)

    jet_pattern_index = 0
    while true
        jet_pattern_index, jet_char = popfirst!(state.jet_pattern_iter)
        rock = blow_rock(area, rock, jet_char).rock

        # print_area(area, rock)

        fall_result = fall_rock(area, rock)
        fall_result.is_moved || break
        rock = fall_result.rock

        # print_area(area, rock)
    end

    # print_area(area, rock)

    fix_rock!(area, rock)
    push!(state.heights, findlast(mapslices(any, area; dims = 1)).y)
    push!(state.final_rock_origins, CIS(rock)[1])
    push!(state.shape_indices, shape_index)
    push!(state.jet_pattern_indices, jet_pattern_index)

    state = (;
        state.jet_pattern_iter,
        state.shapes_iter,
        area,
        state.heights,
        state.final_rock_origins,
        state.shape_indices,
        state.jet_pattern_indices,
    )
    return state
end

function add_rocks(jet_pattern, shapes, rock_count; verbose = false)
    state = init_state(jet_pattern, shapes)

    for k in 1:rock_count
        state = add_next_rock!(state)

        if verbose
            @show state.heights[end]
            print_area(state.area)
        end
    end

    return state
end

function result1(jet_pattern, shapes)
    state = add_rocks(jet_pattern, shapes, 2022)
    state.heights[end]
end


## Part 2

function get_move_signature(state, k)
    cis = @chain state.final_rock_origins begin
        _[(k - 5): k]
        (ci -> ci - CI((; x = 0, state.final_rock_origins[k].y))).(_)
    end
    return (;
        shape_index = state.shape_indices[k],
        jet_pattern_index = state.jet_pattern_indices[k],
        cis,
    ) => (; rock_count = k, height = state.heights[k])
end

function find_repetition(jet_pattern, shapes, count)
    state = add_rocks(jet_pattern, shapes, count)

    seen = Dict()
    for k in 6:count
        (signature, stat) = get_move_signature(state, k)
        if haskey(seen, signature)
            return (; stat1 = seen[signature], stat2 = stat, state.heights)
        else
            seen[signature] = stat
        end
    end
end

function derive_height(crazy_rock_count, jet_pattern, shapes, rock_limit)
    (; stat1, stat2, heights) = find_repetition(jet_pattern, shapes, rock_limit)
    δrock_count = stat2.rock_count - stat1.rock_count
    δheight = stat2.height - stat1.height

    d, r =  divrem(crazy_rock_count, δrock_count)
    return heights[r + δrock_count] + (d - 1) * δheight
end

function result2(jet_pattern, shapes, rock_limit)
    crazy_rock_count = 1000000000000
    derive_height(crazy_rock_count, jet_pattern, shapes, rock_limit)
end
