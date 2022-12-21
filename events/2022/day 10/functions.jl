import Chain: @chain


## Helpers

import AdventOfCode:
    AdventOfCode,
    print_matrix, CI, CIS

function AdventOfCode.CI((; x, y)::@NamedTuple{x::Int, y::Int})
    return CI(y, x)
end

function Base.getproperty(ci::CI{2}, sym::Symbol)
    (sym == :x) && return ci[2]
    (sym == :y) && return ci[1]

    # CI has fields (:I,)
    return getfield(ci, sym)
end

# Does not conflict with existing defintion for showing CI{N}.
Base.show(io::IO, ::MIME"text/plain", ci::CI{2}) = print(io, "CI(", (; ci.x, ci.y), ")")


## Types

abstract type Op end

struct Noop <: Op end

struct AddX <: Op
    n::Int
end


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
    op = s[1:4]

    if op == "noop"
        return Noop()
    else  # op == "addx"
        n = parse(Int, s[6:end])
        return AddX(n)
    end
end


## Part 1

function update!(values, ::Noop)
    push!(values, values[end])
end

function update!(values, op::AddX)
    push!(values, values[end])
    push!(values, values[end] + op.n)
end

function make_values(ops)
    values = [1]

    for op in ops
        update!(values, op)
    end
    return values
end

function result1(ops)
    values = make_values(ops)

    indices = [20, 60, 100, 140, 180, 220]
    sum(values[indices] .* indices)
end


## Part 2

function get_sprite(n)
    return n:(n + 2)
end

function result2(ops)
    sprites = get_sprite.(make_values(ops))
    crt = falses(6, 40)

    for x in axes(crt, 2), y in axes(crt, 1)
        crt[y, x] = x ∈ sprites[(y - 1) * 40 + x]
    end

    print_matrix(crt)
end

function result2(ops)
    sprites = @chain ops begin
        make_values
        _[1:(end - 1)]
        @. get_sprite
        reshape((40, :))
        permutedims((2, 1))
    end

    crt = falses(6, 40)
    cix = [ci.x for ci in CIS(crt)]

    crt .= cix .∈ sprites
    print_matrix(crt)
end
