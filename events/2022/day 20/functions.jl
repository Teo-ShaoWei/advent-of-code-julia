import Chain: @chain
import CircularList: CircularList, Node, circularlist, current, jump!, move!, shift!
using Combinatorics
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
        split(",")
        parse.(Int, _)
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
        parse(Int, _)
    end
end


## Part 1

function init_state(v)
    (x1, rest_v) = Iterators.peel(v)
    cl = circularlist([x1])
    nodes = [current(cl)]

    for x in rest_v
        insert!(cl, x)
        push!(nodes, current(cl))
    end

    return (; cl, nodes)
end

function shift_node!(cl, node, steroid = 1)
    x = node.data
    steps = mod(x * steroid, length(cl) - 1)

    jump!(cl, node)
    move!(cl, steps)
end

function shift_around!((; cl, nodes), steroid = 1)
    for node in nodes
        shift_node!(cl, node, steroid)
    end
    jump!(cl, findfirst(==(0), cl))

    return cl
end

function derive_grove_coordinates(cl)
    shift!(cl, 1000)
    x1 = current(cl).data
    shift!(cl, 1000)
    x2 = current(cl).data
    shift!(cl, 1000)
    x3 = current(cl).data
    return (x1, x2, x3)
end

function result1(v)
    (; cl, nodes) = init_state(v)
    shift_around!((; cl, nodes))

    @chain cl begin
        derive_grove_coordinates
        sum
    end
end


## Part 2

function result2(v)
    steroid = 811589153
    (; cl, nodes) = init_state(v)

    for _ in 1:10
        shift_around!((; cl, nodes), steroid)
    end

    @chain cl begin
        derive_grove_coordinates
        sum
        *(steroid)
    end
end
