### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 090b4c81-9cda-42e4-a9ff-22fbf5844fa0
begin
	using Pkg
	Pkg.activate(Base.current_project())
end

# ╔═╡ e1a70f77-5002-4720-8ead-30a7ac2e63d6
using LinearAlgebra

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

# ╔═╡ 0b58ec7b-e60a-4415-8c04-a6dabdac11fb
function parse_wiring(s; len)
	xs = @chain s begin
		only
		split(",")
		@. parse(Int, _)
	end
	([i ∈ xs ? 1 : 0 for i ∈ 0:(len - 1)])
end

# ╔═╡ c45c51f2-cf17-4dad-9bae-1c1ff3133931
function parse_wirings(s; len)
	@chain s begin
		eachmatch(r"\((.+?)\)", _)
		parse_wiring.(_; len)
		cat(_...; dims = 2)
	end
end

# ╔═╡ 3835fe6f-a1c5-438c-a2db-467b2fb42ccb
function parse_target_joltages(s)
	@chain s begin
		split(",")
		@. parse(Int, _)
	end
end

# ╔═╡ afe15c3c-0a5f-4db4-8f72-bd22b0b7e27b
function parse_puzzle_line(s)
    @chain s begin
        match(r"\[(.+)\] (.+) {(.+)}", _)
		collect
		(
			target_lights = [c == '#' ? 1 : 0 for c ∈ _[1]],
			wirings = parse_wirings(_[2]; len = length(_[1])),
			target_joltages = parse_target_joltages(_[3]),
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

# ╔═╡ d30a47b2-b64a-463a-a6bb-d32f4b833467
apply_presses(presses) = foldl(.⊻, presses; init = zeros(Int, axes(presses[1])))

# ╔═╡ 849a1124-c243-4011-9ae7-1e71c0b5884f
function find_minimum_presses_for_light(target_lights::Vector{Int}, wirings::Matrix{Int})
	valid_presses = []
	for pressed_buttons in Combinatorics.powerset(1:size(wirings, 2), 1)
		actual_lights = apply_presses(eachslice(wirings[:, pressed_buttons]; dims = 2, drop = true))
		(actual_lights == target_lights) && push!(valid_presses, pressed_buttons)
	end
	@chain valid_presses begin
		@. length
		minimum
	end
end

# ╔═╡ 4c4f78ee-b679-4597-9a0e-a01a2060f231
function result1(pd)
	minimum_presses = [
		find_minimum_presses_for_light(target_lights, wirings)
		for (; target_lights, wirings) ∈ pd
	] |> sum
end

# ╔═╡ 5bdfe21f-9535-47f3-b162-5c63e49022ac
result1(PDS_part1)
# 7

# ╔═╡ 451ff7c6-1e2f-4717-9c15-92760473609c
md"""
### answer
"""

# ╔═╡ 0afa794b-17ef-4e24-a5de-caf2d4ff966e
@time @info(
    "part 1 answer",
    result1(PDI),
)
# my ans: 538

# ╔═╡ 2bbaf7d3-5a27-43f6-b7e6-a737a4419406
md"""
## Part 2
"""

# ╔═╡ d9048bfa-f5b4-4257-b678-23755c97427e
# puzzle part 2 data samples
PDS_part2 = parse_puzzle_file("sample1.txt")

# ╔═╡ 4abdc88d-6fc3-413d-99a3-e874aaca8b6d
[
	(
		dims = size(machine.wirings),
		rank = rank(machine.wirings),
		null = size(machine.wirings, 2) - rank(machine.wirings)
	)
	for machine ∈ PDI
]

# ╔═╡ 813c057d-6e23-4ac5-9f39-bf830c4adc51
find_max_press_count(machine) = machine.target_joltages |> maximum

# ╔═╡ 8da1236c-447f-4f2a-8248-82cee978ea35
find_max_press_count.(PDS_part2)

# ╔═╡ a70de2b1-495b-4aee-a3d0-f297d888eac1
function do_gaussian_elimination_on_steroid!(M::Matrix)
	offset = 0
    for j in 1:size(M, 2)
		current_i = j - offset
		(current_i > size(M, 1)) && break
        # Find pivot row
        pivot_row = current_i
        for i in (current_i + 1):size(M, 1)
            if abs(M[i, current_i]) > abs(M[pivot_row, current_i])
                pivot_row = i
            end
        end

		# Column is empty, cycle to the back
		if M[pivot_row, current_i] == 0
			(current_i + 1 ≥ size(M, 2)) && continue
			M[:, current_i:(size(M, 2) - 1)] = cat(M[:, (current_i + 1):(size(M, 2) - 1)], M[:, current_i]; dims = 2)
			offset += 1
			continue
		end

        # Swap rows if necessary (partial pivoting)
        if pivot_row != current_i
            M[current_i, :], M[pivot_row, :] = M[pivot_row, :], M[current_i, :]
        end

		# Normalize M[current_i, current_i]
		M[current_i, :] ./= M[current_i, current_i]
		
		# Eliminate elements around the pivot
		for i in 1:size(M, 1)
			(i == current_i) && continue
			factor = M[i, current_i]
			M[i, :] .-= factor .* M[current_i, :] # Use broadcasting for efficiency
		end
    end
	
    return M[[j for j ∈ axes(M, 1) if !all(M[j, :] .== 0)], :]
end

# ╔═╡ 513440a9-dcf2-4cdd-9f57-58cf4e0d3258
function do_gaussian_elimination_on_steroid(machine)
	M = Rational.(machine.wirings)
	b = (machine.target_joltages)
	do_gaussian_elimination_on_steroid!(cat(M, b; dims = 2))
end

# ╔═╡ 691af86d-cfdd-4b59-8576-e07380973ac1
do_gaussian_elimination_on_steroid.(PDS_part2)

# ╔═╡ c1ae95d5-88a6-4224-8da5-a55daf860bbf
do_gaussian_elimination_on_steroid.(PDI)

# ╔═╡ 3af2ffea-e149-40d0-a58a-7294ab6d05ed
function find_minimum_presses_for_joltage(machine)
	M = do_gaussian_elimination_on_steroid(machine)
	max_press_count = find_max_press_count(machine)
	m, n = size(M)
	eye = Matrix(LinearAlgebra.I, n - 1, n - 1)[(m + 1):end, :]

	press_counts = []
	for xs in Iterators.product([0:max_press_count for _ in axes(eye, 1)]...)
		full_M = cat(
			M,
			cat(eye, collect(xs); dims = 2),
			;
			dims = 1,
		)
		solved_press_count = do_gaussian_elimination_on_steroid!(full_M)[:, end]
		any(solved_press_count .< 0) && continue
		any(denominator.(solved_press_count) .!= 1) && continue
		
		push!(press_counts, numerator.(solved_press_count))
	end
	return @chain press_counts begin
		@. sum
		minimum
	end
end

# ╔═╡ e6938500-494f-4c3a-92e0-ba48fa360ec0
function result2(pd)
	@chain pd begin
		@. find_minimum_presses_for_joltage
		sum
	end
end

# ╔═╡ 46815b59-2e29-4a80-bb6b-ff81a03f3b81
result2(PDS_part2)
# 33

# ╔═╡ d496419e-572a-4fe7-9468-bd4d0be9e0c7
md"""
### answer
"""

# ╔═╡ 6cb8a5e4-d822-425e-ad9e-aeff375ad9ac
@time @info(
    "part 2 answer",
    result2(PDI),
)
# my ans: 20298
# takes 371 seconds to run

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
# ╠═c45c51f2-cf17-4dad-9bae-1c1ff3133931
# ╠═0b58ec7b-e60a-4415-8c04-a6dabdac11fb
# ╠═3835fe6f-a1c5-438c-a2db-467b2fb42ccb
# ╠═d97c6185-39c1-4d26-b2d2-66dd000c317b
# ╟─5436ac6a-5869-4b8d-9b9e-56e731589cbd
# ╠═e9fc4134-09f9-43b8-8066-24ab50a2f64c
# ╠═d30a47b2-b64a-463a-a6bb-d32f4b833467
# ╠═849a1124-c243-4011-9ae7-1e71c0b5884f
# ╠═4c4f78ee-b679-4597-9a0e-a01a2060f231
# ╠═5bdfe21f-9535-47f3-b162-5c63e49022ac
# ╟─451ff7c6-1e2f-4717-9c15-92760473609c
# ╠═0afa794b-17ef-4e24-a5de-caf2d4ff966e
# ╟─2bbaf7d3-5a27-43f6-b7e6-a737a4419406
# ╠═d9048bfa-f5b4-4257-b678-23755c97427e
# ╠═4abdc88d-6fc3-413d-99a3-e874aaca8b6d
# ╠═813c057d-6e23-4ac5-9f39-bf830c4adc51
# ╠═8da1236c-447f-4f2a-8248-82cee978ea35
# ╠═513440a9-dcf2-4cdd-9f57-58cf4e0d3258
# ╠═a70de2b1-495b-4aee-a3d0-f297d888eac1
# ╠═691af86d-cfdd-4b59-8576-e07380973ac1
# ╠═c1ae95d5-88a6-4224-8da5-a55daf860bbf
# ╠═e1a70f77-5002-4720-8ead-30a7ac2e63d6
# ╠═3af2ffea-e149-40d0-a58a-7294ab6d05ed
# ╠═e6938500-494f-4c3a-92e0-ba48fa360ec0
# ╠═46815b59-2e29-4a80-bb6b-ff81a03f3b81
# ╟─d496419e-572a-4fe7-9468-bd4d0be9e0c7
# ╠═6cb8a5e4-d822-425e-ad9e-aeff375ad9ac
# ╟─c366ad51-46da-47b4-af45-2d2374521857
# ╠═090b4c81-9cda-42e4-a9ff-22fbf5844fa0
# ╠═90815a37-6e8e-4c01-9e22-52dd96ab457b
# ╠═56736de4-cc48-11f0-a6b8-e199bea039a2
# ╠═3460a9d6-dec6-4791-bbbb-f081e253f7d9
# ╠═b405167e-613f-49ae-ad3d-30354d2c30a3
# ╠═edb226f3-ee5c-4c18-85d5-daf795014160
