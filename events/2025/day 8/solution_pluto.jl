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

# ╔═╡ afe15c3c-0a5f-4db4-8f72-bd22b0b7e27b
function parse_puzzle_line(s)
    @chain s begin
		split(",")
		@. parse(Int, _)
    end
end

# ╔═╡ da7e182a-6c9d-4c43-91d4-b32be2545718
function parse_puzzle_data(s::String)
    @chain s begin
		split("\n")
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

# ╔═╡ d2638404-b96d-4362-850f-98fd5dabd5be
macro pd_str(s::String)
    @chain s begin
        chomp
		string
        parse_puzzle_data
    end
end

# ╔═╡ d97c6185-39c1-4d26-b2d2-66dd000c317b
PDI = parse_puzzle_file("input.txt")

# ╔═╡ 5436ac6a-5869-4b8d-9b9e-56e731589cbd
md"""
## Part 1
"""

# ╔═╡ e9fc4134-09f9-43b8-8066-24ab50a2f64c
# puzzle part 1 data samples
PDS_part1 = parse_puzzle_file("sample1.txt")

# ╔═╡ 057c0011-8462-4d8e-b7fa-56e572a7ec97
function compute_euclidean_distances(v)
	sort(
		[
			(ci1, ci2) => sqrt(sum((ci1 .- ci2) .^ 2))
			for (ci1, ci2) ∈ Combinatorics.combinations(v, 2)
		],
		;
		by = ((k, v),) -> v,
	)
end

# ╔═╡ 9e9904ba-1f10-447e-96aa-88a8be85a433
compute_euclidean_distances(PDS_part1)

# ╔═╡ 91d2f453-b569-4617-b530-8faf191fee3e
function connect_boxes(boxes, sorted_dists; limit)
	ds = DataStructures.DisjointSet(boxes)
	moves = 0

	for ((ci1, ci2), _) ∈ sorted_dists
		moves += 1
		in_same_set(ds, ci1, ci2) && continue
		union!(ds, ci1, ci2)
		(moves == limit) && break
	end

	result = Dict(box => 0 for box in boxes)
	for box in boxes
		result[find_root!(ds, box)] += 1
	end
	result
end

# ╔═╡ 9955cf4c-ae76-442e-81bd-6773475db4f5
connect_boxes(PDS_part1, compute_euclidean_distances(PDS_part1); limit = 10)

# ╔═╡ 4c4f78ee-b679-4597-9a0e-a01a2060f231
function result1(pd; limit)
	@chain pd begin
		compute_euclidean_distances
		connect_boxes(pd, _; limit)
		values
		collect
		sort(; rev = true)
		_[1:3]
		prod
	end
end

# ╔═╡ 5bdfe21f-9535-47f3-b162-5c63e49022ac
result1(PDS_part1; limit = 10)

# ╔═╡ 451ff7c6-1e2f-4717-9c15-92760473609c
md"""
### answer
"""

# ╔═╡ 0afa794b-17ef-4e24-a5de-caf2d4ff966e
@time @info(
    "part 1 answer",
    result1(PDI; limit = 1000),
)
# my ans: 123930

# ╔═╡ 2bbaf7d3-5a27-43f6-b7e6-a737a4419406
md"""
## Part 2
"""

# ╔═╡ d9048bfa-f5b4-4257-b678-23755c97427e
# puzzle part 2 data samples
PDS_part2 = parse_puzzle_file("sample1.txt")

# ╔═╡ 62303755-9e9a-498c-b3ba-e94352c61132
function connect_all_boxes(boxes, queue)
	ds = DataStructures.DisjointSet(boxes)
	moves = 0

	for ((ci1, ci2), _) ∈ queue
		in_same_set(ds, ci1, ci2) && continue
		union!(ds, ci1, ci2)
		moves += 1
		(moves + 1 == length(boxes)) && (return (; ci1, ci2))
	end
end

# ╔═╡ 20042511-0231-436f-a6cd-3c1e8f4232b3
connect_all_boxes(PDS_part2, compute_euclidean_distances(PDS_part2))

# ╔═╡ e6938500-494f-4c3a-92e0-ba48fa360ec0
function result2(pd)
	@chain pd begin
		compute_euclidean_distances
		connect_all_boxes(pd, _)
		_.ci1[1] * _.ci2[1]
	end
end

# ╔═╡ b5d4cd00-4d5b-4ab5-8771-23e471badb57
result2(PDS_part2)
# 25272

# ╔═╡ d496419e-572a-4fe7-9468-bd4d0be9e0c7
md"""
### answer
"""

# ╔═╡ 6cb8a5e4-d822-425e-ad9e-aeff375ad9ac
@time @info(
    "part 2 answer",
    result2(PDI),
)
# my ans: 27338688

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
# ╠═e9fc4134-09f9-43b8-8066-24ab50a2f64c
# ╠═057c0011-8462-4d8e-b7fa-56e572a7ec97
# ╠═9e9904ba-1f10-447e-96aa-88a8be85a433
# ╠═91d2f453-b569-4617-b530-8faf191fee3e
# ╠═9955cf4c-ae76-442e-81bd-6773475db4f5
# ╠═4c4f78ee-b679-4597-9a0e-a01a2060f231
# ╠═5bdfe21f-9535-47f3-b162-5c63e49022ac
# ╟─451ff7c6-1e2f-4717-9c15-92760473609c
# ╠═0afa794b-17ef-4e24-a5de-caf2d4ff966e
# ╟─2bbaf7d3-5a27-43f6-b7e6-a737a4419406
# ╠═d9048bfa-f5b4-4257-b678-23755c97427e
# ╠═20042511-0231-436f-a6cd-3c1e8f4232b3
# ╠═62303755-9e9a-498c-b3ba-e94352c61132
# ╠═e6938500-494f-4c3a-92e0-ba48fa360ec0
# ╠═b5d4cd00-4d5b-4ab5-8771-23e471badb57
# ╟─d496419e-572a-4fe7-9468-bd4d0be9e0c7
# ╠═6cb8a5e4-d822-425e-ad9e-aeff375ad9ac
# ╟─c366ad51-46da-47b4-af45-2d2374521857
# ╠═090b4c81-9cda-42e4-a9ff-22fbf5844fa0
# ╠═90815a37-6e8e-4c01-9e22-52dd96ab457b
# ╠═56736de4-cc48-11f0-a6b8-e199bea039a2
# ╠═3460a9d6-dec6-4791-bbbb-f081e253f7d9
# ╠═b405167e-613f-49ae-ad3d-30354d2c30a3
# ╠═edb226f3-ee5c-4c18-85d5-daf795014160
