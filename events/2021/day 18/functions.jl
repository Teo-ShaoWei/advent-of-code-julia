using Chain
using Combinatorics


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function Base.show(io::IO, ::MIME"text/plain", v::Vector{Union{Int, Vector}})
    print(io, "[")
    print(io, join(string.(v), ", "))
    print(io, "]")
end

function Base.show(io::IO, v::Vector{Union{Int, Vector}})
    show(io, "text/plain", v)
end

function Base.display(io::IO, v::Vector{Union{Int, Vector}})
    show(io, v)
end

function parse_input(filename::String)
    @chain filename begin
        readlines
        @. parse_line
    end
end

function parse_line(line)
    @chain line begin
        replace('[' => "Union{Int, Vector}[")
        Meta.parse
        eval
    end
end

macro ex_str(s)
    parse_line(s)
end


## Part 1

function to_nested_indices_form(v, ni = Int[])
    result = Pair{Vector{Int}, Int}[]

    for (i, x) in enumerate(v)
        next_ni = [ni; i]

        if isa(x, Vector)
            append!(result, to_nested_indices_form(x, next_ni))
        else
            push!(result, next_ni => x)
        end
    end

    return result
end

function is_within(child_ni, parent_ni)
    (length(child_ni) < length(parent_ni)) && return false
    return child_ni[1:length(parent_ni)] == parent_ni
end

function to_nested_vector_form(nis, ni = Int[])
    result = []

    ni1 = [ni; 1]
    ni2 = [ni; 2]

    descendants1 = filter(((ni, _),) -> is_within(ni, ni1), nis)
    descendants2 = filter(((ni, _),) -> is_within(ni, ni2), nis)

    return Union{Int, Vector}[
        length(descendants1) == 1 ? only(descendants1)[2] : to_nested_vector_form(descendants1, ni1),
        length(descendants2) == 1 ? only(descendants2)[2] : to_nested_vector_form(descendants2, ni2),
    ]
end

macro ni_str(s::String)
    @chain s begin
        parse_line
        to_nested_indices_form
    end
end

function add_value!(v, i, value)
    ni, old_value = v[i]
    v[i] = ni => (old_value + value)
    return v
end

function get_parent(ni)
    ni[1:(end - 1)]
end



function get_leaf_pair_inds(nis)
    result = []
    for (i, (ni1, _)) in enumerate(nis)
        ni1[end] == 2 && continue
        parent_ni = get_parent(ni1)
        ni2, _ = nis[i + 1]
        (ni2 != [parent_ni; 2]) && continue

        push!(result, i)
    end
    return result
end

function explode!(nis)
    for i in get_leaf_pair_inds(nis)
        ni1, x1 = nis[i]
        (length(ni1) ≤ 4) && continue
        _, x2 = nis[i + 1]

        (i > 1) && add_value!(nis, i - 1, x1)
        (i < length(nis) - 1) && add_value!(nis, i + 2, x2)

        nis[i] = get_parent(ni1) => 0
        deleteat!(nis, i + 1)
        return (true, nis)
    end

    return (false, nis)
end

function split!(nis)
    for (i, (ni, x)) in enumerate(nis)
        if x ≥ 10
            nis[i] = [ni; 1] => x ÷ 2
            insert!(nis, i + 1, [ni; 2] => (x + 1) ÷ 2)
            return (true, nis)
        end
    end
    return (false, nis)
end

function next_reduce!(nis)
    ok, _ = explode!(nis)
    ok && return (true, nis)
    ok, _ = split!(nis)
    ok && return (true, nis)
    return (false, nis)
end

function reduce!(nis)
    while true
        ok, _ = next_reduce!(nis)
        !ok && break
    end
    return nis
end

function add(nis1, nis2)
    nis1 = deepcopy(nis1)
    nis2 = deepcopy(nis2)
    for (i, (ni, v)) in enumerate(nis1)
        nis1[i] = [1; ni] => v
    end
    for (i, (ni, v)) in enumerate(nis2)
        nis2[i] = [2; ni] => v
    end
    return reduce!([nis1; nis2])
end

function add_all(niss)
    result = niss[1]
    for nis in niss[2:end]
        result = add(result, nis)
    end
    return result
end

function get_magnitude(ni, x)
    prod(i == 1 ? 3 : 2 for i in ni) * x
end

function get_magnitude(nis)
    sum(get_magnitude(ni, x) for (ni, x) in nis)
end


function result1(vs)
    @chain vs begin
        @. to_nested_indices_form
        add_all
        get_magnitude
        sum
    end
end


## Part 2

function result2(vs)
    niss = to_nested_indices_form.(vs)

    max_magnitude = 0
    for (nis1, nis2) in Combinatorics.combinations(niss, 2)
        magnitude = add(nis1, nis2) |> get_magnitude
        (magnitude > max_magnitude) && (max_magnitude = magnitude)
        magnitude = add(nis2, nis1) |> get_magnitude
        (magnitude > max_magnitude) && (max_magnitude = magnitude)
    end
    return max_magnitude
end

