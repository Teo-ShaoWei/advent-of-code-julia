using Chain
using Combinatorics
using DataStructures
import LinearAlgebra


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
Base.show(io::IO, c::CI) = show(io, "text/plain", c)

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readchomp
        split("\n\n")
        @. parse_scanner
    end
end

function parse_scanner(s)
    @chain s begin
        split("\n")
        (loc = CI(0, 0, 0), beacons = parse_coordinate.(_[2:end]))
    end
end

function parse_coordinate(s)
    @chain s begin
        join(["CI(", _, ")"])
        Meta.parse
        eval
    end
end


## Part 1

"""
The ordering is very important! Think about how to get a disoriented scanner upright:
    1. Flip upside down if the top face the negative direction of that axis (2 of transformation A).
    2. Rotate around the top-axis to get both the front and right axis to face position directions (4 of transformation B).
    3. Rotate around the 3-axis cone to rotate the axes, e.g. (x, y, z) -> (y, z, x) -> (z, x, y), until the top face the x-axis (3 of transformation C).
"""
function generate_all_facings()
    A = [
        1  0  0;
        0 -1  0;
        0  0 -1;
    ]
    B = [
        0 -1 0;
        1  0 0;
        0  0 1;
    ]
    C = [
        0 1 0;
        0 0 1;
        1 0 0;
    ]

    (C^pC * B^pB * A^pA for (pA, pB, pC) in Iterators.product(0:1, 0:3, 0:2))
end

"""
Alternatively, make use of cross-product to generate the 3rd column vector.
Concatenate together to form the transformation matrix.
"""
function generate_all_facings_alt()
    v = [
        [-1; 0; 0],
        [1; 0; 0],
        [0; -1; 0],
        [0; 1; 0],
        [0; 0; -1],
        [0; 0; 1],
    ]

    result = []
    for v1 in v, v2 in v
        v3 = LinearAlgebra.cross(v1, v2)
        (v3 == [0; 0; 0]) && continue
        push!(result, [v1;; v2;; v3])
    end
    return result
end

function orientate(c, facing)
    @chain c begin
        Tuple
        collect
        facing * _
        CI(_...)
    end
end

function reorientate_scanner(fixed_scanner, disorientated_scanner)
    fixed_beacons = fixed_scanner.beacons
    for facing in generate_all_facings()
        beacons = disorientated_scanner.beacons
        beacons = orientate.(beacons, Ref(facing))

        for c1 in fixed_beacons, c2 in beacons
            offset = c2 - c1
            moved_beacons = beacons .- Ref(offset)
            overlap_count = count(∈(fixed_beacons), moved_beacons)
            (overlap_count < 12) && continue

            orientated_scanner = (loc = -offset, beacons = moved_beacons)
            return (true, orientated_scanner)
        end
    end

    return (false, disorientated_scanner)
end

function reorientate_all_scanners(scanners)
    scanners = deepcopy(scanners)
    q = DataStructures.Queue{Int}()
    enqueue!(q, 1)
    unresolved_inds = Set(collect(2:length(scanners)))

    while !isempty(q)
        i = dequeue!(q)
        for j in unresolved_inds
            ok, scanner = reorientate_scanner(scanners[i], scanners[j])
            !ok && continue

            scanners[j] = scanner
            enqueue!(q, j)
            delete!(unresolved_inds, j)
        end
    end

    return scanners
end

function gather_beacons(scanners)
    @chain scanners begin
        (s.beacons for s in _)
        union(_...)
        unique!
    end
end

function result1(scanners)
    @chain scanners begin
        reorientate_all_scanners
        gather_beacons
        length
    end
end


## Part 2

function L1(c1::CI, c2::CI)
    @chain c1 - c2 begin
        Tuple
        @. abs
        sum
    end
end

function largest_L1(scanners)
    @chain scanners begin
        [s.loc for s in _]
        [L1(c1, c2) for (c1, c2) in Combinatorics.combinations(_, 2)]
        maximum
    end
end

function result2(scanners)
    @chain scanners begin
        reorientate_all_scanners
        largest_L1
    end
end
