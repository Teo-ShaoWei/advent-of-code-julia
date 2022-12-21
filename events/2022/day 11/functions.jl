import Chain: @chain


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
        split("\n\n")
        @. parse_puzzle_group
        OffsetArray(-1)
    end
end

function parse_puzzle_group(s)
    lines = split(s, "\n")

    return (;
        worries = eval(Meta.parse("[$(lines[2][19:end])]")),
        op_string = lines[3][14:end],
        check = parse(Int, lines[4][22:end]),
        if_true = parse(Int, lines[5][30:end]),
        if_false = parse(Int, lines[6][31:end]),
    )
end


## Part 1

function make_op(op_string)
    @chain op_string begin
        replace("new =" => "old ->")
        Meta.parse
        eval
    end
end

function transform_monkeys_part1(monkeys::OffsetVector)
    transform_monkey_part1.(monkeys)
end

function transform_monkey_part1(monkey)
    return (;
        worries = copy(monkey.worries),
        op = make_op(monkey.op_string),
        monkey.check,
        monkey.if_true,
        monkey.if_false,
    )
end

function throw_item_part1!(monkeys, current_i)
    monkey = monkeys[current_i]
    worry = popfirst!(monkey.worries)

    worry = monkey.op(worry)
    worry ÷= 3

    target_i = (mod(worry, monkey.check) == 0) ? monkey.if_true : monkey.if_false
    push!(monkeys[target_i].worries, worry)
end

function next_monkey!(monkeys, current_i, inspect_counts::OffsetVector; throw_item_func!)
    worries = monkeys[current_i].worries
    while !isempty(worries)
        inspect_counts[current_i] += 1
        throw_item_func!(monkeys, current_i)
    end
end

function next_round!(monkeys, inspect_counts; throw_item_func!)
    for i in eachindex(monkeys)
        next_monkey!(monkeys, i, inspect_counts; throw_item_func!)
    end
end

function result1(monkeys)
    monkeys = deepcopy(monkeys)
    throw_item_func! = throw_item_part1!
    inspect_counts = map(x -> 0, monkeys)

    for _ in 1:20
        next_round!(monkeys, inspect_counts; throw_item_func!)
    end

    return @chain inspect_counts begin
        sort(; rev = true)
        OffsetArrays.no_offset_view
        _[1:2]
        prod
    end
end


## Part 2

function calculate_big_mod(monkeys)
    prod(m.check for m in monkeys)
end

function transform_monkeys_part2(monkeys::AbstractVector)
    big_mod = calculate_big_mod(monkeys)
    return transform_monkey_part2.(monkeys, big_mod)
end

function transform_monkey_part2(monkey, big_mod)
    return (;
        worries = [Mod{big_mod}(w) for w in monkey.worries],
        op = make_op(monkey.op_string),
        monkey.check,
        monkey.if_true,
        monkey.if_false,
    )
end

function throw_item_part2!(monkeys, current_i)
    monkey = monkeys[current_i]
    worry = popfirst!(monkey.worries)

    worry = monkey.op(worry)

    target_i = (mod(worry.val, monkey.check) == 0) ? monkey.if_true : monkey.if_false
    push!(monkeys[target_i].worries, worry)
end

function result2(monkeys)
    monkeys = deepcopy(monkeys)
    throw_item_func! = throw_item_part2!
    inspect_counts = map(x -> 0, monkeys)

    for _ in 1:10000
        next_round!(monkeys, inspect_counts; throw_item_func!)
    end

    return @chain inspect_counts begin
        sort(; rev = true)
        OffsetArrays.no_offset_view
        _[1:2]
        prod
    end
end
