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

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_puzzle_file(filename::String)
    @chain filename begin
        readchomp
        parse_puzzle_data
    end
end

macro pd_str(s::String)
    @chain s begin
        chomp
        parse_puzzle_data
    end
end

function parse_puzzle_data(s)
    @chain s begin
        split("\n")
        @. parse_puzzle_line
    end
end

function parse_puzzle_line(s)
    @chain s begin
        split(",")
        @. parse_pair
    end
end

function parse_pair(s)
    @chain s begin
        split("-")
        @. parse(Int, _)
    end
end


## Part 1

function get_ranges(((r11, r12), (r21, r22)))
    (r11:r12, r21:r22)
end

function one_in_another((r1, r2))
    return (r1 ⊆ r2) || (r2 ⊆ r1)
end

function result1(pd)
    @chain pd begin
        @. get_ranges
        @. one_in_another
        count
    end
end


## Part 2

function is_intersect((r1, r2))
    return !isempty(r1 ∩ r2)
end

function result2(pd)
    @chain pd begin
        @. get_ranges
        @. is_intersect
        sum
    end
end
