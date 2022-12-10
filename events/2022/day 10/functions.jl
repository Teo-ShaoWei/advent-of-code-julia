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

function print_area(area)
    println("size: ", join(size(area), " × "))
    println("axes: (", join(UnitRange.(axes(area)), ", "), ")")
    for row in eachrow(area)
        @chain row begin
            @. Int
            replace(1 => '░', 0 => '·')
            join
            println
        end
    end
    println()
end

function result2(ops)
    sprites = get_sprite.(make_values(ops))
    crt = BitArray(fill(false, (6, 40)))

    for x in axes(crt, 2), y in axes(crt, 1)
        crt[y, x] = x ∈ sprites[(y - 1) * 40 + x]
    end

    print_area(crt)
end
