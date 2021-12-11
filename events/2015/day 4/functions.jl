using MD5

## Part 1

function result1(key)
    for i in Iterators.countfrom(1)
        s = key * string(i)
        h = md5(s) |> bytes2hex
        (h[1:5] == "00000") && return i
    end
end


## Part 2

function result2(key)
    for i in Iterators.countfrom(1)
        s = key * string(i)
        h = md5(s) |> bytes2hex
        (h[1:6] == "000000") && return i
    end
end
