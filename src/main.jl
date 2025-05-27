import Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
Pkg.instantiate()
output_path = joinpath(@__DIR__, "..", "output")
mkpath(output_path)  # Ensure exists

include("data.jl")
include("helpers.jl")
include("decision.jl")
include("dynamic.jl")
include("codeblocks.jl")
