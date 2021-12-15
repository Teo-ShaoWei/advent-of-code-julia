using Chain
using DataStructures


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readlines
        @. parse_line
        cat(_..., dims=2)
        permutedims((2, 1))
    end
end

function parse_line(line)
    @chain line begin
        split("")
        parse.(Int, _)
    end
end


## Part 1

function valid_coor(c::CI, area)
    all(Tuple(c) .∈ axes(area))
end

function get_neighbours(c::CI, area)
    offsets = CI.([
        CI(-1, 0),
        CI(1, 0),
        CI(0, -1),
        CI(0, 1),
    ])
    neighbours = Ref(c) .+ offsets
    return filter(c -> valid_coor(c, area), neighbours)
end

function update_next_locs!(total_risks, seen_locs, q, loc, risks)
    next_locs = @chain loc begin
        get_neighbours(seen_locs)
        filter!(c -> !(seen_locs[c]), _)
    end

    total_risks[next_locs] .= total_risks[loc] .+ risks[next_locs]
    seen_locs[next_locs] .= true
    enqueue!.(Ref(q), next_locs, total_risks[next_locs])
end


function result1(risks)
    start_loc = CI(1, 1)
    final_loc = CI(size(risks)...)
    total_risks = map(_ -> 0, risks)
    seen_locs = map(==(CI(1, 1)), CartesianIndices(risks))
    q = PriorityQueue()
    q[start_loc] = 0

    while !isempty(q)
        loc = dequeue!(q)
        loc == final_loc && return total_risks[final_loc]
        update_next_locs!(total_risks, seen_locs, q, loc, risks)
    end
end

## Part 2

function make_map(risks, i, j)
    (risks .+ i .+ j .- 1) .% 9 .+ 1
end

function make_map(risks, i)
    cat((make_map(risks, i, j) for j in 0:4)..., dims = 2)
end

function make_map(risks)
    cat((make_map(risks, i) for i in 0:4)..., dims = 1)
end

function result2(risks)
    @chain risks begin
        make_map
        result1
    end
end
