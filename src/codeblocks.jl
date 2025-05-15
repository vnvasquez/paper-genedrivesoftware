##################################################################################
# Supplementary Information, Code Block 1: Creating the data model 
##################################################################################

# Select species type
species = AedesAegypti      

# Define how genetic information is passed on
genetics = genetics_ridl();                  

# Choose functional form of environmental response 
enviro_response = stages_rossi();                 

# Update population size 
update_population_size!(enviro_response, 500);                 

# Assemble organism
organisms = make_organisms(species, genetics, enviro_response); 

# Define ecological data
temperature = TimeSeriesTemperature(ext1997);          

# Specify the geographic coordinates
coordinates = (12.2534, 109.1871);  

# Define geographic type, name location, populate it
node = Node(:NhaTrang, organisms, temperature, coordinates); 

# Define the problem time horizon in days 
tspan = (1,365)         

##################################################################################
# Supplementary Information, Code Block 2: Creating and solving the dynamic model 
##################################################################################

# Select solver 
solver = OrdinaryDiffEq.Tsit5()              

# Parameterize problem and solve 
dynamic_sol = solve_dynamic_model(node, solver, tspan);      

# Format results for analysis
results_dyn = format_dynamic_model_results(node, dynamic_sol)    


##################################################################################
# Supplementary Information, Code Block 3: Creating and solving the decision model 
###################################################################################

# Code Block 3, Panel A:  Deterministic 
###################################################################################

# Create operational constraints 
org_constraints = ReleaseStrategy(release_this_gene_index = 3,   
    release_this_life_stage = Male, 
    release_time_interval = 7, 
    release_size_max_per_timestep = 50000.0)
    
# Assign operational constraints: organism & node of interest (organism = 1, node = 1) 
my_org_strat = [1 => org_constraints]            
my_node_strat = NodeStrategy(1, mystrategy)    
my_node_species = [species]    

# Select solver(s) 
i = JuMP.optimizer_with_attributes(Ipopt.Optimizer, 
    "linear_solver" => "ma86");  

# Parameterize problem 
deterministic_prob = create_decision_model(
    node, tspan; 
    node_strategy = my_node_strat, 
    node_species = my_node_species, 
    optimizer = i)   

# Solve using selected objective function (TargetPercentageByDate) 
detopt_sol = solve_decision_model_scenarios(
    deterministic_prob, 
    TargetPercentageByDate; 
    wildtype = 1,
    percent_suppression = .20, 
    target_timestep = 200) 

# Format all results for analysis
results_det = format_decision_model_results(detopt_sol)


# Code Block 3, Panel B: Stochastic 
###################################################################################

# Redefine temperature as multiple timeseries in a matrix
scenariomat_2000 = Matrix(DataFrame(
    ext1997,
    ext1998,
    ext2001,
    ext2002,
    ext2003,
    ext2005))
    
probabilities_2000 = [0.1, 0.1, 0.1, 0.1, 0.1, 0.5]

scenarios_2000 = ScenarioTemperature(
    scenariomat_2000, 
    probabilities_2000);    

# Update node with new data 
update_temperature!(node, ScenarioTemperature, scenarios_2000)

# Parameterize 
stochastic_prob = create_decision_model(
    node, 
    tspan; 
    node_strategy = my_node_strat, 
    node_species = my_node_species, 
    optimizer = i)   

# Solve 
stochopt_sol = solve_decision_model_scenarios(
    stochastic_prob, 
    TargetPercentageByDate; 
    wildtype = 1,
    percent_suppression = .20, 
    target_timestep = 200) 

# Format all results for analysis
results_stoch = format_decision_model_results(stochopt_sol)
