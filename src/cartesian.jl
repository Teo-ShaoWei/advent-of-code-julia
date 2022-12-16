import OffsetArrays

CI = CartesianIndex
CIS = CartesianIndices

"""
Make the smallest boundary range that contains all the given cartesian indices.
Optionally includes a margin tuple to expand on the dimensions.
"""

function make_smallest_boundary(cis::Vector{CI{N}}; margin::NTuple{N, Int} = Tuple(0 for _ in 1:N)) where {N}
    ranges = map(1:N) do i
        range(
            (extrema(ci[i] for ci in cis) .+ (-margin[i], margin[i]))...
        )
    end
    return Tuple(ranges)
end
