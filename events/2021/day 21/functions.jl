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

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))

S = Iterators.Stateful


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readlines
        @. parse_player
        Tuple
    end
end

function parse_player(line)
    @chain line begin
        match(r"Player (.+) starting position: (.+)", _)
        collect
        parse.(Int, _)
        (id = _[1], pos = _[2], score = 0)
    end
end


## Part 1

function make_dice(iter)
    S(Iterators.cycle(iter))
end

function roll_dice(dice, n)
    Iterators.take(dice, n)
end

function make_move(pos, move)
    ((pos + move - 1) % 10 ) + 1
end

function result1(players)
    dice = make_dice(1:100)
    total_rolls = 0
    while true
        move = roll_dice(dice, 3) |> sum
        total_rolls += 3
        pos = make_move(players[1].pos, move)
        score = players[1].score + pos
        players = (
            players[2],
            (; players[1].id, pos, score),
        )

        (score ≥ 1000) && break
    end

    total_rolls * players[1].score
end

function dice_results()
    Dict(
        3 => 1,
        4 => 3,
        5 => 6,
        6 => 7,
        7 => 6,
        8 => 3,
        9 => 1,
    )
end


## Part 2

function result2(players)
    limit = 21
    starting_state = (1, players[1].pos, players[2].pos, 0, 0)
    store = DefaultDict(0, starting_state => 1)
    q = DataStructures.PriorityQueue()
    q[starting_state] = starting_state[4] + starting_state[5]

    while !isempty(q)
        state = dequeue!(q)
        current_u = store[state]

        for (move, u) in dice_results()
            turn, pos1, pos2, score1, score2 = state
            if turn == 1
                pos1 = make_move(pos1, move)
                score1 += pos1
            else
                pos2 = make_move(pos2, move)
                score2 += pos2
            end
            turn = 3 - turn

            new_state = (turn, pos1, pos2, score1, score2)
            store[new_state] += current_u * u

            (score1 ≥ limit) && continue
            (score2 ≥ limit) && continue

            q[new_state] = score1 + score2
        end
    end

    u1 = sum((u for (state, u) in store if state[4] ≥ limit), init = 0)
    u2 = sum((u for (state, u) in store if state[5] ≥ limit), init = 0)

    return u1 > u2 ? u1 : u2
end
