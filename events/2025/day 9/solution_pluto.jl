### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 090b4c81-9cda-42e4-a9ff-22fbf5844fa0
begin
	using Pkg
	Pkg.activate(Base.current_project())
end

# ╔═╡ 90815a37-6e8e-4c01-9e22-52dd96ab457b
using PlutoUI

# ╔═╡ 56736de4-cc48-11f0-a6b8-e199bea039a2
begin
	using Chain
	using Combinatorics
	using DataStructures
	using OffsetArrays
	using Mods
	using UnPack
end

# ╔═╡ 213c3a51-ce8d-4c6f-811e-7f551fd2c356
begin
	matched = match(r"events/(?<year>\d+)/day (?<day>\d+)$", pwd())
	if isnothing(matched)
		md"""
		# Advent of Code template
		Copy this to an AoC event (`events/<year>/day <day>/`) as the starting point for the puzzle.
		"""
	else
		@unpack year, day = NamedTuple(matched)
		problem_link = "[Problem link](https://adventofcode.com/$(year)/day/$(day))"
	
		Markdown.parse(
			"""
			# Advent of Code $(year) Day $(day)
			$(problem_link)
			"""
		)
	end
end

# ╔═╡ bfd79601-6001-4737-bc9f-f13e02150c3c
md"""
## Parse puzzle input
"""

# ╔═╡ 5436ac6a-5869-4b8d-9b9e-56e731589cbd
md"""
## Part 1
"""

# ╔═╡ ef1dff25-0467-4f1a-80e2-6fa72d71b482
AreaRange = NTuple{2, UnitRange{Int}}

# ╔═╡ 057c0011-8462-4d8e-b7fa-56e572a7ec97
function get_rect_size(ranges::AreaRange)
	@chain ranges begin
		@. length
		prod
	end
end

# ╔═╡ 451ff7c6-1e2f-4717-9c15-92760473609c
md"""
### answer
"""

# ╔═╡ 2bbaf7d3-5a27-43f6-b7e6-a737a4419406
md"""
## Part 2
"""

# ╔═╡ 113c0158-077e-49fc-97ea-4ab36f6d4fb9
md"""
The crux for part 2 is that a rectangular area is invalid (i.e. contains external tiles) iff there's an edge of the tile shape that cut within the internal boundary of this area.
"""

# ╔═╡ d0374a6f-1a7a-4c65-bd3c-f78d148e2a16
function is_cutting_into_area(
	line::AreaRange,
	area::AreaRange,
)
	if length(line[1]) == 1
		(only(line[1]) ∉ area[1]) && (return false)
		return !isempty(line[2] ∩ area[2])
	else
		(only(line[2]) ∉ area[2]) && (return false)
		return !isempty(line[1] ∩ area[1])
	end
end

# ╔═╡ 2719c37b-de14-4c3f-9e54-0ace6404a4c2
is_contained_area(area::AreaRange, lines::Vector{AreaRange}) = all(!is_cutting_into_area(line, area) for line in lines)

# ╔═╡ d496419e-572a-4fe7-9468-bd4d0be9e0c7
md"""
### answer
"""

# ╔═╡ 15086b83-76c4-4082-8f23-efd9602cccdd
md"""
## Part 2 (alt)
"""

# ╔═╡ 4d1f931b-5dbf-4f2f-a165-d87e626c6bf7
md"""
Alternatively compress the area first while keeping the shape. Then floodfill and process on it. This handles a broader problem domain.
"""

# ╔═╡ c3a02d09-8661-41bd-b3ab-6e340c1c8b5d
function make_compress_map(xs::Vector{Int})
	sorted_xs = @chain xs begin
		Set
		collect
		sort
	end

	m = Dict(sorted_xs[1] => 2)
	for i in 2:length(sorted_xs)
		x = sorted_xs[i]
		prev_x = sorted_xs[i - 1]
		m[x] = m[prev_x] + (x - prev_x > 1 ? 2 : 1)
	end
	return m
end

# ╔═╡ c366ad51-46da-47b4-af45-2d2374521857
	md"""
	## Standard helpers
	"""

# ╔═╡ 3460a9d6-dec6-4791-bbbb-f081e253f7d9
import AdventOfCode:
	AdventOfCode,
	CI, CIS,
	make_smallest_boundary,
	parse_matrix,
	print_matrix

# ╔═╡ afe15c3c-0a5f-4db4-8f72-bd22b0b7e27b
function parse_puzzle_line(s)
    @chain s begin
        split(",")
		@. parse(Int, _)
		CI(_...)
    end
end

# ╔═╡ da7e182a-6c9d-4c43-91d4-b32be2545718
function parse_puzzle_data(s::String)
    @chain s begin
        split("\n")
		@. string
        @. parse_puzzle_line
    end
end

# ╔═╡ ccd4eb29-5eb4-469c-99d7-1cdcd679fb66
function parse_puzzle_file(filename::String)
    @chain filename begin
        readchomp
		string
        parse_puzzle_data
    end
end

# ╔═╡ d97c6185-39c1-4d26-b2d2-66dd000c317b
PDI = parse_puzzle_file("input.txt")

# ╔═╡ e9fc4134-09f9-43b8-8066-24ab50a2f64c
# puzzle part 1 data samples
PDS_part1 = parse_puzzle_file("sample1.txt")

# ╔═╡ d9048bfa-f5b4-4257-b678-23755c97427e
# puzzle part 2 data samples
PDS_part2 = parse_puzzle_file("sample1.txt")

# ╔═╡ d2638404-b96d-4362-850f-98fd5dabd5be
macro pd_str(s::String)
    @chain s begin
        chomp
		string
        parse_puzzle_data
    end
end

# ╔═╡ 4c4f78ee-b679-4597-9a0e-a01a2060f231
function result1(pd)
    @chain pd begin
        Combinatorics.combinations(2)
		@. make_smallest_boundary
		@. get_rect_size
		maximum
    end
end

# ╔═╡ 5bdfe21f-9535-47f3-b162-5c63e49022ac
result1(PDS_part1)
# 50

# ╔═╡ 0afa794b-17ef-4e24-a5de-caf2d4ff966e
@time @info(
    "part 1 answer",
    result1(PDI),
)
# my ans: 4749838800

# ╔═╡ e6938500-494f-4c3a-92e0-ba48fa360ec0
function result2(pd)
	pairs = Combinatorics.combinations(pd, 2)
	areas = make_smallest_boundary.(pairs)
	inner_areas = make_smallest_boundary.(pairs; margin = (-1, -1))
	lines = @chain begin
		zip(circshift(pd, 1), pd)
		@. collect
		@. make_smallest_boundary
	end

	valid_areas = [
		area
		for (area, inner_area) ∈ zip(areas, inner_areas)
		if is_contained_area(inner_area, lines)
	]
	@chain valid_areas begin
		@. get_rect_size
		maximum
	end
end

# ╔═╡ b5d4cd00-4d5b-4ab5-8771-23e471badb57
result2(PDS_part2)
# 24

# ╔═╡ 6cb8a5e4-d822-425e-ad9e-aeff375ad9ac
@time @info(
    "part 2 answer",
    result2(PDI),
)
# my ans: 1624057680

# ╔═╡ 2b058347-13d1-49ea-a74a-66e3474dcb35
function map_ci(ci::CI{2}, compression_mapping::Vector{Dict{Int, Int}})
	return CI(
		compression_mapping[1][ci[1]],
		compression_mapping[2][ci[2]],
	)
end

# ╔═╡ deac70da-cc6c-46b2-8383-4c06ef5a4212
function compress_cis(cis::Vector{CI{2}})
	compress_mapping = [
		make_compress_map([ci[1] for ci ∈ cis]),
	    make_compress_map([ci[2] for ci ∈ cis]),
	]
	return [map_ci(ci, compress_mapping) for ci ∈ cis]
end

# ╔═╡ ea47396d-b6f4-46e3-ad65-670ca315d7d5
is_within_area(ci::CI, area) = all(Tuple(ci) .∈ axes(area))

# ╔═╡ 21378a48-051f-4fdb-a6f9-34b57adfdcdc
function get_neighbours(ci::CI, area)
    # 2D plus
    offsets = [
        CI(-1,  0),
        CI( 1,  0),
        CI( 0, -1),
        CI( 0,  1),
    ]
    neighbours = Ref(ci) .+ offsets
    return filter(nci -> is_within_area(nci, area), neighbours)
end

# ╔═╡ f43ba201-0bd3-400d-b2be-0877dcd92cdb
function flood_exterior!(area)
	pq = DataStructures.Queue{CI{2}}()
	push!(pq, CI(1, 1))
	area[CI(1, 1)] = 0
	while !isempty(pq)
		ci = popfirst!(pq)
		for nci ∈ get_neighbours(ci, area)
			if area[nci] == 2
				area[nci] = 0
				push!(pq, nci)
			end
		end
	end
	return area
end

# ╔═╡ cc72da4f-2bb4-4027-b6d2-5e9d8ec21962
function make_shape(cis::Vector{CI{2}})
	area = [2 for _ ∈ falses(make_smallest_boundary(cis; margin = (1, 1)))]
	lines = @chain begin
		zip(circshift(cis, 1), cis)
		@. collect
		@. make_smallest_boundary
		@. CIS
	end
	for line in lines
		area[line] .= 1
	end
	return flood_exterior!(area)
end

# ╔═╡ 99a1f3c3-9de2-4210-a7c8-590df01f960d
is_valid_pair(pair, shape) = all(shape[make_smallest_boundary(pair)...] .> 0)

# ╔═╡ 5d8fcc7d-dc07-4566-9a09-4b78c31219b4
function result2_alt(pd)
	cis = pd
	mapped_cis = compress_cis(cis)
	shape = make_shape(mapped_cis)

	pairs = collect(Combinatorics.combinations(cis, 2))
	compressed_pairs = collect(Combinatorics.combinations(mapped_cis, 2))
	valid_pairs = [
		pair
		for (pair, compressed_pair) ∈ zip(pairs, compressed_pairs)
		if is_valid_pair(compressed_pair, shape)
	]
	
	@chain valid_pairs begin
		@. make_smallest_boundary
		@. get_rect_size
		maximum
	end
end

# ╔═╡ 128909ad-3563-4658-bf2c-bd7a152572ed
result2_alt(PDS_part2)
# 24

# ╔═╡ 3a70db88-c450-429b-8bab-832903b07626
@time @info(
    "part 2 (alt) answer",
    result2_alt(PDI),
)
# my ans: 1624057680

# ╔═╡ b405167e-613f-49ae-ad3d-30354d2c30a3
begin
	Base.show(io::IO, ::MIME"text/plain", c::CI) = print(io, "CI(", join(string.(Tuple(c)), ", "), ")")
	Base.show(io::IO, c::CI) = show(io, "text/plain", c)
	
	Base.show(io::IO, ::MIME"text/plain", c::CIS) = print(io, "CIS((", join(c.indices, ", "), "))")
	Base.show(io::IO, c::CIS) = show(io, "text/plain", c)
	
	Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))
	
	# Base.show(io::IO, ::MIME"text/plain", v::Vector) = print(io, "[", join(v, ", "), "]")
	Base.show(io::IO, v::Vector) = print(io, "[", join(v, ", "), "]")
end

# ╔═╡ edb226f3-ee5c-4c18-85d5-daf795014160
html"""
<style>
    main {
        max-width: none; /* Removes the max-width constraint */
        margin: 0 auto; /* Centers the content if there's extra space */
        padding-left: 10%; /* Optional: add some padding on the sides */
        padding-right: 10%;
    }
</style>
"""

# ╔═╡ Cell order:
# ╟─213c3a51-ce8d-4c6f-811e-7f551fd2c356
# ╟─bfd79601-6001-4737-bc9f-f13e02150c3c
# ╟─ccd4eb29-5eb4-469c-99d7-1cdcd679fb66
# ╟─d2638404-b96d-4362-850f-98fd5dabd5be
# ╠═da7e182a-6c9d-4c43-91d4-b32be2545718
# ╠═afe15c3c-0a5f-4db4-8f72-bd22b0b7e27b
# ╠═d97c6185-39c1-4d26-b2d2-66dd000c317b
# ╟─5436ac6a-5869-4b8d-9b9e-56e731589cbd
# ╠═ef1dff25-0467-4f1a-80e2-6fa72d71b482
# ╠═e9fc4134-09f9-43b8-8066-24ab50a2f64c
# ╠═057c0011-8462-4d8e-b7fa-56e572a7ec97
# ╠═4c4f78ee-b679-4597-9a0e-a01a2060f231
# ╠═5bdfe21f-9535-47f3-b162-5c63e49022ac
# ╟─451ff7c6-1e2f-4717-9c15-92760473609c
# ╠═0afa794b-17ef-4e24-a5de-caf2d4ff966e
# ╟─2bbaf7d3-5a27-43f6-b7e6-a737a4419406
# ╟─113c0158-077e-49fc-97ea-4ab36f6d4fb9
# ╠═d9048bfa-f5b4-4257-b678-23755c97427e
# ╠═d0374a6f-1a7a-4c65-bd3c-f78d148e2a16
# ╠═2719c37b-de14-4c3f-9e54-0ace6404a4c2
# ╠═e6938500-494f-4c3a-92e0-ba48fa360ec0
# ╠═b5d4cd00-4d5b-4ab5-8771-23e471badb57
# ╟─d496419e-572a-4fe7-9468-bd4d0be9e0c7
# ╠═6cb8a5e4-d822-425e-ad9e-aeff375ad9ac
# ╠═15086b83-76c4-4082-8f23-efd9602cccdd
# ╠═4d1f931b-5dbf-4f2f-a165-d87e626c6bf7
# ╠═c3a02d09-8661-41bd-b3ab-6e340c1c8b5d
# ╠═deac70da-cc6c-46b2-8383-4c06ef5a4212
# ╠═2b058347-13d1-49ea-a74a-66e3474dcb35
# ╠═ea47396d-b6f4-46e3-ad65-670ca315d7d5
# ╠═21378a48-051f-4fdb-a6f9-34b57adfdcdc
# ╠═f43ba201-0bd3-400d-b2be-0877dcd92cdb
# ╠═cc72da4f-2bb4-4027-b6d2-5e9d8ec21962
# ╠═99a1f3c3-9de2-4210-a7c8-590df01f960d
# ╠═5d8fcc7d-dc07-4566-9a09-4b78c31219b4
# ╠═128909ad-3563-4658-bf2c-bd7a152572ed
# ╠═3a70db88-c450-429b-8bab-832903b07626
# ╟─c366ad51-46da-47b4-af45-2d2374521857
# ╠═090b4c81-9cda-42e4-a9ff-22fbf5844fa0
# ╠═90815a37-6e8e-4c01-9e22-52dd96ab457b
# ╠═56736de4-cc48-11f0-a6b8-e199bea039a2
# ╠═3460a9d6-dec6-4791-bbbb-f081e253f7d9
# ╠═b405167e-613f-49ae-ad3d-30354d2c30a3
# ╠═edb226f3-ee5c-4c18-85d5-daf795014160
