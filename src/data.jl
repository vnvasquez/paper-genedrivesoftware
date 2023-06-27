using GeneDrive
using OrdinaryDiffEq
using PlotlyJS
using Ipopt
using JuMP

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
ext1997 = sort!(CSV.read(joinpath(mypath,"freqFINAL_heatwave_2031_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
ext1998 = sort!(CSV.read(joinpath(mypath,"freqFINAL_heatwave_2032_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
ext2001 = sort!(CSV.read(joinpath(mypath,"freqFINAL_heatwave_2035_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
ext2002 = sort!(CSV.read(joinpath(mypath,"freqFINAL_heatwave_2036_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
ext2003 = sort!(CSV.read(joinpath(mypath,"freqFINAL_heatwave_2037_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
ext2005 = sort!(CSV.read(joinpath(mypath,"freqFINAL_heatwave_2039_85_2030_hg.csv"), DataFrame),[:DoY])[:,:TAVG];
scenariomat_2000 = DataFrame( # = hcat(
    ext1997 = ext1997,
    ext1998 = ext1998,
    ext2001 = ext2001,
    ext2002 = ext2002,
    ext2003 = ext2003,
    ext2005 = ext2005,
    )
    scenavg_2000 = row_averages(Matrix(scenariomat_2000))

# 2030s
ext2031 = sort!(CSV.read(joinpath(mypath, "freqFINAL_heatwave_2031_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
ext2032 = sort!(CSV.read(joinpath(mypath, "freqFINAL_heatwave_2032_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
ext2035 = sort!(CSV.read(joinpath(mypath, "freqFINAL_heatwave_2035_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
ext2036 = sort!(CSV.read(joinpath(mypath, "freqFINAL_heatwave_2036_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
ext2037 = sort!(CSV.read(joinpath(mypath, "freqFINAL_heatwave_2037_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
ext2039 = sort!(CSV.read(joinpath(mypath, "freqFINAL_heatwave_2039_85_2030_hg.csv"), DataFrame),[:DoY])[:,:futureHeatwave];
scenariomat_2030 = DataFrame( # = hcat(
    ext2031 = ext2031,
    ext2032 = ext2032,
    ext2035 = ext2035,
    ext2036 = ext2036,
    ext2037 = ext2037,
    ext2039 = ext2039,
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
update_population_size(enviro_response, 500);
organisms = make_organisms(species, genetics, enviro_response);
coordinates = (1.0, 1.0);
node = Node(:NhaTrang, organisms, temperature, coordinates);
release_gene = get_homozygous_modified(node, species)
wild_gene = get_wildtype(node, species)
tspan = (1,365)

# algorithms 
i = JuMP.optimizer_with_attributes(Ipopt.Optimizer,
    "linear_solver" =>  "ma86");
solver = OrdinaryDiffEq.Tsit5();