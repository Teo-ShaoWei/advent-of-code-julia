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

# ╔═╡ 057c0011-8462-4d8e-b7fa-56e572a7ec97
make_area(::Type{TElement}) where {TElement} = zeros(TElement, 0:999, 0:999)

# ╔═╡ 92ac2ab8-c1d4-4a24-bea1-791e407bb14b
function toggle_area!(; area::AbstractMatrix{Bool}, coor1, coor2)::AbstractMatrix{Bool}
	area[make_smallest_boundary([coor1, coor2])...] .⊻= 1
	area
end

# ╔═╡ 061279da-6780-4296-85f2-cc4055a9c6f2
function apply_instruction!(area, (; op!, coor1, coor2))
	op!(; area, coor1, coor2)
	area
end

# ╔═╡ 084aa061-e93a-4d28-b023-e76d902f6e61
function apply_all_instructions(instructions; area_type = Bool)
	area = make_area(area_type)
	for instruction in instructions
		apply_instruction!(area, instruction)
	end
	area
end

# ╔═╡ 4c4f78ee-b679-4597-9a0e-a01a2060f231
function result1(pd)
	@chain pd begin
		apply_all_instructions
		count
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

# ╔═╡ c2198f22-10d3-492f-bb8f-8a530dd54657
decrease(x) = max(x - 1, 0)

# ╔═╡ d496419e-572a-4fe7-9468-bd4d0be9e0c7
md"""
### answer
"""

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

# ╔═╡ d504e7cd-47aa-470e-bb46-a4d2cdbf4bae
function turn_on_area!(; area::AbstractMatrix{Bool}, coor1, coor2)::AbstractMatrix{Bool}
	area[make_smallest_boundary([coor1, coor2])...] .|= 1
	area
end

# ╔═╡ f790539a-5e8d-4bed-927a-ac6dddbd027d
turn_on_area!(
	area = make_area(Bool),
	coor1 = CI(2, 5),
	coor2 = CI(1, 9),
)

# ╔═╡ ea55df1a-a147-490a-b8fd-89e895ab2032
function turn_off_area!(; area::AbstractMatrix{Bool}, coor1, coor2)::AbstractMatrix{Bool}
	area[make_smallest_boundary([coor1, coor2])...] .&= 0
	area
end

# ╔═╡ 692ff87c-1252-4e71-a24f-128cc6681092
function parse_op(s)
	(s == "turn on") && return turn_on_area!
	(s == "turn off") && return turn_off_area!
	return toggle_area!
end

# ╔═╡ afe15c3c-0a5f-4db4-8f72-bd22b0b7e27b
function parse_puzzle_line(s)
    @chain s begin
        match(r"(?<op>.+) (?<coor1>\d+,\d+) through (?<coor2>\d+,\d+)", _)
		NamedTuple
		(;
			op! = parse_op(_.op),
		 	coor1 = eval(Meta.parse("CI(" * _.coor1 * ")")),
		 	coor2 = eval(Meta.parse("CI(" * _.coor2 * ")")),
		)
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

# ╔═╡ 0afa794b-17ef-4e24-a5de-caf2d4ff966e
@time @info(
    "part 1 answer",
    result1(PDI),
)

# ╔═╡ e9fc4134-09f9-43b8-8066-24ab50a2f64c
# puzzle part 1 data samples
PDS_part1 = [
	parse_puzzle_file("sample1.txt"),
]

# ╔═╡ 5bdfe21f-9535-47f3-b162-5c63e49022ac
result1.(PDS_part1)

# ╔═╡ d9048bfa-f5b4-4257-b678-23755c97427e
# puzzle part 2 data samples
PDS_part2 = [
	parse_puzzle_file("sample1.txt"),
]

# ╔═╡ d2638404-b96d-4362-850f-98fd5dabd5be
macro pd_str(s::String)
    @chain s begin
        chomp
		string
        parse_puzzle_data
    end
end

# ╔═╡ 1c7698eb-48e4-4c60-b9c0-ea7123c2f01b
function turn_on_area_new!(; area::AbstractMatrix{Int}, coor1, coor2)
	area[make_smallest_boundary([coor1, coor2])...] .+= 1
	area
end

# ╔═╡ 8854698e-6546-42d3-bb8e-66d07e27f9f9
function turn_off_area_new!(; area::AbstractMatrix{Int}, coor1, coor2)
	area_view = @view area[make_smallest_boundary([coor1, coor2])...]
	@. area_view = max(area_view - 1, 0)
	area
end

# ╔═╡ ef83dca5-aacd-4cd3-908a-ae22d9db208b
function toggle_area_new!(; area::AbstractMatrix{Int}, coor1, coor2)
	area[make_smallest_boundary([coor1, coor2])...] .+= 2
	area
end

# ╔═╡ 12bc68ab-03ea-4d86-90df-53137436e838
function new_instruction((; op!, coor1, coor2))
	new_op! = if (Symbol(op!) == :turn_on_area!)
		turn_on_area_new!
	elseif (Symbol(op!) == :turn_off_area!)
		turn_off_area_new!
	else
		toggle_area_new!
	end
	return (; op! = new_op!, coor1, coor2)
end

# ╔═╡ e6938500-494f-4c3a-92e0-ba48fa360ec0
function result2(pd)
    @chain pd begin
        @. new_instruction
		apply_all_instructions(; area_type = Int)
		sum
    end
end

# ╔═╡ b5d4cd00-4d5b-4ab5-8771-23e471badb57
result2.(PDS_part2)

# ╔═╡ 6cb8a5e4-d822-425e-ad9e-aeff375ad9ac
@time @info(
    "part 2 answer",
    result2(PDI),
)

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
# ╠═692ff87c-1252-4e71-a24f-128cc6681092
# ╠═afe15c3c-0a5f-4db4-8f72-bd22b0b7e27b
# ╠═d97c6185-39c1-4d26-b2d2-66dd000c317b
# ╟─5436ac6a-5869-4b8d-9b9e-56e731589cbd
# ╠═e9fc4134-09f9-43b8-8066-24ab50a2f64c
# ╠═057c0011-8462-4d8e-b7fa-56e572a7ec97
# ╠═d504e7cd-47aa-470e-bb46-a4d2cdbf4bae
# ╠═f790539a-5e8d-4bed-927a-ac6dddbd027d
# ╠═ea55df1a-a147-490a-b8fd-89e895ab2032
# ╠═92ac2ab8-c1d4-4a24-bea1-791e407bb14b
# ╠═061279da-6780-4296-85f2-cc4055a9c6f2
# ╠═084aa061-e93a-4d28-b023-e76d902f6e61
# ╠═4c4f78ee-b679-4597-9a0e-a01a2060f231
# ╠═5bdfe21f-9535-47f3-b162-5c63e49022ac
# ╟─451ff7c6-1e2f-4717-9c15-92760473609c
# ╠═0afa794b-17ef-4e24-a5de-caf2d4ff966e
# ╟─2bbaf7d3-5a27-43f6-b7e6-a737a4419406
# ╠═d9048bfa-f5b4-4257-b678-23755c97427e
# ╠═12bc68ab-03ea-4d86-90df-53137436e838
# ╠═1c7698eb-48e4-4c60-b9c0-ea7123c2f01b
# ╠═c2198f22-10d3-492f-bb8f-8a530dd54657
# ╠═8854698e-6546-42d3-bb8e-66d07e27f9f9
# ╠═ef83dca5-aacd-4cd3-908a-ae22d9db208b
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
