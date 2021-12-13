using Chain
using OffsetArrays


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readchomp
        split("\n\n")
        (dots = parse_dots(_[1]), ists = parse_ists(_[2]))
    end
end

function parse_dots(s)
    @chain s begin
        split("\n")
        @. parse_coor
    end
end

function parse_coor(s)
    @chain s begin
        split(",")
        parse.(Int, _)
        CI(_[2], _[1])
    end
end

function parse_ists(s)
    @chain s begin
        split("\n")
        @. parse_ist
    end
end

function parse_ist(s)
    @chain s begin
        match(r"fold along (.+)", _)
        only
        split('=')
        (axis = Val(Symbol(_[1])), value = parse(Int, _[2]))
    end
end


## Part 1

function get_area(dots)
    area = falses((
        range(start = 0, stop = maximum(d[1] for d in dots)),
        range(start = 0, stop = maximum(d[2] for d in dots)),
    ))

    area[dots] .= true
    return area
end

function fold(dot::CI, axis::Val{:x}, value)
    CI(dot[1], dot[2] < value ? dot[2] : 2 * value - dot[2])
end

function fold(dot::CI, axis::Val{:y}, value)
    CI(dot[1] < value ? dot[1] : 2 * value - dot[1], dot[2])
end

function fold(dots::Vector{<:CI}, axis, value)
    unique(fold.(dots, axis, value))
end

function result1(pd)
    area = fold(pd.dots, pd.ists[1]...) |> get_area
    return count(area)
end


## Part 2

function print_area(area)
    for row in eachrow(area)
        @chain row begin
            @. Int
            replace(1 => '█', 0 => ' ')
            join
            println
        end
    end
    println()
end

function result2(pd)
    dots = pd.dots
    for ist in pd.ists
        dots = fold(dots, ist...)
    end

    area = get_area(dots)
    print_area(area)
end
