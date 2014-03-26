#!/usr/bin/env julia

using JSON
include("jenks.jl")

# load sample data
f = open("test.json")
data = convert(Vector{Float64}, JSON.parse(f))

# test runtime
jenks(data, 5)
@time jenks(data, 5)
