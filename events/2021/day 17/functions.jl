using Chain


## Helpers

CI = CartesianIndex
CIS = CartesianIndices

Base.show(io::IO, ::MIME"text/plain", c::Char) = print(io, string(c))


## Parse input

function parse_input(filename::String)
    @chain filename begin
        readchomp
        @. parse_line
    end
end

function parse_line(line)
    @chain line begin
        match(r"target area: x=(.+)\.\.(.+), y=(.+)\.\.(.+)", _)
        collect
        parse.(Int, _)
        (_[1]:_[2], _[3]:_[4])
    end
end


## Part 1

function tri(x)
    x * (x - 1) ÷ 2
end

function get_ypos(yvel0, t)
    t * yvel0 - tri(t)
end

function get_xpos(xvel0, t)
    if t < xvel0
        return t * xvel0 - tri(t)
    else
        return tri(xvel0 + 1)
    end
end

function get_t_min_bound(yvel0, ytarget)
    ypos_upper_bound = last(ytarget)
    for t in Iterators.countfrom(1)
        if get_ypos(yvel0, t) ≤ ypos_upper_bound
            return t
        end
    end
end

function get_t_max_bound(yvel0, ytarget)
    ypos_lower_bound = first(ytarget)
    for t in Iterators.countfrom(1)
        if get_ypos(yvel0, t) < ypos_lower_bound
            return t - 1
        end
    end
end

function get_t_bound(yvel0, ytarget)
    get_t_min_bound(yvel0, ytarget):get_t_max_bound(yvel0, ytarget)
end

"""
The assumption in the sample and input is that the target has negative y range, and positive x range.
We sort by larger y velocity first.
"""
function possible_vel0s((xtarget, ytarget))
    ((xvel, yvel) for yvel in -first(ytarget):-1:first(ytarget) for xvel in 1:last(xtarget))
end

function max_height(yvel0)
    max(0, tri(yvel0 + 1))
end

function hit_target((xvel0, yvel0), (xtarget, ytarget))
    any(get_xpos(xvel0, t) ∈ xtarget for t in get_t_bound(yvel0, ytarget))
end

function result1(xytarget)
    for (xvel0, yvel0) in possible_vel0s(xytarget)
        if hit_target((xvel0, yvel0), xytarget)
            return max_height(yvel0)
        end
    end
end


## Part 2

function result2(xytarget)
    count(hit_target((xvel0, yvel0), xytarget) for (xvel0, yvel0) in possible_vel0s(xytarget))
end
