using Chain

## Helpers

S = Iterators.Stateful

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    parse_input_data(readchomp(filename))
end

function parse_input_data(s)
    @chain s begin
        split("")
        parse.(Int, _, base=16)
        string.(base=2, pad=4)
        join
    end
end

## Part 1

import Base.Iterators: take

function extract(s, n)
    @chain s begin
        take(n)
        collect
        join
    end
end

function s2b(s, n)
    @chain s begin
        extract(n)
        parse(Int, _, base = 2)
    end
end

function parse_packet(s::S, versions)
    push!(versions, s2b(s, 3))
    T = s2b(s, 3) |> Val

    parse_packet(s, T, versions)
end

function parse_packet(s::S, T::Val{:4}, versions)
    result_s = ""
    flag = true

    while flag
        flag = s2b(s, 1) == 1
        result_s = @chain s begin
            extract(4)
            join([result_s, _])
        end
    end

    isempty(result_s) && result_s == "0"
    parse(Int, result_s, base=2)
end

function parse_packet(s::S, T::Val, versions)
    LT = s2b(s, 1) |> Val
    @chain s begin
        parse_sub_packets(LT, versions)
        process_values(T)
    end
end

function parse_sub_packets(s::S, LT::Val{:0}, versions)
    sub_s_len = s2b(s, 15)
    sub_s = S(extract(s, sub_s_len))

    values = []
    while !isempty(sub_s)
        push!(values, parse_packet(sub_s, versions))
    end

    return values
end

function parse_sub_packets(s::S, LT::Val{:1}, versions)
    count = s2b(s, 11)
    values = []
    for i in 1:count
        push!(values, parse_packet(s, versions))
    end

    return values
end

function result1(pd)
    versions = []
    parse_packet(S(pd), versions)
    versions |> sum
end


## Part 2

function process_values(values, T::Val{:0})
    sum(values)
end

function process_values(values, T::Val{:1})
    prod(values)
end

function process_values(values, T::Val{:2})
    minimum(values)
end

function process_values(values, T::Val{:3})
    maximum(values)
end

function process_values(values, T::Val{:5})
    (values[1] > values[2]) ? 1 : 0
end

function process_values(values, T::Val{:6})
    (values[1] < values[2]) ? 1 : 0
end

function process_values(values, T::Val{:7})
    (values[1] == values[2]) ? 1 : 0
end

function result2(pd)
    parse_packet(S(pd), [])
end
