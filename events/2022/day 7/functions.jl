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
        split("\$ "; keepempty = false)
        @. parse_command
    end
end

function parse_command(s)
    @chain s begin
        split("\n"; keepempty = false)
    end
end


## Part 1

function add_file_size!(sizes, current_dir, v)
    for i in 0:length(current_dir)
        dir = current_dir[1:i]
        sizes[dir] += v
    end
end

function calculate_folder_sizes(pd)
    sizes = DefaultDict(0)
    current_dir = []
    for (command, names...) in pd
        op = command[1:2]
        dir = command[4:end]
        if op == "cd"
            if dir == "/"
                empty!(current_dir)
            elseif dir == ".."
                pop!(current_dir)
            else
                push!(current_dir, dir)
            end
        elseif op == "ls"
            for (n1, _) in split.(names, " ")
                (n1 == "dir") && continue
                add_file_size!(sizes, current_dir, parse(Int, n1))
            end
        end
    end
    return sizes
end

function result1(pd)
    @chain pd begin
        calculate_folder_sizes
        values
        collect
        filter(≤(100000), _)
        # [v for v in _ if v ≤ 100000]
        sum
    end
end


## Part 2

function result2(pd)
    sizes = calculate_folder_sizes(pd)
    space_to_free = sizes[[]] - 40000000

    @chain sizes begin
        values
        collect
        filter(≥(space_to_free), _)
        sort!
        first
    end
end
