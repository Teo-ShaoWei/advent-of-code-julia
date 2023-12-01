using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

import AdventOfCode:
    AdventOfCode,
    CI, CIS,
    make_smallest_boundary,
    parse_matrix,
    print_matrix

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))

# Base.show(io::IO, ::MIME"text/plain", v::Vector) = print(io, "[", join(v, ", "), "]")
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
        split(",")
        parse.(Int, _)
        OffsetArrays.OffsetArray(-1)
    end
end


## Part 1

function perform_op!(rule::AbstractVector{Int}, idx::Int)
    op = Val(rule[idx])
    return perform_op!(op, rule, idx)
end
function perform_op!(::Val{99}, rule::AbstractVector{Int}, idx::Int)
    return (; terminate = true, idx)
end

function perform_op!(::Val{1}, rule::AbstractVector{Int}, idx::Int)
    (i1, i2, i3) = collect(rule[(idx + 1):(idx + 3)])
    rule[i3] = rule[i1] + rule[i2]
    return (; terminate = false, idx = idx + 4)
end

function perform_op!(::Val{2}, rule::AbstractVector{Int}, idx::Int)
    (i1, i2, i3) = collect(rule[(idx + 1):(idx + 3)])
    rule[i3] = rule[i1] * rule[i2]
    return (; terminate = false, idx = idx + 4)
end

function run_program!(rule)
    idx = 0
    while true
        (; terminate, idx) = perform_op!(rule, idx)
        terminate && break
    end
    return rule
end

function result1(pd)
    rule = OffsetArrays.OffsetArray(copy(pd))
    rule[1] = 12
    rule[2] = 2

    run_program!(rule)
    return rule[0]
end


## Part 2

function result2(pd)
    magic_output = 19690720
    for noun in 0:99, verb in 0:99
        rule = OffsetArrays.OffsetArray(copy(pd))
        rule[1] = noun
        rule[2] = verb

        run_program!(rule)
        (rule[0] == magic_output) && return 100 * noun + verb
    end
end
