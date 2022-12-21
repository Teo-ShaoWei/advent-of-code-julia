export print_matrix

import Chain

const DEFAULT_MAP_LEGEND = [
    (
        pred = x -> Int(x) == 0,
        char = '·',
    ),
    (
        pred = x -> Int(x) == 1,
        char = '░',
    ),
    (
        pred = x -> Int(x) == 2,
        char = 'x',
    ),
    (
        pred = x -> Int(x) == 3,
        char = '#',
    ),
]

"""
The following function works. `@. Int` is use so `area` can a `BitMatrix` or (0, 1)-matrix, etc.
"""
function print_matrix(area::AbstractMatrix; map_legend = DEFAULT_MAP_LEGEND)
    print_matrix(identity, area; map_legend)
end

function print_matrix(
        transform_func,
        area::AbstractMatrix,
        ;
        map_legend = DEFAULT_MAP_LEGEND,
    )

    function map_area_point(area)
        return map(area) do x
            for (pred, char) in map_legend
                pred(x) && (return char)
            end

            throw(error("Area element cannot be processed!"))
        end
    end

    println("size: ", join(size(area), " × "))
    println("axes: (", join(UnitRange.(axes(area)), ", "), ")")

    for row in eachrow(transform_func(area))
        Chain.@chain row begin
            map_area_point
            join
            println
        end
    end

    println()
end
