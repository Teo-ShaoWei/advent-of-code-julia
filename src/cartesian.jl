import OffsetArrays

CI = CartesianIndex
CIS = CartesianIndices

"""
Get the bound of a rectangular CIS.
"""
function get_bound(cis::CIS{N})::NTuple{N, UnitRange{Int}} where {N}
    Tuple(range(i1, i2) for (i1, i2) in zip(Tuple(cis[1]), Tuple(cis[end])))
end

"""
Get the bound of a vector of CIs.
"""
function get_bound(cis::Vector{CI{N}})::NTuple{N, UnitRange{Int}} where {N}
    Tuple(range(extrema(ci[i] for ci in cis)...) for i in 1:N)
end

"""
Make the smallest boundary range that contains all the given cartesian indices.
Optionally includes a margin tuple to expand on the dimensions.
"""
function make_smallest_boundary(
        cis::Union{CIS{N}, Vector{CI{N}}},
        ;
        margin::NTuple{N, Int} = Tuple(0 for _ in 1:N),
        bound::Union{Nothing, CIS{N}} = nothing,
    )::NTuple{N, UnitRange{Int}} where {N}

    ranges = map(1:N) do i
        range(
            (extrema(ci[i] for ci in cis) .+ (-margin[i], margin[i]))...
        )
    end |> Tuple

    isnothing(bound) && return ranges
    return ranges .∩ get_bound(bound)
end
