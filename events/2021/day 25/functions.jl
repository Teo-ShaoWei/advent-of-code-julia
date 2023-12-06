using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readlines
        @. parse_line
        cat(_..., dims = 2)
        permutedims((2, 1))
    end
end

function parse_line(line)
    @chain line begin
        split("")
        @. only
    end
end


## Part 1

function get_east_ci(area, ci)
    new_ci = ci + CI(0, 1)
    (new_ci[2] > size(area, 2)) && (new_ci = CI(new_ci[1], 1))
    return new_ci
end

function get_south_ci(area, ci)
    new_ci = ci + CI(1, 0)
    (new_ci[1] > size(area, 1)) && (new_ci = CI(1, new_ci[2]))
    return new_ci
end

function move_east!(area)
    moves = []
    for src_ci in CIS(area)
        (area[src_ci] == '>') || continue
        dst_ci = get_east_ci(area, src_ci)
        (area[dst_ci] == '.') || continue
        push!(moves, src_ci => dst_ci)
    end

    for (src_ci, dst_ci) in moves
        area[dst_ci] = '>'
        area[src_ci] = '.'
    end

    return area
end

function move_south!(area)
    moves = []
    for src_ci in CIS(area)
        (area[src_ci] == 'v') || continue
        dst_ci = get_south_ci(area, src_ci)
        (area[dst_ci] == '.') || continue
        push!(moves, src_ci => dst_ci)
    end

    for (src_ci, dst_ci) in moves
        area[dst_ci] = 'v'
        area[src_ci] = '.'
    end

    return area
end

function move(area)
    area = deepcopy(area)
    move_east!(area)
    move_south!(area)
end


function result1(area)
    # for i in 1:58
    for i in Iterators.countfrom(1, 1)
        new_area = move(area)
        (new_area == area) && return i
        area = new_area
    end

    return area
end


## Part 2

function result2(area)
    @chain area begin
        _
    end
end
