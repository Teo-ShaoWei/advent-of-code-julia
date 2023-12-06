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
        cat(_..., dims=2)
        permutedims((2, 1))
    end
end

function parse_line(line)
    @chain line begin
        split("")
        parse.(Int, _)
    end
end


## Part 1

function increase_energy(state)
    (; otps = state.otps .+ 1, state.num_flash)
end

function neighbour_offsets()
    CI.([
        (-1, -1),
        (-1, 0),
        (-1, 1),
        (0, -1),
        (0, 1),
        (1, -1),
        (1, 0),
        (1, 1),
    ])
end

function get_neighbours(otps, i::CI)
    neighbours = Ref(i) .+ neighbour_offsets()
    return neighbours ∩ CIS(otps)
end

function is_done(state)
    all(≤(9), state.otps)
end

function flash((otps, num_flash))
    for i in CartesianIndices(otps)
        (otps[i] ≤ 9) && continue
        num_flash += 1
        nbs = get_neighbours(otps, i)
        nbs = filter(nb -> otps[nb] > 0, nbs)
        otps[nbs] .+= 1
        otps[i] = 0
    end
    return (; otps, num_flash)
end

function next(state)
    state = increase_energy(state)
    while !is_done(state)
        state = flash(state)
    end
    return state
end

function result1(otps, n)
    state = (; otps, num_flash = 0)
    for _ in 1:n
        state = next(state)
    end
    return state.num_flash
end


## Part 2

function is_sync(state)
    all(==(0), state.otps)
end

function result2(otps)
    state = (; otps, num_flash = 0)
    i = 0
    while !is_sync(state)
        state = next(state)
        i += 1
    end

    return i
end
