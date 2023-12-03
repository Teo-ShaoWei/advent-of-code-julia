using Chain


## Helpers

import AdventOfCode:
    CI, CIS,
    make_smallest_boundary,
    parse_matrix


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
        parse_matrix(; elem_dlm = "")
        @. only
    end
end


## Part 1

function is_part(item::Char)
    !isdigit(item) && (item != '.')
end

function find_parts(area)::Vector{@NamedTuple{ci::CI{2}, item::Char}}
    [(; ci, item = area[ci]) for ci in CIS(area) if is_part(area[ci])]
end

function parse_number(cis::Vector{CI{2}}, area)
    @chain cis begin
        area[_]
        join
        parse(Int, _)
    end
end

function find_numbers(area)::Vector{@NamedTuple{cis::Vector{CI{2}}, value::Int}}
    numbers = @NamedTuple{cis::Vector{CI{2}}, value::Int}[]
    for i in axes(area, 1)
        start_j = 0
        is_processing_number = false
        for j in axes(area, 2)
            if !is_processing_number && isdigit(area[i, j])
                start_j = j
                is_processing_number = true
            elseif is_processing_number && !isdigit(area[i, j])
                cis = CIS((i:i, start_j:(j - 1)))[:]
                push!(
                    numbers,
                    (; cis, value = parse_number(cis, area))
                )
                is_processing_number = false
            end
        end
        if is_processing_number
            cis = CIS((i:i, start_j:size(area, 2)))[:]
            push!(
                numbers,
                (; cis, value = parse_number(cis, area))
            )
            is_processing_number = false
        end
    end
    return numbers
end

function is_adjacent_to_parts(numbers, parts)::Vector{@NamedTuple{cis::Vector{CI{2}}, value::Int}}
    result = @NamedTuple{cis::Vector{CI{2}}, value::Int}[]
    for (cis, value) in numbers
        boundary = CIS(make_smallest_boundary(cis; margin = (1, 1)))
        any(part.ci ∈ boundary for part in parts) && push!(result, (; cis, value))
    end
    return result
end

function result1(area)
    numbers = is_adjacent_to_parts(
        find_numbers(area),
        find_parts(area)
    )
    @chain area begin
        is_adjacent_to_parts(find_numbers(_), find_parts(_))
        [n.value for n in _]
        sum
    end

end


## Part 2

function find_gears(area)::Vector{@NamedTuple{ci::CI{2}, item::Char}}
    [(; ci, item = area[ci]) for ci in CIS(area) if area[ci] == '*']
end

function filter_neighbouring_numbers_to_gears(numbers, gears)
    map(gears) do (; ci,)
        boundary = CIS(make_smallest_boundary([ci]; margin = (1, 1)))
        [n for n in numbers if !isempty(n.cis ∩ boundary)]
    end
end

function compute_gear_ratio(numbers)
    length(numbers) == 2 || return 0
    return prod(value for (; value) in numbers)
end

function result2(area)
    @chain area begin
        filter_neighbouring_numbers_to_gears(find_numbers(_), find_gears(_))
        @. compute_gear_ratio
        sum
    end
end
