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
        string
    end
end

# ╔═╡ da7e182a-6c9d-4c43-91d4-b32be2545718
function parse_puzzle_data(s)
    @chain s begin
        split("\n")
        @. parse_puzzle_line
		only
    end
end

# ╔═╡ ccd4eb29-5eb4-469c-99d7-1cdcd679fb66
function parse_puzzle_file(filename::String)
    @chain filename begin
        readchomp
        parse_puzzle_data
    end
end

# ╔═╡ d2638404-b96d-4362-850f-98fd5dabd5be
macro pd_str(s::String)
    @chain s begin
        chomp
        parse_puzzle_data
    end
end

# ╔═╡ d97c6185-39c1-4d26-b2d2-66dd000c317b
PDI = parse_puzzle_file("input.txt")

# ╔═╡ 5436ac6a-5869-4b8d-9b9e-56e731589cbd
md"""
## Part 1
"""

# ╔═╡ 5d1c1e18-1eb6-4eb0-a23f-df5ef1ca94d4
PDE_part1 = [
	pd"(())",
	pd"()()",
	pd"(((",
	pd"(()(()(",
	pd"))(((((",
	pd"())",
	pd"))(",
	pd")))",
	pd")())())",
]

# ╔═╡ ad1ee250-2cf7-4c40-90ae-f455fe15c6f5
function move(c::Char)
	c == '(' ? 1 : -1
end

# ╔═╡ db60ad6c-4c21-4145-9605-5d45c08504c0
move('(')

# ╔═╡ c9f0b0bc-6d18-43d8-b88e-2d4766ff203c
move(')')

# ╔═╡ 4c4f78ee-b679-4597-9a0e-a01a2060f231
function result1(pd)
    @chain pd begin
        split("")
		@. only
		@. move
		sum
    end
end

# ╔═╡ ce27c0b9-5fa2-4ce8-bd21-0b7449fefb25
[result1(pd) for pd ∈ PDE_part1]

# ╔═╡ 451ff7c6-1e2f-4717-9c15-92760473609c
md"""
### answer
"""

# ╔═╡ 0afa794b-17ef-4e24-a5de-caf2d4ff966e
@time @info(
    "part 1 answer",
    result1(PDI),
)

# ╔═╡ 2bbaf7d3-5a27-43f6-b7e6-a737a4419406
md"""
## Part 2
"""

# ╔═╡ 8ccc98d3-91c7-4ec6-9ad1-9c0026ee067c
PDE_part2 = [
	pd")",
	pd"()())",
]

# ╔═╡ e6938500-494f-4c3a-92e0-ba48fa360ec0
function result2(pd)
    @chain pd begin
        split("")
		@. only
		@. move
		cumsum
		findfirst(==(-1), _)
    end
end

# ╔═╡ 87d0b854-5e8d-4aa7-b3a6-6e241de1c96f
[result2(pd) for pd ∈ PDE_part2]

# ╔═╡ d496419e-572a-4fe7-9468-bd4d0be9e0c7
md"""
### answer
"""

# ╔═╡ 6cb8a5e4-d822-425e-ad9e-aeff375ad9ac
@time @info(
    "part 2 answer",
    result2(PDI),
)

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
	
	# Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))
	
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
# ╠═5d1c1e18-1eb6-4eb0-a23f-df5ef1ca94d4
# ╠═ad1ee250-2cf7-4c40-90ae-f455fe15c6f5
# ╠═db60ad6c-4c21-4145-9605-5d45c08504c0
# ╠═c9f0b0bc-6d18-43d8-b88e-2d4766ff203c
# ╠═4c4f78ee-b679-4597-9a0e-a01a2060f231
# ╠═ce27c0b9-5fa2-4ce8-bd21-0b7449fefb25
# ╟─451ff7c6-1e2f-4717-9c15-92760473609c
# ╠═0afa794b-17ef-4e24-a5de-caf2d4ff966e
# ╟─2bbaf7d3-5a27-43f6-b7e6-a737a4419406
# ╠═8ccc98d3-91c7-4ec6-9ad1-9c0026ee067c
# ╠═e6938500-494f-4c3a-92e0-ba48fa360ec0
# ╠═87d0b854-5e8d-4aa7-b3a6-6e241de1c96f
# ╟─d496419e-572a-4fe7-9468-bd4d0be9e0c7
# ╠═6cb8a5e4-d822-425e-ad9e-aeff375ad9ac
# ╟─c366ad51-46da-47b4-af45-2d2374521857
# ╠═090b4c81-9cda-42e4-a9ff-22fbf5844fa0
# ╠═90815a37-6e8e-4c01-9e22-52dd96ab457b
# ╠═56736de4-cc48-11f0-a6b8-e199bea039a2
# ╠═3460a9d6-dec6-4791-bbbb-f081e253f7d9
# ╠═b405167e-613f-49ae-ad3d-30354d2c30a3
# ╠═edb226f3-ee5c-4c18-85d5-daf795014160
