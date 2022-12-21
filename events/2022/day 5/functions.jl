import Chain: @chain


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
        _ .|> (parse_containers, parse_moves)
    end
end

function inject_quote(s)
    @chain s begin
        enumerate
        [(i % 2 == 0) ? c : '\'' for (i, c) in _]
        join
    end
end

function parse_container(v)
    [x for x in v if x != ' ']
end

function parse_containers(s)
    @chain s begin
        split("\n")
        _[1:(end - 1)]
        @. inject_quote
        ["[", _..., "]"]
        join("\n")
        Meta.parse
        eval
        rotr90
        eachrow
        @. parse_container
    end
end

function parse_moves(s)
    @chain s begin
        split("\n")
        @. parse_move
    end
end

function parse_move(l)
    @chain l begin
        match(r"move (\d+) from (\d+) to (\d+)", _)
        @. parse(Int, _)
        ((:count, :src, :tgt) .=> _)
        NamedTuple
    end
end


## Part 1

function move!(cols, (; count, src, tgt); move_container_func)
    src_new_length = length(cols[src]) - count
    containers_to_move = cols[src][(src_new_length + 1):end]
    moved_containers = move_container_func(containers_to_move)
    append!(cols[tgt], moved_containers)
    resize!(cols[src], src_new_length)
    return cols
end

function make_moves((cols, moves); move_container_func)
    cols = deepcopy(cols)
    for m in moves
        cols = move!(cols, m; move_container_func)
    end
    return cols
end

function result1(pd)
    @chain pd begin
        make_moves(; move_container_func = Iterators.reverse)
        @. last
        join
    end
end


## Part 2
function result2(pd)
    @chain pd begin
        make_moves(move_container_func = identity)
        @. last
        join
    end
end
