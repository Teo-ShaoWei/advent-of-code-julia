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

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readchomp
        split("\n\n")
        (algo = _[1] |> parse_algo, image = _[2] |> parse_image)
    end
end

function parse_algo(s)
    @chain s begin
        split("")
        map(==("#"), _)
        @. Int
    end
end

function parse_image(s)
    @chain s begin
        split("\n")
        @. parse_image_row
        cat(_..., dims = 2)
        permutedims((2, 1))
        OffsetArrays.OffsetArray
    end
end

function parse_image_row(s)
    @chain s begin
        split("")
        map(==("#"), _)
        @. Int
    end
end


## Part 1

function print_area(area)
    println("size: ", join(size(area), " × "))
    println("axes: (", join(UnitRange.(axes(area)), ", "), ")")
    for row in eachrow(area)
        @chain row begin
            @. Int
            replace(1 => '█', 0 => '·')
            join
            println
        end
    end
    println()
end


function get_neighbours(c::CI)
    # 2D box include center
    offsets = [
        CI(-1, -1),
        CI(-1,  0),
        CI(-1,  1),
        CI( 0, -1),
        CI( 0,  0),
        CI( 0,  1),
        CI( 1, -1),
        CI( 1,  0),
        CI( 1,  1),
    ]

    neighbours = Ref(c) .+ offsets
    return neighbours
end

function get_enhanced_pixels(c::CI, image, algo)
    @chain c begin
        get_neighbours
        image[_]
        @. string
        join
        parse(Int, _, base=2)
        algo[_ + 1]
    end
end

function get_expanded_range(r, i)
    return range(
        start = first(r) - i,
        stop = last(r) + i,
    )
end

function expand_image(image, algo, iteration)
    is_flipped = (algo[1] == 1) && (iteration % 2 == 0)
    vec_func = is_flipped ? ones : zeros
    result = vec_func(
        Int,
        (
            get_expanded_range(axes(image, 1), 2),
            get_expanded_range(axes(image, 2), 2),
        ),
    )

    for c in CartesianIndices(image)
        result[c] = image[c]
    end

    return result
end

function enhance_image(image, algo, iteration)
    expanded_image = expand_image(image, algo, iteration)

    result = zeros(
        Int,
        (
            get_expanded_range(axes(image, 1), 1),
            get_expanded_range(axes(image, 2), 1),
        ),
    )

    for c in CartesianIndices(result)
        result[c] = get_enhanced_pixels(c, expanded_image, algo)
    end

    return result
end

function result1(pd)
    (; algo, image) = pd
    for i in 1:2
        image = enhance_image(image, algo, i)
    end

    return count(==(1), image)
end


## Part 2


function result2(pd)
    (; algo, image) = pd
    for i in 1:50
        image = enhance_image(image, algo, i)
    end

    return count(==(1), image)
end
