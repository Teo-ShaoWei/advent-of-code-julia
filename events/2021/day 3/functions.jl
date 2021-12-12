using Chain


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readlines
        @. parse_line
    end
end

function parse_line(line)
    @chain line begin
        split("")
        parse.(Int, _)
    end
end


## Part 1

function most_common(v)
    count0 = count(==(0), v)
    count1 = count(==(1), v)

    count0 > count1 ? 0 : 1
end

function least_common(v)
    count0 = count(==(0), v)
    count1 = count(==(1), v)

    count0 > count1 ? 1 : 0
end

function binary2int(v)
    @chain v begin
        @. string
        join
        parse(Int, _, base=2)
    end
end

function gamma_rate(numbers)
    result = map(eachindex(numbers[1])) do i
        most_common(n[i] for n in numbers)
    end

    binary2int(result)
end

function epsilon_rate(numbers)
    result = map(eachindex(numbers[1])) do i
        least_common(n[i] for n in numbers)
    end

    binary2int(result)
end

function result1(report)
    gamma_rate(report) * epsilon_rate(report)
end


## Part 2

function oxygen_generator_rating(numbers)
    leftover_numbers = deepcopy(numbers)

    for i in eachindex(leftover_numbers[1])
        x = most_common(n[i] for n in leftover_numbers)
        filter!(n -> n[i] == x, leftover_numbers)
        (length(leftover_numbers) == 1) && break
    end

    binary2int(only(leftover_numbers))
end

function co2_scrubber_rating(numbers)
    leftover_numbers = deepcopy(numbers)

    for i in eachindex(leftover_numbers[1])
        x = least_common(n[i] for n in leftover_numbers)
        filter!(n -> n[i] == x, leftover_numbers)
        (length(leftover_numbers) == 1) && break
    end

    binary2int(only(leftover_numbers))
end

function result2(report)
    oxygen_generator_rating(report) * co2_scrubber_rating(report)
end
