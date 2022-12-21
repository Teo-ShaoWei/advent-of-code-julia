import Chain: @chain
import DataStructures: DefaultDict


# Types

abstract type Content end

struct File <: Content
    name::String
    size::Int
end

struct Folder <: Content
    name::String
end

abstract type Op end

struct Cd <: Op
    dir::String
end

struct Ls <: Op
    contents::Vector{Content}
end


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
    command = split(s, "\n"; keepempty = false)
    return if command[1] == "ls"
        Ls(parse_content.(command[2:end]))
    else
        Cd(split(command[1], " ")[2])
    end
end

function parse_content(s)
    content = split(s, " ")
    return if content[1] == "dir"
        Folder(content[2])
    else
        File(content[2], parse(Int, content[1]))
    end
end


## Part 1

function calculate_folders_file_size(ops::Vector{Op})
    folders_file_size = Dict{String, Int}()
    current_dir = String[]
    for op in ops
        exec!(op; folders_file_size, current_dir)
    end
    return folders_file_size
end

function exec!(op::Cd; folders_file_size, current_dir::Vector{String})
    if op.dir == ".."
        resize!(current_dir, length(current_dir) - 1)
    elseif op.dir == "/"
        return
    else
        push!(current_dir, op.dir)
    end
    return
end

function exec!(op::Ls; folders_file_size, current_dir::Vector{String})
    folders_file_size[join(current_dir, "/")] = sum(c.size for c in op.contents if isa(c, File); init = 0)
end

function calculate_folders_recursive_size(folders_file_size)
    folders_recursive_size = DefaultDict{String, Int}(0)
    for parent_path in keys(folders_file_size)
        for (path, size) in folders_file_size
            startswith(path, parent_path) || continue
            folders_recursive_size[parent_path] += size
        end
    end
    return folders_recursive_size
end

function result1(ops)
    @chain ops begin
        calculate_folders_file_size
        calculate_folders_recursive_size
        values
        [size for size in _ if size ≤ 100000]
        sum
    end
end


## Part 2

function result2(ops)
    @chain ops begin
        calculate_folders_file_size
        calculate_folders_recursive_size
        @aside space_to_free = _[""] - 40000000
        values
        [size for size in _ if size ≥ space_to_free]
        sort!
        first
    end
end
