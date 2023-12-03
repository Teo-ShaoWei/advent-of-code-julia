using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

import AdventOfCode:
    AdventOfCode,
    CI, CIS,
    get_bound,
    make_smallest_boundary,
    parse_matrix,
    print_matrix


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
        string
    end
end


## Part 1

function result1(pd)
    @chain pd begin
        _
    end
end


## Part 2

function result2(pd)
    @chain pd begin
        _
    end
end
