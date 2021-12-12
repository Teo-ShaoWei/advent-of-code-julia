using Chain


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readlines
        @. parse_line
    end
end

function parse_line(line)
    @chain line begin
        split('-')
        @. string
        Pair(_...)
    end
end

function get_type_of_cave(c)
    (c == "start") && return :start
    (c == "end") && return :end
    isuppercase(c[1]) && return :big
    return :small
end

is_start_cave(c) = get_type_of_cave(c) == :start
is_end_cave(c) = get_type_of_cave(c) == :end

function path_to_string(path)
    @chain path begin
        join(',')
    end
end

## Part 1

function filter_roads_with_start(roads)
    filter(r -> any(is_start_cave, r), roads)
end

function filter_roads_with_end(roads)
    filter(r -> any(is_end_cave, r), roads)
end

function filter_roads_with_cave(cave, roads)
    filter(r -> cave ∈ r, roads)
end

function filter_inaccessible_caves(path)
    filter(path) do c
        get_type_of_cave(c) ∈ (:small, :start)
    end
end

function get_opp_cave(road, current_cave)
    (c1, c2) = road
    return c1 == current_cave ? c2 : c1
end

function find_paths(curr_path, roads)
    latest_cave = last(curr_path)
    is_end_cave(latest_cave) && return [curr_path]

    paths = []
    inaccessible = filter_inaccessible_caves(curr_path)

    next_caves = @chain latest_cave begin
        filter_roads_with_cave(roads)
        get_opp_cave.(_, latest_cave)
        setdiff(_, inaccessible)
    end

    for c in next_caves
        next_path = [curr_path; c]
        append!(
            paths,
            find_paths(next_path, roads),
        )
    end
    return paths
end

function result1(roads)
    paths = find_paths(["start"], roads)
    return length(paths)
end


## Part 2

function can_revisit_small_caves(path)
    small_caves_in_path = filter(c -> get_type_of_cave(c) == :small, path) |> unique

    for cave in small_caves_in_path
        visited_count = count(==(cave), path)
        if visited_count > 1
            return false
        end
    end

    return true
end

function find_longer_paths(curr_path, roads)
    latest_cave = last(curr_path)
    is_end_cave(latest_cave) && return [curr_path]

    paths = []

    if can_revisit_small_caves(curr_path)
        inaccessible = ["start"]
    else
        inaccessible = filter_inaccessible_caves(curr_path)
    end

    next_caves = @chain latest_cave begin
        filter_roads_with_cave(roads)
        get_opp_cave.(_, latest_cave)
        setdiff(_, inaccessible)
    end

    for c in next_caves
        next_path = [curr_path; c]
        append!(
            paths,
            find_longer_paths(next_path, roads),
        )
    end
    return paths
end

function result2(roads)
    paths = find_longer_paths(
        ["start"],
        roads,
    )

    return length(paths)
end
