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
		split("\n")
		@. parse_puzzle_line
	end
end

function parse_puzzle_line(s)
	@chain s begin
		split(" ")
		(d = Symbol(_[1]), n = parse(Int, _[2]))
	end
end


## Part 1

function next_head(head, d)
	offsets = Dict(
		:U => CI(-1, 0),
		:D => CI(1, 0),
		:L => CI(0, -1),
		:R => CI(0, 1),
	)

	return head + offsets[d]
end

function is_touching((diff_y, diff_x))
	return (diff_y ∈ -1:1) && (diff_x ∈ -1:1)
end

function move_tail(tail, diff)
	return tail + CI(sign.(diff))
end

function next_tail(tail, head)
	diff = Tuple(head - tail)

	is_touching(diff) && return tail
	return move_tail(tail, diff)
end

function next(knots, d)
	knots = copy(knots)
	knots[1] = next_head(knots[1], d)

	for i in 2:length(knots)
		knots[i] = next_tail(knots[i], knots[i-1])
	end

	return knots
end

function next!(visited, knots, d, n)
	for _ in 1:n
		knots = next(knots, d)
		push!(visited, knots[end])
	end

	return knots
end

function visit_by_rope_tail(moves, knot_count)
	visited = Set{CI{2}}()

	knots = [CI(0, 0) for _ in 1:knot_count]
	for (d, n) in moves
		knots = next!(visited, knots, d, n)
	end

	return length(visited)
end

function result1(moves)
	visit_by_rope_tail(moves, 2)
end


## Part 2

function result2(moves)
	visit_by_rope_tail(moves, 10)
end
