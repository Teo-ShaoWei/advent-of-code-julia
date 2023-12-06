using Chain


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

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
        (drawns = parse_drawns(_[1]), boards = parse_board.(_[2:end]))
    end
end

function parse_drawns(s)
    @chain s begin
        split(',')
        parse.(Int, _)
    end
end

function parse_board(s)
    @chain s begin
        split('\n')
        @. parse_board_row
        cat(_..., dims=2)
        permutedims((2, 1))
    end
end

function parse_board_row(s)
    @chain s begin
        split(' ', keepempty = false)
        parse.(Int, _)
    end
end


## Part 1

function init_drawn_state(board)
    falses(size(board))
end

function is_row_complete(state)
    @chain eachslice(state, dims = 1) begin
        @. all
        any
    end
end

function is_col_complete(state)
    @chain eachslice(state, dims = 2) begin
        @. all
        any
    end
end

function is_complete(state)
    is_row_complete(state) || is_col_complete(state)
end

function findfirst_complete(states)
    findfirst(is_complete, states)
end

function update_drawn!(state, board, drawn)
    state[board .== drawn] .= true
    return state
end

function get_unmarked(state, board)
    board[state .== false]
end

function result1((; drawns, boards))
    states = init_drawn_state.(boards)
    for d in drawns
        update_drawn!.(states, boards, d)
        i = findfirst_complete(states)
        isnothing(i) && continue
        unmarked = get_unmarked(states[i], boards[i])
        return sum(unmarked) * d
    end
end


## Part 2

function result2((; drawns, boards))
    states = init_drawn_state.(boards)
    for d in drawns
        update_drawn!.(states, boards, d)
        incomplete_indices = (!is_complete).(states)
        leftover_boards = boards[incomplete_indices]
        leftover_states = states[incomplete_indices]

        if isempty(leftover_states)
            unmarked = get_unmarked(only(states), (only(boards)))
            return sum(unmarked) * d
        end

        boards = leftover_boards
        states = leftover_states
    end
end
