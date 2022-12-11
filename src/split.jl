"""
Split a vector based on given collection of indices.
The `splitter` can be handled differently:
- `:next` -- It is kept as the first element in the next vector after split.
- `:prev` -- It is kept as the last element in the previous vector after split.
- `:skip` -- It is discarded.
The default behaviour is `:next`.

E.g.
split(collect(1:10), 2, 10)
split(collect(1:10), 2, 10; splitter = :prev)
split(collect(1:10), 2, 10; splitter = :skip)
"""
function Base.split(v::AbstractVector, indices::Int...; splitter = :next)
    is = (0, indices..., length(v) + 1)
    return map(2:length(is)) do k
        range = if splitter == :next
            is[k - 1]:(is[k] - 1)
        elseif splitter == :prev
            (is[k - 1] + 1):is[k]
        elseif splitter == :skip
            (is[k - 1] + 1):(is[k] - 1)
        else
            throw(error("`splitter` is not valid! Only `:next`, `:prev` or `:skip`."))
        end

        v[range ∩ axes(v, 1)]
    end
end


"""
Split a vector into 3 parts, by extracting the full range as the middle.

E.g.
split(collect(1:10), 3:5)
"""
function Base.split(v::AbstractVector, r::AbstractUnitRange)
    return Base.split(v, first(r), last(r) + 1; splitter = :next)
end


"""
Split a vector where the splitters satisfy the predicate.
The `splitter` can be handled differently:
- `:next` -- It is kept as the first element in the next vector after split.
- `:prev` -- It is kept as the last element in the previous vector after split.
- `:skip` -- It is discarded.
The default behaviour is `:next`.

E.g.
split(==("haha"), ["ok", "haha", "sure"])
split(==("haha"), ["ok", "haha", "sure"]; splitter = :prev)
split(==("haha"), ["ok", "haha", "sure"]; splitter = :skip)
"""
function Base.split(pred, v::AbstractVector; splitter = :next)
    triggered_indices = (i for i in 1:length(v) if pred(v[i]))
    return Base.split(v, triggered_indices...; splitter)
end
