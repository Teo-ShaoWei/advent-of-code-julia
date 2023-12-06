using Chain
using Combinatorics
using DataStructures
using Mods


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(Tuple(c), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
Base.show(io::IO, c::CIS) = show(io, "text/plain", c)

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
        split(" ")
        (string(_[1]), parse_axes(_[2]))
    end
end

function parse_axes(s)
    @chain s begin
        split(",")
        @. parse_axis
        Tuple
        CIS
    end
end

function parse_axis(s)
    @chain s begin
        match(r"(.)=(.+)\.\.(.+)", _)
        collect
        (parse(Int, _[2]):parse(Int, _[3]))
    end
end


## Part 1

function init_cubes()
    DefaultDict{CI{3}, Bool}(false)
end

# function expand_axes(a, r)
#     return (
#         expand_axis(axes(a, 1), r[1]),
#         expand_axis(axes(a, 2), r[2]),
#         expand_axis(axes(a, 3), r[3]),
#     )
# end

# function expand_axis(x1, x2)
#     range(
#         start = min(first(x1), first(x2)),
#         stop = max(last(x1), last(x2)),
#     )
# end

function filter_axes(r1, r2)
    return (
        filter_axis(r1[1], r2[1]),
        filter_axis(r1[2], r2[2]),
        filter_axis(r1[3], r2[3]),
    )
end

function filter_axis(x1, x2)
    range(
        start = max(first(x1), first(x2)),
        stop = min(last(x1), last(x2)),
    )
end

function toggle_cuboid!(cubes, toggle_range, toggle_state::Val{:on})
    toggle_range = filter_axes(toggle_range, (-50:50, -50:50, -50:50))
    for c in CIS(toggle_range)
        cubes[c] = true
    end
    return cubes
end

function toggle_cuboid!(cubes, toggle_range, toggle_state::Val{:off})
    toggle_range = filter_axes(toggle_range, (-50:50, -50:50, -50:50))
    for c in CIS(toggle_range)
        cubes[c] = false
    end
    return cubes
end

function result1(steps)
    cubes = init_cubes()

    for (toggle_state, toggle_range) in steps
        cubes = toggle_cuboid!(cubes, toggle_range, toggle_state)
    end

    count(s == 1 for (c, s) in cubes)

    # return cubes[filter_axes(cubes, (1:50, 1:50, 1:50))...] |> count
end

## Part 2

function gather_marks(steps, i)
    marks = Int[]
    for (_, toggle_range) in steps
        push!(marks, first(toggle_range.indices[i]))
        push!(marks, last(toggle_range.indices[i]) + 1)
    end
    unique!(sort!(marks))
end

function gather_marks(steps)
    return (
        gather_marks(steps, 1),
        gather_marks(steps, 2),
        gather_marks(steps, 3),
    )
end

function init_region(marks)
    @chain marks begin
        @. length
        [l - 1 for l in _]
        Tuple
        fill(false, _)
    end
end

function cuboid2region_inds(cuboid, marks)
    return CIS((
        get_cuboid2region_ind(cuboid.indices[1], marks[1]),
        get_cuboid2region_ind(cuboid.indices[2], marks[2]),
        get_cuboid2region_ind(cuboid.indices[3], marks[3]),
    ))
end

function get_cuboid2region_ind(cuboid_dim, marks_dim)
    searchsortedfirst(marks_dim, first(cuboid_dim)):searchsortedlast(marks_dim, last(cuboid_dim))
end

function take_step!(region, marks, step)
    (toggle, cuboid) = step
    cis = cuboid2region_inds(cuboid, marks)
    if toggle == Val(:on)
        region[cis] .= true
    else
        region[cis] .= false
    end
    return region
end

function marks2cubes(marks)
    return (
        CIS((
            marks[1][i1]:(marks[1][i1 + 1] - 1),
            marks[2][i2]:(marks[2][i2 + 1] - 1),
            marks[3][i3]:(marks[3][i3 + 1] - 1),
        ))
        for i1 in 1:(length(marks[1]) - 1)
        for i2 in 1:(length(marks[2]) - 1)
        for i3 in 1:(length(marks[3]) - 1)
    )
end

function get_subcuboids(marks, cuboid)
    subcuboids_cis = CIS((
        get_subcuboid_dim(marks[1], cuboid.indices[1]),
        get_subcuboid_dim(marks[2], cuboid.indices[2]),
        get_subcuboid_dim(marks[3], cuboid.indices[3]),
    ))

    return map(subcuboids_cis) do ci
        (i1, i2, i3) = Tuple(ci)
        CIS((
            marks[1][i1]:(marks[1][i1 + 1] - 1),
            marks[2][i2]:(marks[2][i2 + 1] - 1),
            marks[3][i3]:(marks[3][i3 + 1] - 1),
        ))
    end
end

function assign_state!(state, subcuboids, toggle)
    for subcuboid in subcuboids
        haskey(state, subcuboids) && continue
        state[subcuboid] = toggle
    end
end

function get_subcuboid_dim(marks_dim, cuboid_dim)
    searchsortedfirst(marks_dim, first(cuboid_dim)):searchsortedlast(marks_dim, last(cuboid_dim))
end

function volume(region, marks)
    result = big(0)
    for c in CIS(region)
        region[c] && (result += volume(region, c, marks))
    end

    return result
end

function volume(region, c, marks)
    return prod([
        marks[1][c[1] + 1] - marks[1][c[1]],
        marks[2][c[2] + 1] - marks[2][c[2]],
        marks[3][c[3] + 1] - marks[3][c[3]],
    ])
end

function result2(steps)
    marks = gather_marks(steps)
    region = init_region(marks)

    for step in steps
        take_step!(region, marks, step)
    end

    volume(region, marks)
end
