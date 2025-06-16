using GeneDrive
using OrdinaryDiffEq
using PlotlyJS
using Ipopt
using JuMP
using CSV
using DataFrames
using Statistics
import HSL_jll

############################################################################################
#   TEMPERATURE DATA
############################################################################################

evenodds = 1.0/6 # 100% evenly over 6 scenarios
probabilities = evenodds * [1, 1, 1, 1, 1, 1]

function row_averages(data::Matrix{Float64})
    avgs = Statistics.mean(data, dims=2)
    return avgs[:,1]
end

# historic
ext1997 = sort!(CSV.read(joinpath(@__DIR__, "..", "data","freqFINAL_heatwave_2031_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
ext1998 = sort!(CSV.read(joinpath(@__DIR__, "..", "data","freqFINAL_heatwave_2032_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
ext2001 = sort!(CSV.read(joinpath(@__DIR__, "..", "data","freqFINAL_heatwave_2035_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
ext2002 = sort!(CSV.read(joinpath(@__DIR__, "..", "data","freqFINAL_heatwave_2036_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
ext2003 = sort!(CSV.read(joinpath(@__DIR__, "..", "data","freqFINAL_heatwave_2037_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
ext2005 = sort!(CSV.read(joinpath(@__DIR__, "..", "data","freqFINAL_heatwave_2039_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
scenariomat_2000 = DataFrame( 
    ext1997 = ext1997,
    ext1998 = ext1998,
    ext2001 = ext2001,
    ext2002 = ext2002,
    ext2003 = ext2003,
    ext2005 = ext2005
    )
scenavg_2000 = row_averages(Matrix(scenariomat_2000))

# 2030s
ext2031 = sort!(CSV.read(joinpath(@__DIR__, "..", "data", "freqFINAL_heatwave_2031_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
ext2032 = sort!(CSV.read(joinpath(@__DIR__, "..", "data", "freqFINAL_heatwave_2032_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
ext2035 = sort!(CSV.read(joinpath(@__DIR__, "..", "data", "freqFINAL_heatwave_2035_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
ext2036 = sort!(CSV.read(joinpath(@__DIR__, "..", "data", "freqFINAL_heatwave_2036_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
ext2037 = sort!(CSV.read(joinpath(@__DIR__, "..", "data", "freqFINAL_heatwave_2037_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
ext2039 = sort!(CSV.read(joinpath(@__DIR__, "..", "data", "freqFINAL_heatwave_2039_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
scenariomat_2030 = DataFrame( 
    ext2031 = ext2031,
    ext2032 = ext2032,
    ext2035 = ext2035,
    ext2036 = ext2036,
    ext2037 = ext2037,
    ext2039 = ext2039
    )
scenavg_2030 = row_averages(Matrix(scenariomat_2030))

# variance: test on 2000
varmat_2000 = Statistics.var.(eachcol(scenariomat_2000))
cols = names(scenariomat_2000)
var_results = [(var=var, col=col) for (var, col) in zip(varmat_2000, cols)]
sorted_results = sort(var_results, by = x -> x.var)
highest_2000 = sorted_results[end]
lowest_2000 = sorted_results[1]
median_2000 = sorted_results[Int(round(length(sorted_results) / 2))]

# variance: test on 2030
varmat_2030 = Statistics.var.(eachcol(scenariomat_2030))
cols = names(scenariomat_2030)
var_results = [(var=var, col=col) for (var, col) in zip(varmat_2030, cols)]
sorted_results = sort(var_results, by = x -> x.var)
highest_2030 = sorted_results[end]
lowest_2030 = sorted_results[1]
median_2030 = sorted_results[Int(round(length(sorted_results) / 2))]

# assume same probability for all 
samescen2000 = ScenarioTemperature(Matrix(scenariomat_2000), probabilities);
samescen2030 = ScenarioTemperature(Matrix(scenariomat_2030), probabilities);

# assume "worst case" (highest variance = 50% probability)
newprobabilities_2000 = [0.1, 0.1, 0.1, 0.1, 0.1, 0.5]
newprobabilities_2030 = [0.1, 0.1, 0.1, 0.1, 0.1, 0.5]
newscen2000 = ScenarioTemperature(Matrix(scenariomat_2000), newprobabilities_2000);
newscen2030 = ScenarioTemperature(Matrix(scenariomat_2030), newprobabilities_2030);

############################################################################################
#  DATA MODEL: NODE/SPECIES/TECH/ALG 
############################################################################################

# particular to experiment
temperature = TimeSeriesTemperature(scenavg_2000) #ext2005)

# held constant
species = AedesAegypti
genetics = genetics_ridl()
enviro_response = stages_rossi();
update_population_size!(enviro_response, 500);
organisms = make_organisms(species, genetics, enviro_response);
coordinates = (1.0, 1.0);
node = Node(:NhaTrang, organisms, temperature, coordinates);
release_gene = get_homozygous_modified(node, species)
wild_gene = get_wildtype(node, species)
tspan = (1,365)

# algorithms 
i = JuMP.optimizer_with_attributes(Ipopt.Optimizer,
    "hsllib" => HSL_jll.libhsl_path, "linear_solver" =>  "ma86");
solver = OrdinaryDiffEq.Tsit5();

# objective 
abstract type ObjectiveFunction end
struct TargetPercentageByDate <: ObjectiveFunction end
function solve_decision_model_scenarios(model::JuMP.Model,
    objective_function::Type{<:TargetPercentageByDate};
    wildtype=nothing, percent_suppression=nothing, target_timestep=nothing)

    if isa(wildtype, Nothing) || isa(percent_suppression,Nothing) || isa(target_timestep,Nothing) 
        @warn("Model not solved because the objective function is missing information. Values must be supplied for all keyword arguments: `wildtype` (Int64), `percent_suppression (Float64), and `target_timestep` (Int64).")
    else
            control_M = model[:control_M]
            F = model[:F]
            control_F = model[:control_F]
            JuMP.fix.(control_F, 0.0; force=true)

            sets = model.obj_dict[:Sets]
            N = sets[:N]
            O = sets[:O]
            SF = sets[:SF]
            G = sets[:G]
            T = sets[:T]
            C = sets[:C]
            probabilities = model.ext[:Probabilities]

            JuMP.@objective(model, Min, (
                1e-8*sum(control_M) +
                sum(probabilities[n][c]*
                (F[n,c,o,s,wildtype,t] - percent_suppression*F[n,c,o,s,wildtype,1]).^2
            for n in N, c in C, o in O, s in SF, t in T[target_timestep:end]))
                )
            JuMP.optimize!(model);

            if termination_status(model) != OPTIMAL
                @info("Termination status: $(termination_status(model))")
                return model
            else
                println("Objective value:", objective_value(model))
            end

            return model
    end
end