using Chain


## Helpers

CI = CartesianIndex


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
        split(_, "")
        @. only
    end
end


## Part 1

function result1(path)
    loc = CI(0, 0)
    seen = Set([loc])
    for p in path
        move = MOVE[p]
        loc += move
        push!(seen, loc)
    end

    return length(seen)
end


## Part 2

function result2(path)
    locs = [CI(0, 0), CI(0, 0)]
    seen = Set([locs[1]])
    for p in path
        move = MOVE[p]
        locs[1] += move
        push!(seen, locs[1])
        locs = locs[2:-1:1]
    end

    println()

    return length(seen)
end
