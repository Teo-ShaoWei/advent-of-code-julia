using Chain


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
        split(": ")
        _[2]
        split(" | ")
        @. parse_numbers
        (winning = _[1], have = _[2])
    end
end

function parse_numbers(s)
    n = (length(s) + 1) ÷ 3
    map(1:n) do i
        parse(Int, s[(3 * i - 2):(3 * i - 1)])
    end
end


## Part 1

function get_self_winning_numbers(card)
    [n for n in card.have if n ∈ card.winning]
end

function result1(pd)
    @chain pd begin
        @. get_self_winning_numbers
        @. length
        [n == 0 ? 0 : 2 ^ (n - 1) for n in _]
        sum
    end
end


## Part 2

function process_card!(counts, i, card)
    winning_count = length(get_self_winning_numbers(card))
    for k in (i + 1):(i + winning_count)
        counts[k] += counts[i]
    end
    return counts
end

function result2(cards)
    counts = [1 for _ in cards]
    for (i, card) in enumerate(cards)
        process_card!(counts, i, card)
    end
    sum(counts)
end
