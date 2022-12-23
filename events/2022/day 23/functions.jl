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
        parse_matrix(; elem_dlm = "")
        @. only
        collect_elves
    end
end

function is_elf(ci::CI{2}, area)
    area[ci] == '#'
end

function collect_elves(area)
    [ci for ci in CIS(area) if is_elf(ci, area)]
end

function make_area(elves; margin = (1, 1))
    area = fill('.', make_smallest_boundary(elves; margin))
    area[elves] .= '#'
    return area
end


## Part 1

"""
Given coordinate is within the given rectangular area.
"""
is_within_area(c::CI, area) = all(Tuple(c) .∈ axes(area))

"""
Neighbours doesn't include itself.
"""
function get_neighbours(c::CI, area)
    # 2D box
    offsets = [
        CI(-1, -1),
        CI( 0, -1),
        CI( 1, -1),
        CI(-1,  0),
        CI( 1,  0),
        CI(-1,  1),
        CI( 0,  1),
        CI( 1,  1),
    ]

    neighbours = Ref(c) .+ offsets
    return filter(c -> is_within_area(c, area), neighbours)
end

function get_neighbours(c::CI, direction::CI)
    offsets = Dict(
        CI(-1,  0) => CI(-1, -1):CI(-1,  1),
        CI( 1,  0) => CI( 1, -1):CI( 1,  1),
        CI( 0,  1) => CI(-1,  1):CI( 1,  1),
        CI( 0, -1) => CI(-1, -1):CI( 1, -1),
    )

    return (c,) .+ offsets[direction]
end

function get_move(k::Int)
    d = [
        CI( 0,  1),
        CI(-1,  0),
        CI( 1,  0),
        CI( 0, -1),
    ]

    return d[k]
end

function propose_move(elf::CI{2}, area, move_order::Vector{CI{2}})
    all_ncis = get_neighbours(elf, area)
    any(area[all_ncis] .== '#') || return elf

    for move in move_order
        ncis = get_neighbours(elf, move)
        any(area[ncis] .== '#') && continue
        return ncis[2]
    end
    return elf
end

function move(elves; k)
    area = make_area(elves)
    move_order = get_move.(mod.((0:3) .+ k, 4) .+ 1)
    proposals = [propose_move(elf, area, move_order) for elf in elves]

    return map(zip(elves, proposals)) do (e, p)
        count(==(p), proposals) == 1 ? p : e
    end
end

function repeated_move(elves, n)
    for k in 1:n
        elves = move(elves; k)
    end
    return elves
end

function result1(elves)
    elves = repeated_move(elves, 10)

    return @chain elves begin
        make_area(; margin = (0, 0))
        [ci for ci in CIS(_) if _[ci] == '.']
        length
    end
end


## Part 2

function move_till_done(elves)
    for k in Iterators.countfrom(1)
        new_elves = move(elves; k)
        (elves == new_elves) && return k
        elves = new_elves
    end
end

function result2(elves)
    move_till_done(elves)
end
