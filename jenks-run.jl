#!/usr/bin/env julia

using JSON
include("jenks.jl")

# load sample data
f = open("test.json")
data = JSON.parse(f)

dc = Jenks.DataClassification(data,5)

# run once to exclude compilation time from runtime test
Jenks.jenks(dc)
# examine runtime
@time Jenks.jenks(dc)
