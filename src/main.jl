import Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
Pkg.instantiate()

include("data.jl")
include("decision.jl")
include("dynamic.jl")
