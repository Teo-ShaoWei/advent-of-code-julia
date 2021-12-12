using Chain


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readlines
        parse.(Int, _)
    end
end


## Part 1

function result1(depths)
    return count(2:length(depths)) do i
        depths[i - 1] < depths[i]
    end
end


## Part 2

function result2(depths)
    return count(4:length(depths)) do i
        depths[i - 3] < depths[i]
    end
end
