using Chain


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readlines
        only
        parse_line
    end
end

function parse_line(line)
    @chain line begin
        split("")
        @. only
    end
end


## Part 1

function get_move(direction)
    move = Dict(
        '^' => CI(-1, 0),
        '>' => CI(0, 1),
        'v' => CI(1, 0),
        '<' => CI(0, -1),
    )
    return move[direction]
end

function result1(directions)
    loc = CI(0, 0)
    seen = Set([loc])
    for d in directions
        loc += get_move(d)
        push!(seen, loc)
    end

    return length(seen)
end


## Part 2

function result2(directions)
    locs = [CI(0, 0), CI(0, 0)]
    seen = Set([locs[1]])
    for d in directions
        locs[1] += get_move(d)
        push!(seen, locs[1])
        reverse!(locs)
    end

    return length(seen)
end
