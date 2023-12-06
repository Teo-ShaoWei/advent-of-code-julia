using Chain
using Combinatorics
using DataStructures
using OffsetArrays
using Mods


## Helpers

⋆(f::Base.Callable) = Base.splat(f)

CI = CartesianIndex
CIS = CartesianIndices


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readlines
        @. parse_line
    end
end

function parse_line(l)
    @chain l begin
        split(_, "")
        @. only
    end
end


## Part 1

function get_status(line)
    s = Stack{Char}()
    for (i, c) in enumerate(line)
        if c ∈ keys(MATCHING_CHARS)
            push!(s, c)
        else
            prev_c = pop!(s)
            (MATCHING_CHARS[prev_c] == c) && continue
            return (; is_corrupted=true, c, i)
        end
    end

    return (; is_corrupted=false, s)
end

function compute_corrupt_point(result)
    CORRUPT_POINTS[result.c]
end

function result1(pd)
    @chain pd begin
        @. get_status
        filter(s -> s.is_corrupted, _)
        map(s -> CORRUPT_POINTS[s.c], _)
        sum
    end
end


## Part 2

function filter_incomplete(ip)
    ip = [cs for cs in ip if !find_illegal(cs).found]
end

function completion_score(s::Stack)
    score = 0
    for c in s
        score *= 5
        score += INCOMPLETE_POINTS[c]
    end
    return score
end

function result2(pd)
    @chain pd begin
        @. get_status
        filter(s -> !s.is_corrupted, _)
        map(status -> status.s, _)
        @. completion_score
        sort!
        _[(length(_) + 1) ÷ 2]
    end
end
