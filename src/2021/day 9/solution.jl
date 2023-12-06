using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

⋆(f::Base.Callable) = Base.splat(f)

CI = CartesianIndex
CIS = CartesianIndices


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readlines
        @. parse_line
        cat(_..., dims=(2,))
        permutedims((2, 1))
    end
end

function parse_line(line)
    @chain line begin
        split("")
        parse.(Int, _)
    end
end


## Part 1

function neighbours(area, index::CI)
    result = CI[]
    if index[1] > 1
        push!(result, index - CI(1, 0))
    end
    if index[1] < size(area, 1)
        push!(result, index + CI(1, 0))
    end
    if index[2] > 1
        push!(result, index - CI(0, 1))
        push!(result, CI(index[1], index[2] - 1))
    end
    if index[2] < size(area, 2)
        push!(result, index + CI(0, 1))
        push!(result, CI(index[1], index[2] + 1))
    end

    return result
end

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
