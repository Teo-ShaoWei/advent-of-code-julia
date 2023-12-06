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

function parse_input(filename::String)
    @chain filename begin
        readlines
        parse_data
    end
end

macro pd_str(s)
    @chain s begin
        chomp
        split("\n")
        parse_data
    end
end

function parse_data(s)
    hallway = @chain s begin
        _[2]
        _[2:(end - 1)]
        split("")
        _[[1, 2, 4, 6, 8, 10, 11]]
        @. Tuple
        (:cl1, :cl2, :cm1, :cm2, :cm3, :cr1, :cr2) .=> _
    end

    rooms = @chain s begin
        _[3:(end - 1)]
        @. parse_line
        cat(_..., dims = 2)
        eachslice(dims = 1)
        @. Tuple
        [Symbol("r$i") for i in 1:4] .=> _
    end

    NamedTuple([rooms; hallway])
end

function parse_line(line)
    @chain line begin
        _[collect(4:2:10)]
        split("")
        @. only
    end
end

function display_state(state)
    println(join(('░' for _ in 1:13)))
    println('░', state.cl1[1], state.cl2[1], ' ', state.cm1[1], ' ', state.cm2[1], ' ', state.cm3[1],' ', state.cr1[1], state.cr2[1], '░')
    foreach(
        i -> println('░', '░', '░', state.r1[i], '░', state.r2[i], '░', state.r3[i], '░', state.r4[i], '░', '░', '░'),
        1:length(state.r1),
    )
    println(join(('░' for _ in 1:13)))
end


## Part 1

function is_empty(state, loc::Symbol)
    all(==('.'), state[loc])
end

function has_space(state, loc::Symbol)
    any(==('.'), state[loc])
end

function is_room(loc::Symbol)
    loc ∈ (:r1, :r2, :r3, :r4)
end

function lookup_occupant_type()
    return (
        r1 = 'A',
        r2 = 'B',
        r3 = 'C',
        r4 = 'D',
    )
end

function lookup_unit_energy()
    return Dict(
        'A' => 1,
        'B' => 10,
        'C' => 100,
        'D' => 1000,
    )
end

function lookup_ordering()
    return [:cl1, :cl2, :r1, :cm1, :r2, :cm2, :r3, :cm3, :r4, :cr1, :cr2]
end

function lookup_on_path()
    c = (:cl2, :cm1, :cm2, :cm3, :cr1)
    return [
        # :cl1   :cl2    :r1   :cm1    :r2   :cm2    :r3   :cm3    :r4   :cr1   :cr2
            ()     () c[1:1] c[1:1] c[1:2] c[1:2] c[1:3] c[1:3] c[1:4] c[1:4] c[1:5];
            ()     ()     ()     () c[2:2] c[2:2] c[2:3] c[2:3] c[2:4] c[2:4] c[2:5];
        c[1:1]     ()     ()     () c[2:2] c[2:2] c[2:3] c[2:3] c[2:4] c[2:4] c[2:5];
        c[1:1]     ()     ()     ()     ()     () c[3:3] c[3:3] c[3:4] c[3:4] c[3:5];
        c[1:2] c[2:2] c[2:2]     ()     ()     () c[3:3] c[3:3] c[3:4] c[3:4] c[3:5];
        c[1:2] c[2:2] c[2:2]     ()     ()     ()     ()     () c[4:4] c[4:4] c[4:5];
        c[1:3] c[2:3] c[2:3] c[3:3] c[3:3]     ()     ()     () c[4:4] c[4:4] c[4:5];
        c[1:3] c[2:3] c[2:3] c[3:3] c[3:3]     ()     ()     ()     ()     () c[5:5];
        c[1:4] c[2:4] c[2:4] c[3:4] c[3:4] c[4:4] c[4:4]     ()     ()     () c[5:5];
        c[1:4] c[2:4] c[2:4] c[3:4] c[3:4] c[4:4] c[4:4]     ()     ()     ()     ();
        c[1:5] c[2:5] c[2:5] c[3:5] c[3:5] c[4:5] c[4:5] c[5:5] c[5:5]     ()     ();
    ]
end

function lookup_energy_unit()
    c = (:cl2, :cm1, :cm2, :cm3, :cr1)
    return [
    # :cl1 :cl2  :r1 :cm1  :r2 :cm2  :r3 :cm3  :r4 :cr1 :cr2
         0    1    3    3    5    5    7    7    9    9   10;
         1    0    2    2    4    4    6    6    8    8    9;
         3    2    0    2    4    4    6    6    8    8    9;
         3    2    2    0    2    2    4    4    6    6    7;
         5    4    4    2    0    2    4    4    6    6    7;
         5    4    4    2    2    0    2    2    4    4    5;
         7    6    6    4    4    2    0    2    4    4    5;
         7    6    6    4    4    2    2    0    2    2    3;
         9    8    8    6    6    4    4    2    0    2    3;
         9    8    8    6    6    4    4    2    2    0    1;
        10    9    9    7    7    5    5    3    3    1    0;
    ]
end

function get_all_moves()
    locs = lookup_ordering()
    rooms = filter(is_room, locs)
    non_rooms = setdiff(locs, rooms)
    [
        reshape(collect(Iterators.product(rooms, non_rooms)), :);
        reshape(collect(Iterators.product(non_rooms, rooms)), :);
    ]
end

function has_only_occupants(state, dst::Symbol)
    occupant_type = lookup_occupant_type()
    all(p -> p == occupant_type[dst] || p == '.', state[dst])
end

function first_occupant(state, loc::Symbol) where {N}
    pods = state[loc]
    pods[findfirst(!=('.'), pods)]
end

function is_correct_occupant(state, src, dst)
    pod = first_occupant(state, src)
    occupant_type = lookup_occupant_type()
    pod == occupant_type[dst]
end

function get_on_path(src::Symbol, dst::Symbol)
    i = indexin((src, dst), lookup_ordering())
    return lookup_on_path()[i...]
end

function is_blocked(state, src::Symbol, dst::Symbol)
    !all(c -> is_empty(state, c), get_on_path(src, dst))
end

function can_move(state, src::Symbol, dst::Symbol)

    is_empty(state, src) && return false
    has_space(state, dst) || return false
    is_room(src) && has_only_occupants(state, src) && return false

    if is_room(dst)
        has_only_occupants(state, dst) || return false
        is_correct_occupant(state, src, dst) || return false
    end

    return !is_blocked(state, src, dst)
end

function eject_first_pod(state, loc)
    pods = state[loc]
    index = findfirst(!=('.'), pods)
    pod = pods[index]
    pods = Tuple([('.' for _ in 1:index)..., pods[(index + 1):end]...])
    state = merge(state, (loc => pods,))
    return (; pod, state, energy_units = index - 1)
end

function insert_pod(state, loc, pod)
    pods = state[loc]
    index = findlast(==('.'), pods)
    pods = Tuple([('.' for _ in 1:(index - 1))..., pod, pods[(index + 1):end]...])
    state = merge(state, (loc => pods,))
    return (; state, energy_units = index - 1)
end

function make_move(state, src::Symbol, dst::Symbol)
    total_energy_units = 0
    pod, state, energy_units = eject_first_pod(state, src)
    total_energy_units += energy_units

    i = indexin((src, dst), lookup_ordering())
    total_energy_units += lookup_energy_unit()[i...]

    state, energy_units = insert_pod(state, dst, pod)
    total_energy_units += energy_units

    return (; state, energy_spent = total_energy_units * lookup_unit_energy()[pod])
end

function get_min_energy_units_to_spend(state, pod, home_room)
    energy_units = 0

    for loc in keys(state)
        (loc == home_room) && continue

        i = indexin((loc, home_room), lookup_ordering())
        crossing_energy_units =  lookup_energy_unit()[i...]
        energy_units += sum(findall(==(pod), state[loc]) .- 1 .+ crossing_energy_units)
    end

    energy_units += sum(filter(i -> state[home_room][i] != pod, 1:length(state[home_room])) .- 1)

    return energy_units
end

function get_min_energy_to_spend(state)
    unit_energy = lookup_unit_energy()
    return sum([
        get_min_energy_units_to_spend(state, 'A', :r1) * unit_energy['A'],
        get_min_energy_units_to_spend(state, 'B', :r2) * unit_energy['B'],
        get_min_energy_units_to_spend(state, 'C', :r3) * unit_energy['C'],
        get_min_energy_units_to_spend(state, 'D', :r4) * unit_energy['D'],
    ])
end

function queue_next_moves!(q, seen_states, state, energy_spent)
    for (src, dst) in get_all_moves()
        can_move(state, src, dst) || continue

        new_state, additional_energy_spent = make_move(state, src, dst)
        (new_state ∈ seen_states) && continue

        new_energy_spent = energy_spent + additional_energy_spent

        min_total_energy = new_energy_spent + get_min_energy_to_spend(new_state)
        q[(new_state, new_energy_spent)] = min_total_energy
        push!(seen_states, new_state)
    end
    return
end

function is_done(state)
    all(==('A'), state.r1) || return false
    all(==('B'), state.r2) || return false
    all(==('C'), state.r3) || return false
    all(==('D'), state.r4) || return false
    return true
end

function result1(state)
    energy_spent = 0
    q = PriorityQueue()
    seen_states = Set()
    q[(state, energy_spent)] = get_min_energy_to_spend(state)
    push!(seen_states, state)

    for i in 1:1000000
        (state, energy_spent) = dequeue!(q)

        if i % 10000 == 0
            @show i
            display_state(state)
            min_energy_to_spend = energy_spent + get_min_energy_to_spend(state)
            @show energy_spent min_energy_to_spend
            flush(stdout)
            flush(stderr)
        end



        if is_done(state)
            @show i
            return (state, energy_spent)
        end

        queue_next_moves!(q, seen_states, state, energy_spent)
    end

    return (state, energy_spent)
end


## Part 2

function result2(pd)
    @chain pd begin
        _
    end
end
