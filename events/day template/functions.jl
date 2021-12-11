using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

CI = CartesianIndex
CIS = CartesianIndices


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readlines
        @. parse_line
    end
end

function parse_line(line)
    @chain line begin
        line
    end
end


## Part 1

function result1(pd)
    @chain pd begin
        pd
    end
end


## Part 2

function result2(pd)
    @chain pd begin
        pd
    end
end
