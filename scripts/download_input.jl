import HTTP
using UnPack
using ArgParse
using InteractiveUtils

function parse_commandline(args::Vector{String})
    s = ArgParseSettings()

    @add_arg_table s begin
        "--year", "-y"
        help = "Year of the event"
        required = true
        "--day", "-d"
        help = "Day of the event"
        required = true
    end

    return parse_args(args, s, as_symbols=true)
end

function (@main)(args::Vector{String})
    @unpack year, day = parse_commandline(args)

    # Check for SESSION_COOKIE
    if !haskey(ENV, "SESSION_COOKIE")
        println("Error: SESSION_COOKIE environment variable not set.")
        exit(1)
    end

    SESSION_COOKIE = ENV["SESSION_COOKIE"]

    url = "https://adventofcode.com/$(year)/day/$(day)/input"
    println((; url,))

    # Construct target directory
    # Assuming the script is run from the project root
    target_dir = joinpath("events", year, "day $day")
    println((; target_dir,))


    if !isdir(target_dir)
        println("Directory $target_dir does not exist. Creating it...")
        mkpath(target_dir)
    end

    target_file = joinpath(target_dir, "input.txt")
    println((; target_file,))

    if isfile(target_file)
        println("You already have `input.txt` at $(target_file)!")
    else
        println("Downloading input...")
        download_input_file(;
            url,
            session_cookie=SESSION_COOKIE,
            target_file,
            year,
            day,
        )
    end
end

function download_input_file(;
    url,
    session_cookie,
    target_file,
    year,
    day,
)
    try
        response = HTTP.get(url, headers=Dict("Cookie" => "session=$(session_cookie)"))

        if HTTP.status(response) == 200
            write(target_file, String(response.body))
            println("Downloaded input file for $year day $day to `$target_file`.")
        else
            println("Download unsuccessful. Status code: $(HTTP.status(response))")
        end
    catch e
        println("Error occurred during download: $e")
    end
end
