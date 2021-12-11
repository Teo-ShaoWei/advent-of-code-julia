# Advent of Code

How I approach Advent of Code using Julia.

As this is a timed event, the code is written in a way that is fast-to-write, but may not be easy-to-read. This is intentional, and help to remind me of how I can write for the subsequent years for speed.

# IDE
I mainly use Jupyter Notebook to handle data as it can visualize them easily. It is however not as fast to write code with especially if I want to do search-and-replace, and to ensure the latest function is evaluated. For that, I use VS Code. The source code file is then read into Jupyter Notebook using `Revise.jl` so it is hot-loaded.
