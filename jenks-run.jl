#!/usr/bin/env julia

using JSON
include("jenks.jl")

# load sample data
f = open("test.json")
data = JSON.parse(f)

# test runtime
@time begin
  jenks(data, 5)
end
