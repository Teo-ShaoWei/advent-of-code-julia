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

function parse_input(filename::String)
    @chain filename begin
        readlines
        @. parse_line
    end
end

function parse_line(line)
    @chain line begin
        split(" ")
        parse_op(Val(Symbol(_[1])), _[2:end])
    end
end

function is_state(v)
    v ∈ ('w', 'x', 'y', 'z')
end

function parse_op(op, rs)
    rs = (v -> is_state(v[1]) ? only(v) : parse(Int, v)).(rs)
    (; op, rs)
end


## Part 1

function init_state()
    return Dict(
        'w' => 0,
        'x' => 0,
        'y' => 0,
        'z' => 0,
    )
end

function next_op!(op::Val{:inp}, rs, state, input_values)
    (a,) = rs
    state[a] = Iterators.take(input_values, 1) |> only
    return state
end

function next_op!(op::Val{:add}, rs, state, _)
    (a, b) = rs
    state[a] += is_state(b) ? state[b] : b
    return state
end

function next_op!(op::Val{:mul}, rs, state, _)
    (a, b) = rs
    state[a] *= is_state(b) ? state[b] : b
    return state
end

function next_op!(op::Val{:div}, rs, state, _)
    (a, b) = rs
    state[a] ÷= is_state(b) ? state[b] : b
    return state
end

function next_op!(op::Val{:mod}, rs, state, input_values)
    (a, b) = rs
    state[a] %= is_state(b) ? state[b] : b
    return state
end

function next_op!(op::Val{:eql}, rs, state, input_values)
    (a, b) = rs
    state[a] = (state[a] == (is_state(b) ? state[b] : b)) ? 1 : 0
    return state
end

macro v_str(s)
    @chain s begin
        split("")
        parse.(Int, _)
    end
end

function run_program(ops, input_values)
    input_values = Iterators.Stateful(input_values)
    state = init_state()

    for (op, rs) in ops
        next_op!(op, rs, state, input_values)
        @show op rs state
        println()
    end

    return state
end

function get_possibilities(ops)
    possibilities = Dict(
        'w' => Set{Int}(),
        'x' => Set{Int}(),
        'y' => Set{Int}(),
        'z' => Set{Int}(),
    )

    for i in 1:9
        input_values = [i]
        state = init_state()

        for (op, rs) in ops
            next_op!(op, rs, state, input_values)
        end

        for c in ('w', 'x', 'y', 'z')
            push!(possibilities[c], state[c])
        end
    end
    return possibilities
end

function result1(ops)
    for i in 99999999999999:-1:10000000000000
        input_values = parse.(Int, split(string(i), ""))
        state = run_program(ops, input_values)
        (state['z'] == 0) && return i
    end
end


## Part 2

function result2(ops)
    @chain ops begin
        _
    end
end
