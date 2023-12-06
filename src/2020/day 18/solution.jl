### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 25da558e-41b1-11eb-2e6f-03d528b70f1e
using Lazy

# ╔═╡ 28670e26-40fa-11eb-1385-e38addb7fd5b
function parse_input(filename)
	readlines(filename)
end

# ╔═╡ 30528a5a-40fa-11eb-3064-610b36009e26
in1 = parse_input("in_s1.txt")

# ╔═╡ 31fce28c-40fa-11eb-2514-bd7a3a527618
inp = parse_input("in_p.txt")

# ╔═╡ 9bf3d826-41af-11eb-0c55-3508c285e3c5
data = inp

# ╔═╡ 7d49c2ea-41b0-11eb-2cbe-a307103a8ac2
⊞(x, y) = x * y

# ╔═╡ 42ecea32-41b0-11eb-31f0-cfcf46cc3195
≎(x, y) = x * y

# ╔═╡ d8e68f98-41b2-11eb-21c1-113d4cf796c8
data1 = data .|> function(d)
	@as d d begin
		@> begin
			d
			replace("*" => "⊞")
			Meta.parse
			eval
		end
	end
end

# ╔═╡ 929a7e2c-4113-11eb-04af-d9cb15c08cc9
sum(data1)

# ╔═╡ c6d8e9e4-4113-11eb-2963-b9791aa7f8a2
replace(data1[2], "*" => "≎")

# ╔═╡ a3ef1b1a-4113-11eb-17a6-7f22c44d60c4


# ╔═╡ 6e21fbec-4113-11eb-1c3f-190fa6c0a23d


# ╔═╡ Cell order:
# ╠═25da558e-41b1-11eb-2e6f-03d528b70f1e
# ╠═28670e26-40fa-11eb-1385-e38addb7fd5b
# ╠═30528a5a-40fa-11eb-3064-610b36009e26
# ╠═31fce28c-40fa-11eb-2514-bd7a3a527618
# ╠═9bf3d826-41af-11eb-0c55-3508c285e3c5
# ╠═7d49c2ea-41b0-11eb-2cbe-a307103a8ac2
# ╠═42ecea32-41b0-11eb-31f0-cfcf46cc3195
# ╠═d8e68f98-41b2-11eb-21c1-113d4cf796c8
# ╠═929a7e2c-4113-11eb-04af-d9cb15c08cc9
# ╠═c6d8e9e4-4113-11eb-2963-b9791aa7f8a2
# ╠═a3ef1b1a-4113-11eb-17a6-7f22c44d60c4
# ╠═6e21fbec-4113-11eb-1c3f-190fa6c0a23d
