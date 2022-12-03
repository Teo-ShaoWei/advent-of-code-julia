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
        split("\n")
        @. parse_puzzle_line
    end
end

function parse_puzzle_line(s)
    @chain s begin
        split(" ")
        @. only
    end
end


## Part 1

function get_round(l)
    (them = l[1], me = l[2])
end

function get_choice_point(play)
    return SHAPE_INDEX[play]
end

function get_win_point(their_play, my_play)
    their_index = SHAPE_INDEX[their_play]
    my_index = SHAPE_INDEX[my_play]

    return 3 * mod(my_index - their_index + 1, 3)
end

function get_point(round)
    their_play = SHAPE_CHOICE[round[1]]
    my_play = SHAPE_CHOICE[round[2]]

    return get_win_point(their_play, my_play) + get_choice_point(my_play)
end

function result1(pd)
    @chain pd begin
        @. get_point
        sum
    end
end

## Part 2

function get_new_win_point(result)
    3 * (SHAPE_INDEX[result] - 1)
end

function get_new_choice_point(their_play, result)
    their_index = SHAPE_INDEX[their_play]
    result = RESULT_INDEX[result]
    mod(their_index  + result - 1, 3) + 1
end

function get_new_point(round)
    their_play = SHAPE_CHOICE[round[1]]
    result = SHAPE_CHOICE[round[2]]

    return get_new_choice_point(their_play, result) + get_new_win_point(result)
end

function result2(pd)
    @chain pd begin
        @. get_new_point
        sum
    end
end
