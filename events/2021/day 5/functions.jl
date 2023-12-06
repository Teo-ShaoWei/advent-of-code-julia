using Chain
using OffsetArrays


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

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
        split("\n")
        @. parse_puzzle_line
    end
end

function parse_puzzle_line(s)
    @chain s begin
        split(" -> ")
        @. parse_coor
        Pair(_...)
    end
end

function parse_coor(s)
    @chain s begin
        split(',')
        parse.(Int, _)
        CI(_...)
    end
end


## Part 1

function init_area(lines)
    return zeros(
        Int,
        (
            range(
                start = 0,
                stop = maximum(max(c1[1], c2[1]) for (c1, c2) in lines),
            ),
            range(
                start = 0,
                stop = maximum(max(c1[2], c2[2]) for (c1, c2) in lines),
            ),
        ),
    )
end

function is_straight(line)
    (c1, c2) = line
    c1[1] == c2[1] || c1[2] == c2[2]
end

function draw_straight_vents(area, line)
    (c1, c2) = line
    vent_indices = collect(c1:c2) ∪ collect(c2:c1)
    area[vent_indices] .+= 1
    return area
end

function result1(lines)
    area = init_area(lines)
    for line in lines
        !is_straight(line) && continue
        area = draw_straight_vents(area, line)
    end
    return count(>(1), area)
end


## Part 2

function is_diagonal(line)
    !is_straight(line)
end

function draw_diagonal_vents(area, line)
    (c1, c2) = line
    diff_c = c2 - c1
    step = CI(sign(diff_c[1]), sign(diff_c[2]))
    width = abs(diff_c[1])
    area[[c1 + i * step for i in 0:width]] .+= 1
    return area
end

function result2(lines)
    area = init_area(lines)
    for line in lines
        if is_straight(line)
            area = draw_straight_vents(area, line)
        else
            area = draw_diagonal_vents(area, line)
        end
    end
    return count(>(1), area)
end
