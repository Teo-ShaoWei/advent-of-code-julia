using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

Base.show(io::IO, v::Vector) = print(io, "[", join(v, ", "), "]")


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
        split("\n")
        @. parse_puzzle_line
        OrderedDict
    end
end

function parse_puzzle_line(s)
    @chain s begin
        match(r"Valve (.+) has flow rate=(.+); tunnels? leads? to valves? (.+)", _)
        collect
        string(_[1]) => (; rate = parse(Int, _[2]), neighbours = parse_neighbours(_[3]))
    end
end

function parse_neighbours(s)
    @chain s begin
        split(", ")
        @. string
        collect
    end
end


## Part 1

function filter_useful_valves(valves)
    Dict(id => rule for (id, rule) in valves if rule.rate > 0)
end

function make_timing_map(src_id, valves)
    timing_map = Dict(n => 1 for n in valves[src_id].neighbours)
    pq = PriorityQueue(timing_map)

    while !isempty(pq)
        (id, tt) = dequeue_pair!(pq)
        for n in valves[id].neighbours
            haskey(timing_map, n) && continue
            timing_map[n] = tt + 1
            pq[n] = tt + 1
        end
    end

    return Dict((src_id => id) => tt for (id, tt) in timing_map)
end

function make_timing_map(valves)
    timing_map = Dict{Pair{String, String}, Int}()

    for (id, _) in valves
        merge!(timing_map, make_timing_map(id, valves))
    end

    return timing_map
end

function extract_timing_map_between_useful_valves(tunnel_map, useful_valves)
    useful_valve_ids = [id for (id, _) in useful_valves]
    return Dict(
        (id1 => id2) => tt
        for ((id1, id2), tt) in tunnel_map
        if id1 ∈ useful_valve_ids && id2 ∈ useful_valve_ids && id1 != id2
    )
end

function get_timing_of_useful_move(tunnel_map, (src_value, tgt_value))
    return tunnel_map[src_value => tgt_value] + 1
end

function contributed_flow(rate, t; time_limit)
    time_left = time_limit - t
    return rate * time_left
end

function derive_first_steps(timing_map, valves; time_limit)
    Dict(
        [id2] => (
            timing = timing + 1,
            flow = contributed_flow(valves[id2].rate, timing + 1; time_limit),
        )
        for ((id1, id2), timing) in timing_map
        if id1 == "AA" && id2 ∈ keys(valves)
    )
end

function build_flow_model(
        valves,
        ;
        time_limit,
        useful_valves = filter_useful_valves(valves),
    )

    timing_lookup = make_timing_map(valves)
    seen = derive_first_steps(timing_lookup, useful_valves; time_limit)
    queue = Queue{Vector{String}}()
    for (path, _) in seen
        enqueue!(queue, path)
    end

    useful_timing_lookup = extract_timing_map_between_useful_valves(timing_lookup, useful_valves)
    useful_valve_ids = [id for (id, _) in useful_valves]

    while !isempty(queue)
        (path) = dequeue!(queue)
        (; timing, flow) = seen[path]
        id = path[end]

        for n in setdiff(useful_valve_ids, path)
            new_path = [path; n]
            new_timing = timing + get_timing_of_useful_move(useful_timing_lookup, id => n)
            (new_timing > time_limit) && continue
            new_flow = flow + contributed_flow(valves[n].rate, new_timing; time_limit)

            seen[new_path] = (timing = new_timing, flow = new_flow)
            enqueue!(queue, new_path)
        end
    end

    return seen
end

function result1(valves)
    seen = build_flow_model(valves; time_limit = 30)
    maximum(flow for (_, (; flow)) in seen)
end


## Part 2

function bucket_useful_value_ids(useful_valves)
    @chain useful_valves begin
        keys
        collect
        Combinatorics.partitions(2)
        map.(Set, _)
    end
end

function build_best_flow_lookup(seen_rates)
    best_paths = Dict()

    for (path, (; flow)) in seen_rates
        path_set = Set(path)
        old_flow = get(best_paths, path_set, 0)
        (flow <= old_flow) && continue
        best_paths[path_set] = flow
    end

    return best_paths
end

function build_new_flow_model(valves; time_limit)
    useful_valves = filter_useful_valves(valves)
    best_flow_lookup = @chain valves begin
        build_flow_model(; time_limit, useful_valves)
        build_best_flow_lookup
        collect
        map(x -> NamedTuple((:id, :flow) .=> collect(x)), _)
        sort!(_; by = x -> x.flow, rev = true)
    end

    max_flow = 0
    for (ids1, flow1) in best_flow_lookup
        for (ids2, flow2) in best_flow_lookup
            isempty(ids1 ∩ ids2) || continue
            flow = flow1 + flow2
            (flow < max_flow) && break
            max_flow = flow
        end
    end
    return max_flow
end

function result2(valves)
    build_new_flow_model(valves; time_limit = 26)
end
