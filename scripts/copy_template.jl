using ArgParse
using UnPack

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

    # Construct target directory
    target_dir = joinpath("events", year, "day $day")
    println((; target_dir,))

    if !isdir(target_dir)
        println("Creating directory $target_dir...")
        mkpath(target_dir)
    end

    template_dir = joinpath("events", "day template")
    println("Copying template from $template_dir...")

    for file in readdir(template_dir)
        src = joinpath(template_dir, file)
        dst = joinpath(target_dir, file)

        if isfile(dst)
            println("Skipping $file (already exists)")
        else
            cp(src, dst)
            println("Copied $file")
        end
    end

    println("Done!")
end
