using Chain


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
        split("\n\n")
        (seeds = parse_seeds(_[1]), rules = rule1.(_[2:end]))
    end
end

function parse_seeds(s)
    @chain s begin
        split("seeds: ")
        _[2]
        split(" ")
        parse.(Int, _)
    end
end

function rule1(s)
    @chain s begin
        split("\n")
        rule2.(_[2:end])
    end
end

function rule2(s)
    @chain s begin
        split(" ")
        parse.(Int, _)
    end
end


## Part 1

function find_dest_by_id(item, lookup)
    for (dest, src, len) in lookup
        (src ≤ item < src + len) && return item + dest - src
    end
    return item
end

function get_location_of_seed(seed, rules)
    item = seed
    for lookup in rules
        item = find_dest_by_id(item, lookup)
    end
    return item
end

function result1(pd)
    locations = [get_location_of_seed(seed, pd.rules) for seed in pd.seeds]
    return minimum(locations)
end


## Part 2

function make_seed_ranges(seeds)
    map(1:2:length(seeds)) do idx
        range(start = seeds[idx], length = seeds[idx + 1])
    end
end

function find_src_by_id(item, lookup)
    for (dest, src, len) in lookup
        (dest ≤ item < dest + len) && return item + src - dest
    end
    return item
end

function find_valid_src_upper_bound(src_item, lookup)::Union{Nothing, Int}
    min_idx = minimum(src for (_, src, _) in lookup)
    (src_item < min_idx) && return min_idx - src_item
    upper_bound_lookup = sort!([src + len for (_, src, len) in lookup])
    idx = 1 + searchsortedlast(upper_bound_lookup, src_item)
    (idx > length(upper_bound_lookup)) && return nothing
    return upper_bound_lookup[idx] - src_item
end

function get_seed_of_location_with_upper_bound(location, rules)
    upper_bounds = Int[]
    item = location
    for lookup in Iterators.reverse(rules)
        item = find_src_by_id(item, lookup)
        upper_bound = find_valid_src_upper_bound(item, lookup)
        isnothing(upper_bound) || push!(upper_bounds, upper_bound)
    end
    return (; seed = item, upper_bound = minimum(upper_bounds))
end

function result2(pd)
    location = 0
    seeds = make_seed_ranges(pd.seeds)
    for _ in 1:100
        (; seed, upper_bound) = get_seed_of_location_with_upper_bound(location, pd.rules)
        for r in seeds
            existing_seeds = r ∩ range(start = seed, length = upper_bound)
            if !isempty(existing_seeds)
                return existing_seeds.start - seed + location
            end
        end
        location += upper_bound
    end
end
