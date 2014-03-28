#!/usr/bin/env julia

using JSON
include("jenks.jl")

# load sample data
f = open("test.json")
data = JSON.parse(f)

# run once to exclude compilation time from runtime test
Jenks.jenks(data, 5)
# examine runtime
@time Jenks.jenks(data, 5)

