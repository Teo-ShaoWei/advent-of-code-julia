using Chain


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

function result1(moves)
    @chain moves begin
        map(c -> MOVE[c], _)
        sum
    end
end


## Part 2

function result2(moves)
    @chain moves begin
        map(c -> MOVE[c], _)
        cumsum
        findfirst(<(0), _)
    end
end
