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

function get_move(c)
    move = Dict(
        '(' => 1,
        ')' => -1,
    )
    move[c]
end

function result1(pd)
    @chain pd begin
        @. get_move
        sum
    end
end


## Part 2

function result2(pd)
    @chain pd begin
        @. get_move
        cumsum
        findfirst(<(0), _)
    end
end
