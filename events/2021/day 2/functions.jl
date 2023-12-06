using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


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
        split("\n")
        @. parse_puzzle_line
    end
end

function parse_puzzle_line(s)
    @chain s begin
        split(' ')
        (d = _[1], m = parse(Int, _[2]))
    end
end


## Part 1

function get_move(command)
    direction = Dict(
        "forward" => CI(0, 1),
        "down" => CI(1, 0),
        "up" => CI(-1, 0),
    )

    return command.m * direction[command.d]
end

function result1(commands)
    @chain commands begin
        @. get_move
        sum
        _[1] * _[2]
    end
end


## Part 2

function get_move_with_aim(command, aim)
    direcion_with_aim = Dict(
        "forward" => CI(0, 1),
        "down" => CI(1, 0),
        "up" => CI(-1, 0),
    )

    if command.d == "down"
        aim += command.m
        move = CI(0, 0)
    elseif command.d == "up"
        aim -= command.m
        move = CI(0, 0)
    else  # command.d == "forward"
        move = CI(aim * command.m, command.m)
    end

    return (; move, aim)
end

function result2(commands)
    aim = 0
    pos = CI(0, 0)
    for command in commands
        (; move, aim) = get_move_with_aim(command, aim)
        pos += move
    end

    return pos[1] * pos[2]
end
