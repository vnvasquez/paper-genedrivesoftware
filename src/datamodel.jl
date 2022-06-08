using GeneDrive
using OrdinaryDiffEq 
using PlotlyJS 
using Ipopt
using JuMP

species = AedesAegypti                                          
genetics = genetics_ridl();                                    
enviro_response = stages_rossi();                               
update_population_size(enviro_response, 500);                   
organisms = make_organisms(species, genetics, enviro_response); 
temperature = example_temperature_timeseries;                   
coordinates = (16.1820, 145.7210);                              
node = Node(:YorkeysKnob, organisms, temperature, coordinates); 

release_gene = get_homozygous_modified(node, species)
wild_gene = get_wildtype(node, species)

op_constraints = ReleaseStrategy(release_this_gene_index = release_gene,   
    release_this_life_stage = Male, 
    release_time_interval = 7, 
    release_start_time = 10, 
    release_size_max_per_timestep = 50000.0)
mystrategy = Dict(1 => op_constraints);