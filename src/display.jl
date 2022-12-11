export print_area

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
]

"""
The following function works. `@. Int` is use so `area` can a `BitMatrix` or (0, 1)-matrix, etc.
"""
function print_area(area::AbstractMatrix; map_legend = DEFAULT_MAP_LEGEND)
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

    for row in eachrow(area)
        Chain.@chain row begin
            map_area_point
            join
            println
        end
    end

    println()
end
