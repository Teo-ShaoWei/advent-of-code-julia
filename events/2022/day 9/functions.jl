import Chain: @chain


## Helpers

import AdventOfCode:
	AdventOfCode,
	CI, CIS

function AdventOfCode.CI((; x, y)::@NamedTuple{x::Int, y::Int})
	return CI(x, y)
end

function Base.getproperty(ci::CI{2}, sym::Symbol)
	(sym == :x) && return ci[1]
	(sym == :y) && return ci[2]

	# CI has fields (:I,)
	return getfield(ci, sym)
end

# Does not conflict with existing defintion for showing CI{N}.
Base.show(io::IO, ::MIME"text/plain", ci::CI{2}) = print(io, "CI(", (; ci.x, ci.y), ")")


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
		(d = _[1], n = parse(Int, _[2]))
	end
end


## Part 1

function next_head(head, d)
	offsets = Dict(
		"U" => CI((x =  0, y = -1)),
		"D" => CI((x =  0, y =  1)),
		"L" => CI((x = -1, y =  0)),
		"R" => CI((x =  1, y =  0)),
	)

	return head + offsets[d]
end

function is_touching(ci::CI)
	(ci.x ∈ -1:1) && (ci.y ∈ -1:1)
end

function move_tail(tail, δ)
	return tail + CI((x = sign(δ.x), y = sign(δ.y)))
end

function next_tail(tail, head)
	δ = head - tail
	return is_touching(δ) ? tail : move_tail(tail, δ)
end

function next(knots, rule)
	knots = copy(knots)
	knots[1] = next_head(knots[1], rule)

	for i in 2:length(knots)
		knots[i] = next_tail(knots[i], knots[i-1])
	end

	return knots
end

function visit_by_rope_tail(moves, knot_count)
	visited = Set{CI{2}}()

	knots = [CI(0, 0) for _ in 1:knot_count]
	for (d, n) in moves
		for _ in 1:n
			knots = next(knots, d)
			push!(visited, knots[end])
		end
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
