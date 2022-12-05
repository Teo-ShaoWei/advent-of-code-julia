using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


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
        split.("\n")
        parse_containers(_[1]), parse_moves(_[2])
    end
end

function get_col_count(l)
    (length(l) + 2) ÷ 4
end

function get_col_index(i)
    4 * i - 2
end

function parse_containers(lines)
    footer, content = Iterators.peel(Iterators.reverse(lines))
    col_count = get_col_count(footer)
    containers = [Char[] for _ in 1:col_count]
    for l in content
        for cj in 1:col_count
            j = get_col_index(cj)
            (j > length(l)) && break
            c = l[j]
            (c == ' ') && continue
            push!(containers[cj], c)
        end
    end
    return containers
end

function parse_moves(s)
    @chain s begin
        @. parse_move
    end
end

function parse_move(l)
    @chain l begin
        match(r"move (\d+) from (\d+) to (\d+)", _)
        @. parse(Int, _)
    end
end

## Part 1

function move_slow(cols, move)
    cols = copy(cols)
    (count, src, tgt) = move

    src_new_length = length(cols[src]) - count
    containers_to_move = cols[src][(src_new_length + 1):end]
    moved_containers = Iterators.reverse(containers_to_move)
    cols[tgt] = [cols[tgt]; collect(moved_containers)]
    cols[src] = cols[src][1:src_new_length]
    return cols
end

function make_moves((cols, moves), move_func)
    for m in moves
        cols = move_func(cols, m)
    end
    return cols
end

function result1(pd)
    @chain pd begin
        make_moves(move_slow)
        [v[end] for v in _]
        join
    end
end


## Part 2

function move_fast(cols, move)
    cols = copy(cols)
    (count, src, tgt) = move

    src_new_length = length(cols[src]) - count
    containers_to_move = cols[src][(src_new_length + 1):end]
    moved_containers = containers_to_move
    cols[tgt] = [cols[tgt]; collect(moved_containers)]
    cols[src] = cols[src][1:src_new_length]
    return cols
end

function result2(pd)
    @chain pd begin
        make_moves(move_fast)
        [v[end] for v in _]
        join
    end
end
