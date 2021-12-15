using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readchomp
        split("\n\n")
        (template = _[1], insertions = parse_insertions(_[2]))
    end
end

function parse_insertions(s)
    @chain s begin
        split('\n')
        @. parse_insertion
        Dict
    end
end

function parse_insertion(s)
    @chain s begin
        split(" -> ")
        (only.(Tuple(split(_[1], ""))), only(_[2]))
    end
end


# solution

function init_polymer(template, insertions)
    polymer = Dict(k => 0 for (k, v) in insertions)

    for i in 2:length(template)
        polymer[(template[i - 1], template[i])] += 1
    end

    return polymer
end

function next(polymer, insertions)
    new_polymer = Dict(k => 0 for (k, v) in insertions)
    for (k, v) in polymer
        elem = insertions[k]
        s1 = (k[1], elem)
        s2 = (elem, k[2])
        new_polymer[s1] += v
        new_polymer[s2] += v
    end
    return new_polymer
end

function get_freq(polymer, template, insertions)
    freq = Dict(c => 0 for c in only.(values(insertions)))
    for (k, v) in polymer
        freq[k[1]] += v
    end
    freq[template[end]] += 1
    return freq
end

function result((template, insertions), n)
    polymer = init_polymer(template, insertions)

    for _ in 1:n
        polymer = next(polymer, insertions)
    end

    freq = get_freq(polymer, template, insertions)

    max_o = maximum(values(freq))
    min_o = minimum(values(freq))

    return max_o - min_o
end
