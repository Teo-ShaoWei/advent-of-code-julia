import Chain: @chain
import OffsetArrays: OffsetVector

## Helpers

import AdventOfCode:
    AdventOfCode,
    CI, CIS,
    print_matrix,
    make_smallest_boundary

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


# Types

struct Rule{T}
    x::T
end

Base.show(io::IO, r::Rule) = print(io, r.x)

abstract type PuzzleData end

Base.@kwdef struct PuzzleSample1 <: PuzzleData
    faces::Vector{OffsetVector{Matrix{Char}}}
    rules::Vector{Rule}
end

Base.@kwdef struct PuzzleInput <: PuzzleData
    faces::Vector{OffsetVector{Matrix{Char}}}
    rules::Vector{Rule}
end

abstract type PartStyle end
struct Part1 <: PartStyle end
struct Part2 <: PartStyle end


## Parse input

get_face_side_length(::PDT) where {PDT <: PuzzleData} = get_face_side_length(PDT)
get_face_side_length(::Type{PuzzleSample1}) = 4
get_face_side_length(::Type{PuzzleInput}) = 50

identify_faces(::PDT) where {PDT <: PuzzleData} = identify_faces(PDT)

function identify_faces(::Type{PuzzleSample1})
    return [
        CI(1, 3),
        CI(2, 1),
        CI(2, 2),
        CI(2, 3),
        CI(3, 3),
        CI(3, 4),
    ]
end

function identify_faces(::Type{PuzzleInput})
    return [
        CI(1, 2),
        CI(1, 3),
        CI(2, 2),
        CI(3, 1),
        CI(3, 2),
        CI(4, 1),
    ]
end

function parse_puzzle_file(filename::String, puzzle_type::Type{<:PuzzleData})
    @chain filename begin
        readchomp
        parse_puzzle_data(puzzle_type)
    end
end

function parse_puzzle_data(s, puzzle_type::Type{<:PuzzleData})
    @chain s begin
        split("\n\n")
        puzzle_type(faces = parse_faces(_[1]; puzzle_type), rules = parse_rule(_[2]))
    end
end

function parse_faces(s; puzzle_type::Type{<:PuzzleData})
    @chain s begin
        split("\n")
        @aside pad = maximum(length(v) for v in _)
        rpad.(pad)
        @. parse_line
        cat(_...; dims = 2)
        permutedims((2, 1))
        make_face_orientations(; puzzle_type)
    end
end

function parse_line(s)
    @chain s begin
        split("")
        @. only
    end
end

function make_face_orientations(m::AbstractMatrix; puzzle_type::Type{<:PuzzleData})
    return map(identify_faces(puzzle_type)) do ci
        face = m[get_original_region(ci, puzzle_type)]
        orientations = [face]
        for _ in 1:3
            push!(orientations, rotl90(orientations[end]))
        end
        return OffsetVector(orientations, -1)
    end
end

function parse_rule(s)
    rules = @chain s begin
        eachmatch(r"(\d+)(\D)", _)
        [[parse(Int, v[1]), only(v[2])] for v in _]
        Iterators.flatten
        collect
        @. Rule
    end

    @chain s begin
        match(r"\w+\D(\d+)", _)
        only
        parse(Int, _)
        Rule
        push!(rules, _)
    end

    return rules
end


## Part 1

function print_whole_area(pd::PuzzleData)
    (; faces) = pd
    map_legend = [
        (
            pred = ==('.'),
            char = '·',
        ),
        (
            pred = ==(' '),
            char = ' ',
        ),
        (
            pred = ==('#'),
            char = '#',
        ),
    ]

    face_side_length = get_face_side_length(pd)
    face_map = identify_faces(pd)
    (range1, range2)  = make_smallest_boundary(face_map)
    area = fill(
        ' ',
        (
            range(
                start = (first(range1) - 1) * face_side_length + 1,
                stop = last(range1) * face_side_length,
            ),
            range(
                start = (first(range2) - 1) * face_side_length + 1,
                stop = last(range2) * face_side_length,
            ),
        )
    )

    for (i, face) in enumerate(faces)
        area[get_original_region(face_map[i], pd)] .= face[0]
    end
    print_matrix(area; map_legend)
end


function get_original_region(ci::CI{2}, ::PDT) where {PDT <: PuzzleData}
    get_original_region(ci, PDT)
end

function get_original_region(ci::CI{2}, puzzle_type::Type{<:PuzzleData})
    face_side_length = get_face_side_length(puzzle_type)
    CIS((
        range(
            start = (ci[1] - 1) * face_side_length + 1,
            stop = ci[1] * face_side_length,
        ),
        range(
            start = (ci[2] - 1) * face_side_length + 1,
            stop = ci[2] * face_side_length,
        )
    ))
end

function get_big_pos((; ci, face, dir), pd::PuzzleData)
    face_side_length = get_face_side_length(pd)
    face_map = identify_faces(pd)
    for k in 1:dir
        ci = CI(ci[2], face_side_length  + 1 - ci[1])
    end

    ci += (face_map[face] - CI(1, 1)) * face_side_length
    return (; ci, dir)
end

function make_warp_map(::PuzzleSample1, ::Part1)
    return Dict(
        (face = 1, dir = 0) => (face = 1, dir = 0),
        (face = 1, dir = 1) => (face = 4, dir = 1),
        (face = 1, dir = 2) => (face = 1, dir = 2),
        (face = 1, dir = 3) => (face = 5, dir = 3),

        (face = 2, dir = 0) => (face = 3, dir = 0),
        (face = 2, dir = 1) => (face = 2, dir = 1),
        (face = 2, dir = 2) => (face = 4, dir = 2),
        (face = 2, dir = 3) => (face = 2, dir = 3),

        (face = 3, dir = 0) => (face = 4, dir = 0),
        (face = 3, dir = 1) => (face = 3, dir = 1),
        (face = 3, dir = 2) => (face = 2, dir = 2),
        (face = 3, dir = 3) => (face = 3, dir = 3),

        (face = 4, dir = 0) => (face = 2, dir = 0),
        (face = 4, dir = 1) => (face = 5, dir = 1),
        (face = 4, dir = 2) => (face = 3, dir = 2),
        (face = 4, dir = 3) => (face = 1, dir = 3),

        (face = 5, dir = 0) => (face = 6, dir = 0),
        (face = 5, dir = 1) => (face = 1, dir = 1),
        (face = 5, dir = 2) => (face = 6, dir = 2),
        (face = 5, dir = 3) => (face = 4, dir = 3),

        (face = 6, dir = 0) => (face = 5, dir = 0),
        (face = 6, dir = 1) => (face = 6, dir = 1),
        (face = 6, dir = 2) => (face = 5, dir = 2),
        (face = 6, dir = 3) => (face = 6, dir = 3),
    )
end

function make_warp_map(::PuzzleInput, ::Part1)
    return Dict(
        (face = 1, dir = 0) => (face = 2, dir = 0),
        (face = 1, dir = 1) => (face = 3, dir = 1),
        (face = 1, dir = 2) => (face = 2, dir = 2),
        (face = 1, dir = 3) => (face = 5, dir = 3),

        (face = 2, dir = 0) => (face = 1, dir = 0),
        (face = 2, dir = 1) => (face = 2, dir = 1),
        (face = 2, dir = 2) => (face = 1, dir = 2),
        (face = 2, dir = 3) => (face = 2, dir = 3),

        (face = 3, dir = 0) => (face = 3, dir = 0),
        (face = 3, dir = 1) => (face = 5, dir = 1),
        (face = 3, dir = 2) => (face = 3, dir = 2),
        (face = 3, dir = 3) => (face = 1, dir = 3),

        (face = 4, dir = 0) => (face = 5, dir = 0),
        (face = 4, dir = 1) => (face = 6, dir = 1),
        (face = 4, dir = 2) => (face = 5, dir = 2),
        (face = 4, dir = 3) => (face = 6, dir = 3),

        (face = 5, dir = 0) => (face = 4, dir = 0),
        (face = 5, dir = 1) => (face = 1, dir = 1),
        (face = 5, dir = 2) => (face = 4, dir = 2),
        (face = 5, dir = 3) => (face = 3, dir = 3),

        (face = 6, dir = 0) => (face = 6, dir = 0),
        (face = 6, dir = 1) => (face = 4, dir = 1),
        (face = 6, dir = 2) => (face = 6, dir = 2),
        (face = 6, dir = 3) => (face = 4, dir = 3),
    )
end

function get_starting_pos(::PuzzleData)
    (; ci = CI(1, 1), face = 1, dir = 0)
end

function move((; ci, face, dir), faces, face_side_length, warp_map)
    if ci[2] ≥ face_side_length
        (next_face, next_dir) = warp_map[(; face, dir)]
        next_ci = CI(ci[1], 1)
    else
        (next_face, next_dir) = (face, dir)
        next_ci = ci + CI(0, 1)
    end

    if faces[next_face][next_dir][next_ci] != '#'
        (ci, face, dir) = (next_ci, next_face, next_dir)
    end
    return (; ci, face, dir)
end

function follow_rule(rule::Rule{Int}, pos, faces, face_side_length, warp_map)
    for k in 1:rule.x
        pos = move(pos, faces, face_side_length, warp_map)
    end
    return pos
end

function follow_rule(rule::Rule{Char}, pos, faces, face_side_length, warp_map)
    (; ci, dir) = pos
    if (rule.x == 'R')
        dir = mod(dir + 1, 4)
        ci = CI(face_side_length + 1 - ci[2], ci[1])
    else
        dir = mod(dir - 1, 4)
        ci = CI(ci[2], face_side_length  + 1 - ci[1])
    end
    return (; ci, pos.face, dir)
end

function follow_rules(pd::PuzzleData; puzzle_part::PartStyle)
    face_side_length = get_face_side_length(pd)
    warp_map = make_warp_map(pd, puzzle_part)
    pos = get_starting_pos(pd)

    for rule in pd.rules
        pos = follow_rule(rule, pos, pd.faces, face_side_length, warp_map)
    end
    return get_big_pos(pos, pd)
end

function result1(pd::PuzzleData)
    (; ci, dir) = follow_rules(
        pd;
        puzzle_part = Part1(),
    )

    return 1000 * ci[1] + 4 * ci[2] + dir
end


## Part 2

function make_warp_map(::PuzzleSample1, ::Part2)
    return Dict(
        (face = 1, dir = 0) => (face = 6, dir = 2),
        (face = 1, dir = 1) => (face = 4, dir = 1),
        (face = 1, dir = 2) => (face = 3, dir = 1),
        (face = 1, dir = 3) => (face = 2, dir = 1),

        (face = 2, dir = 0) => (face = 3, dir = 0),
        (face = 2, dir = 1) => (face = 5, dir = 3),
        (face = 2, dir = 2) => (face = 6, dir = 3),
        (face = 2, dir = 3) => (face = 1, dir = 1),

        (face = 3, dir = 0) => (face = 4, dir = 0),
        (face = 3, dir = 1) => (face = 5, dir = 0),
        (face = 3, dir = 2) => (face = 2, dir = 2),
        (face = 3, dir = 3) => (face = 1, dir = 0),

        (face = 4, dir = 0) => (face = 6, dir = 1),
        (face = 4, dir = 1) => (face = 5, dir = 1),
        (face = 4, dir = 2) => (face = 3, dir = 2),
        (face = 4, dir = 3) => (face = 1, dir = 3),

        (face = 5, dir = 0) => (face = 6, dir = 0),
        (face = 5, dir = 1) => (face = 2, dir = 3),
        (face = 5, dir = 2) => (face = 3, dir = 3),
        (face = 5, dir = 3) => (face = 4, dir = 3),

        (face = 6, dir = 0) => (face = 1, dir = 2),
        (face = 6, dir = 1) => (face = 2, dir = 0),
        (face = 6, dir = 2) => (face = 5, dir = 2),
        (face = 6, dir = 3) => (face = 4, dir = 2),
    )
end

function make_warp_map(::PuzzleInput, ::Part2)
    return Dict(
        (face = 1, dir = 0) => (face = 2, dir = 0),
        (face = 1, dir = 1) => (face = 3, dir = 1),
        (face = 1, dir = 2) => (face = 4, dir = 0),
        (face = 1, dir = 3) => (face = 6, dir = 0),

        (face = 2, dir = 0) => (face = 5, dir = 2),
        (face = 2, dir = 1) => (face = 3, dir = 2),
        (face = 2, dir = 2) => (face = 1, dir = 2),
        (face = 2, dir = 3) => (face = 6, dir = 3),

        (face = 3, dir = 0) => (face = 2, dir = 3),
        (face = 3, dir = 1) => (face = 5, dir = 1),
        (face = 3, dir = 2) => (face = 4, dir = 1),
        (face = 3, dir = 3) => (face = 1, dir = 3),

        (face = 4, dir = 0) => (face = 5, dir = 0),
        (face = 4, dir = 1) => (face = 6, dir = 1),
        (face = 4, dir = 2) => (face = 1, dir = 0),
        (face = 4, dir = 3) => (face = 3, dir = 0),

        (face = 5, dir = 0) => (face = 2, dir = 2),
        (face = 5, dir = 1) => (face = 6, dir = 2),
        (face = 5, dir = 2) => (face = 4, dir = 2),
        (face = 5, dir = 3) => (face = 3, dir = 3),

        (face = 6, dir = 0) => (face = 5, dir = 3),
        (face = 6, dir = 1) => (face = 2, dir = 1),
        (face = 6, dir = 2) => (face = 1, dir = 1),
        (face = 6, dir = 3) => (face = 4, dir = 3),
    )
end

function result2(pd::PuzzleData)
    (; ci, dir) = follow_rules(
        pd;
        puzzle_part = Part2(),
    )

    return 1000 * ci[1] + 4 * ci[2] + dir
end
