using Chain


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readlines
        @. parse_line
    end
end

function parse_line(line)
    @chain line begin
        match(r"(\d+)x(\d+)x(\d+)", _)
        collect
        parse.(Int, _)
        (l = _[1], w = _[2], h = _[3])
    end
end


## Part 1

function smallest_side_dims(dims)
    sort!(collect(dims))[1:2]
end

function get_wrapping_paper_size(dims)
    (; l, w, h) = dims
    surface = 2*l*w + 2*w*h + 2*h*l
    slack = smallest_side_dims(dims) |> prod
    return surface + slack
end

function result1(dimss)
    @chain dimss begin
        @. get_wrapping_paper_size
        sum
    end
end


## Part 2

volume(dims) = prod(dims)

function get_ribbon_length(dims)
    wrap = 2 * sum(smallest_side_dims(dims))
    ribbon = volume(dims)
    return wrap + ribbon
end

function result2(dimss)
    @chain dimss begin
        @. get_ribbon_length
        sum
    end
end
