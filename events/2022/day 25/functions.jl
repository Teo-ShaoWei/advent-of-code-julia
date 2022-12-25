using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))

Base.show(io::IO, v::Vector) = print(io, "[", join(v, ", "), "]")


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
    end
end


## Part 1

"""
Parse snafu vector (sv), which is an int-vector of values in (-2:2).
"""
function parse_sv(c)
    (c == '-') && return -1
    (c == '=') && return -2
    return parse(Int, c)
end

function snafu_to_int(snafu)
    sv = @chain snafu begin
        split("")
        @. only
        @. parse_sv
    end

    x = 0
    for k in sv
        x = 5 * x + k
    end
    return x
end

function int_to_snafu(x)
    sv = Int[]

    while x != 0
        (d, m) = fldmod(x + 2, 5)
        pushfirst!(sv, m - 2)
        x = d
    end

    return @chain sv begin
        @. parse_snafu
        join
    end
end

function parse_snafu(k)
    return ['=', '-', 0, 1, 2][k + 3]
end

function result1(pd)
    @chain pd begin
        @. snafu_to_int
        sum
        int_to_snafu
    end
end
