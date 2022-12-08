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
        parse_matrix
    end
end

function parse_matrix(s::AbstractString)::Matrix
    @chain s begin
        split("\n")
        @. parse_row
        cat(_..., dims = 2)
        permutedims((2, 1))
    end
end

function parse_row(s::AbstractString)::Vector
    @chain s begin
        split("")
        parse.(Int, _)
    end
end


## Part 1

function trees_towards_l(trees, i, j)
    [trees[i, k] for k in (j - 1):-1:1]
end

function trees_towards_r(trees, i, j)
    [trees[i, k] for k in (j + 1):size(trees, 2)]
end

function trees_towards_t(trees, i, j)
    [trees[k, j] for k in (i - 1):-1:1]
end

function trees_towards_b(trees, i, j)
    [trees[k, j] for k in (i + 1):size(trees, 1)]
end

function can_see_tree(trees, i, j)
    all(trees_towards_l(trees, i, j) .< trees[i, j]) && return true
    all(trees_towards_r(trees, i, j) .< trees[i, j]) && return true
    all(trees_towards_t(trees, i, j) .< trees[i, j]) && return true
    all(trees_towards_b(trees, i, j) .< trees[i, j]) && return true
    return false
end

function seeable_trees(trees)
    seen = Set{CI}()

    for I in CIS(trees)
        (i, j) = Tuple(I)
        can_see_tree(trees, i, j) && push!(seen, I)
    end
    return seen
end

function result1(trees)
    @chain trees begin
        seeable_trees
        length
    end
end


## Part 2

function scenic_view(tree, line)
    for (k, t) in Iterators.enumerate(line)
        if t ≥ tree
            return k
        end
    end
    return length(line)
end

function scenic_view(trees, i, j)
    return (
        l_view = scenic_view(trees[i, j], trees_towards_l(trees, i, j)),
        r_view = scenic_view(trees[i, j], trees_towards_r(trees, i, j)),
        t_view = scenic_view(trees[i, j], trees_towards_t(trees, i, j)),
        b_view = scenic_view(trees[i, j], trees_towards_b(trees, i, j)),
    )
end

function scenic_score(view)
    return prod(view)
end

function result2(trees)
    @chain trees begin
        CIS
        @. Tuple
        Iterators.map(I -> scenic_view(trees, I...), _)
        @. scenic_score
        maximum
    end
end
