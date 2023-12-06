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
        split("\n")
        @. parse_puzzle_line
        cat(_..., dims = 2)
        permutedims((2, 1))
    end
end

function parse_puzzle_line(s)
    @chain s begin
        split("")
        parse.(Bool, _)
    end
end


## Part 1

function get_most_common(v)
    count0 = count(==(0), v)
    count1 = count(==(1), v)

    count0 > count1 ? 0 : 1
end

function get_least_common(v)
    count0 = count(==(0), v)
    count1 = count(==(1), v)

    count0 > count1 ? 1 : 0
end

function binary2int(v)
    @chain v begin
        @. Int
        join
        parse(Int, _, base = 2)
    end
end

function gamma_rate(numbers)
    @chain numbers begin
        eachslice(dims = 2)
        @. get_most_common
        binary2int
    end
end

function epsilon_rate(numbers)
    @chain numbers begin
        eachslice(dims = 2)
        @. get_least_common
        binary2int
    end
end

function result1(report)
    gamma_rate(report) * epsilon_rate(report)
end


## Part 2

function filter_most_common_iteratively(numbers)
    i_inds = 1:size(numbers, 1)

    for j in 1:size(numbers, 2)
        x = numbers[i_inds, j] |> get_most_common
        i_inds = filter(i -> numbers[i, j] == x, i_inds)
        (length(i_inds) == 1) && break
    end

    return numbers[only(i_inds), :]
end

function filter_least_common_iteratively(numbers)
    i_inds = 1:size(numbers, 1)

    for j in 1:size(numbers, 2)
        x = numbers[i_inds, j] |> get_least_common
        i_inds = filter(i -> numbers[i, j] == x, i_inds)
        (length(i_inds) == 1) && break
    end

    return numbers[only(i_inds), :]
end

function oxygen_generator_rating(numbers)
    @chain numbers begin
        filter_most_common_iteratively
        binary2int
    end
end

function co2_scrubber_rating(numbers)
    @chain numbers begin
        filter_least_common_iteratively
        binary2int
    end
end

function result2(report)
    oxygen_generator_rating(report) * co2_scrubber_rating(report)
end
