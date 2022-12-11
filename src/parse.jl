export parse_matrix

import Chain

"""
This function deliberately use `permutedims` so that it can easily expand into higher dimension arrays.
"""
function parse_matrix(s::AbstractString; row_dlm = "\n", elem_dlm = " ")::Matrix{String}
    Chain.@chain s begin
        split(row_dlm)
        parse_row.(_; elem_dlm)
        cat(_..., dims = 2)
        permutedims((2, 1))
    end
end

function parse_row(s::AbstractString; elem_dlm = " ")::Vector{String}
    Chain.@chain s begin
        split(elem_dlm)
        @. string
    end
end
