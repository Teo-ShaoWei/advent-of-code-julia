# This implementation is idea from Gunnar Farnebäck on Julia Zulip AoC discussion [here](https://julialang.zulipchat.com/#narrow/stream/357313-advent-of-code-.282022.29/topic/day.2020/near/317219037)
# The implementation I use to submit is similar in idea but has so much distractions like channels/asyncs.
# Wrote this version from scratch from the idea.

import Chain: @chain
import DataStructures: PriorityQueue, dequeue!


## Types

const Op = Union{typeof(+), typeof(-), typeof(*), typeof(÷)}

abstract type Monkey end

struct Equation <: Monkey
    f::Op
    variables::Tuple{String, String}
end

struct Value <: Monkey
    x::Int
end

struct Unknown <: Monkey end

"""
Represents the linear expression mx + c.
"""
struct Linear
    m::Rational{Int}
    c::Rational{Int}
end

Base.:(+)(lhs::Linear, rhs::Linear) = Linear(lhs.m + rhs.m, lhs.c + rhs.c)
Base.:(-)(lhs::Linear, rhs::Linear) = Linear(lhs.m - rhs.m, lhs.c - rhs.c)

function Base.:(*)(lhs::Linear, rhs::Linear)
    (lhs.m * rhs.m == 0) || throw(error("both side have x, resulting in quadratic!"))
    return Linear(lhs.m * rhs.c + rhs.m * lhs.c, lhs.c * rhs.c)
end

function Base.div(lhs::Linear, rhs::Linear, ::RoundingMode{:ToZero})
    (rhs.m == 0) || throw(error("rhs has x, resulting in reciprocal!"))
    return Linear(lhs.m / rhs.c , lhs.c / rhs.c)
end

## Helpers

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
        @. parse_puzzle_line
        Dict
    end
end

function parse_puzzle_line(s)
    @chain s begin
        split(": ")
        @. string
        _[1] => parse_jobs(_[2])
    end
end

function parse_jobs(s)::Monkey
    s = replace(s, '/' => '÷')
    match_result = match(r"(\w+)\s(\+|\-|\*|÷)\s(\w+)", s)
    if isnothing(match_result)
        return Value(parse(BigInt, s))
    else
        return @chain match_result begin
            Equation(eval(Meta.parse(_[2])), (_[1], _[3]))
        end
    end
end


## Part 1

function do_job(monkey::Value, _, _)
    monkey.x
end

function do_job(monkey::Equation, monkeys, values)
    return monkey.f(get_value.(monkey.variables, (monkeys,), (values,))...)
end

function get_value(id, monkeys, values)
    get!(values, id) do
        value = do_job(monkeys[id], monkeys, values)
        return value
    end
end

function result1(monkeys)
    values = Dict{String, Int}()
    get_value("root", monkeys, values)
end


## Part 2

function edit_jobs(monkeys)
    monkeys = deepcopy(monkeys)
    monkeys["humn"] = Unknown()
    root_variables = monkeys["root"].variables
    monkeys["root"] = Equation(-, root_variables)
    return monkeys
end

function do_new_job(monkey::Unknown, _, _)
    Linear(1, 0)  # humn is x == 1x + 0.
end

function do_new_job(monkey::Value, _, _)
    Linear(0, monkey.x)  # value is constant c.
end

function do_new_job(monkey::Equation, monkeys, values)
    return monkey.f(get_new_value.(monkey.variables, (monkeys,), (values,))...)
end

function get_new_value(id, monkeys, values)
    get!(values, id) do
        value = do_new_job(monkeys[id], monkeys, values)
        return value
    end
end

function result2(monkeys)
    monkeys = edit_jobs(monkeys)

    values = Dict{String, Linear}()
    (; m, c) = get_new_value("root", monkeys, values)
    return Int(-(c // m))
end
