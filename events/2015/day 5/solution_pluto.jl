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
PDS_part1 = [
	parse_puzzle_file("sample1.txt"),
]

# ╔═╡ 61509dc2-29c8-4e32-bdd4-44ce05599d84
is_vowel(c::Char) = c ∈ "aeiou"

# ╔═╡ 498ae3d0-bd3c-4c35-8bf2-1ac430778e02
function has_three_vowels(s::String)
	@chain s begin
		split("")
		@. only
		@. is_vowel
		count
		≥(3)
	end
end

# ╔═╡ 4bb1dbdc-d40b-41f6-ac70-4e5490548ea3
has_three_vowels.(PDS_part1[1])

# ╔═╡ 3d93c944-2a2e-46e7-8cd0-e3f5c30e7b7e
function has_double_letters(s::String)
	@chain begin
		[s[x - 1] == s[x] for x ∈ 2:length(s)]
		any
	end
end

# ╔═╡ 0af3ae6e-f06f-4680-9b41-613ed4177b93
has_double_letters.(PDS_part1[1])

# ╔═╡ 10bf89bf-65b1-4beb-958d-a9b5cb00991c
function has_disallowed_substrings(s::String)
	@chain begin
		[s[(x - 1):x] ∈ ("ab", "cd", "pq", "xy") for x ∈ 2:length(s)]
		any
	end
end

# ╔═╡ 0eadbf73-76ea-4211-9ade-786eeb03836e
has_disallowed_substrings.(PDS_part1[1])

# ╔═╡ 980d04e6-7044-41f7-bbd9-666293038216
is_nice(s::String) = has_three_vowels(s) && has_double_letters(s) && !has_disallowed_substrings(s)

# ╔═╡ f53bd2c7-aa61-48ce-8ef9-ba7d3bb15cde
is_nice.(PDS_part1[1])

# ╔═╡ 4c4f78ee-b679-4597-9a0e-a01a2060f231
function result1(pd)
    @chain pd begin
        @. is_nice
		sum
    end
end

# ╔═╡ 5bdfe21f-9535-47f3-b162-5c63e49022ac
result1.(PDS_part1)

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

# ╔═╡ d9048bfa-f5b4-4257-b678-23755c97427e
# puzzle part 2 data samples
PDS_part2 = [
	parse_puzzle_file("sample2.txt"),
]

# ╔═╡ d948c397-6a68-4849-ae59-898bdc86f8de
function has_repeated_doubles(s::String)
	@chain begin
		[s[(x - 1):x] for x ∈ 2:length(s)]
		[
			_[i] == _[j]
			for i ∈ 1:length(_)
			for j ∈ (i + 2):length(_)
		]
		any
	end
end

# ╔═╡ 1099898f-f783-44dd-a16f-d70fa62f5255
has_repeated_doubles.(PDS_part2[1])

# ╔═╡ 933e8195-7fef-4b7f-ae80-c17896d44f81
function has_skipped_repetition(s::String)
	@chain begin
		[s[x - 2] == s[x] for x ∈ 3:length(s)]
		any
	end
end

# ╔═╡ 751edaf8-5b1e-4afd-baac-8408abda4d4f
has_skipped_repetition.(PDS_part2[1])

# ╔═╡ 62303755-9e9a-498c-b3ba-e94352c61132
is_new_nice(s::String) = has_repeated_doubles(s) && has_skipped_repetition(s)

# ╔═╡ e6938500-494f-4c3a-92e0-ba48fa360ec0
function result2(pd)
    @chain pd begin
        @. is_new_nice
		count
    end
end

# ╔═╡ b5d4cd00-4d5b-4ab5-8771-23e471badb57
result2.(PDS_part2)

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
# ╠═61509dc2-29c8-4e32-bdd4-44ce05599d84
# ╠═498ae3d0-bd3c-4c35-8bf2-1ac430778e02
# ╠═4bb1dbdc-d40b-41f6-ac70-4e5490548ea3
# ╠═3d93c944-2a2e-46e7-8cd0-e3f5c30e7b7e
# ╠═0af3ae6e-f06f-4680-9b41-613ed4177b93
# ╠═10bf89bf-65b1-4beb-958d-a9b5cb00991c
# ╠═0eadbf73-76ea-4211-9ade-786eeb03836e
# ╠═980d04e6-7044-41f7-bbd9-666293038216
# ╠═f53bd2c7-aa61-48ce-8ef9-ba7d3bb15cde
# ╠═4c4f78ee-b679-4597-9a0e-a01a2060f231
# ╠═5bdfe21f-9535-47f3-b162-5c63e49022ac
# ╟─451ff7c6-1e2f-4717-9c15-92760473609c
# ╠═0afa794b-17ef-4e24-a5de-caf2d4ff966e
# ╟─2bbaf7d3-5a27-43f6-b7e6-a737a4419406
# ╠═d9048bfa-f5b4-4257-b678-23755c97427e
# ╠═d948c397-6a68-4849-ae59-898bdc86f8de
# ╠═1099898f-f783-44dd-a16f-d70fa62f5255
# ╠═933e8195-7fef-4b7f-ae80-c17896d44f81
# ╠═751edaf8-5b1e-4afd-baac-8408abda4d4f
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
