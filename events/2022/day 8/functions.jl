import Chain: @chain


## Helpers

import AdventOfCode: CI, CIS, parse_matrix

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)


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
        parse_matrix(; row_dlm = "\n", elem_dlm = "")
        parse.(Int, _)
    end
end


## Part 1

function count_seeable_trees(trees)
    can_see_tree.((trees,), CIS(trees))
end

function trees_towards_l(trees, ci::CI)
    [trees[ci[1], k] for k in (ci[2] - 1):-1:1]
end

function trees_towards_r(trees, ci::CI)
    [trees[ci[1], k] for k in (ci[2] + 1):size(trees, 2)]
end

function trees_towards_t(trees, ci::CI)
    [trees[k, ci[2]] for k in (ci[1] - 1):-1:1]
end

function trees_towards_b(trees, ci::CI)
    [trees[k, ci[2]] for k in (ci[1] + 1):size(trees, 1)]
end

function can_see_tree(trees, ci::CI)
    all(trees_towards_l(trees, ci) .< trees[ci]) && return true
    all(trees_towards_r(trees, ci) .< trees[ci]) && return true
    all(trees_towards_t(trees, ci) .< trees[ci]) && return true
    all(trees_towards_b(trees, ci) .< trees[ci]) && return true
    return false
end

function derive_seeable_trees(trees)
    can_see_tree.((trees,), CIS(trees))
end

function result1(trees)
    @chain trees begin
        derive_seeable_trees
        count
    end
end


## Part 2

function scenic_view(tree, line)
    tree_count = findfirst(t -> t ≥ tree, line)
    isnothing(tree_count) ? length(line) : tree_count
end

function scenic_view(trees, ci::CI)
    return (
        l_view = scenic_view(trees[ci], trees_towards_l(trees, ci)),
        r_view = scenic_view(trees[ci], trees_towards_r(trees, ci)),
        t_view = scenic_view(trees[ci], trees_towards_t(trees, ci)),
        b_view = scenic_view(trees[ci], trees_towards_b(trees, ci)),
    )
end

function scenic_score(view)
    return prod(view)
end

function result2(trees)
    @chain scenic_view.((trees,), CIS(trees)) begin
        @. scenic_score
        maximum
    end
end
