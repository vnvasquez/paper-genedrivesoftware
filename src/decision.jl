############################################################################################
#  OPTIMIZATION: DETERMINISTIC (both freq + vol constraints)
############################################################################################

# update temp per experiment 
temperature_2030avg = TimeSeriesTemperature(scenavg_2030)
node = Node(:NhaTrang, organisms, temperature_2030avg, coordinates);

# decision model: target1 (freq = 7), target2 (freq = 14)
org_constraints1 = ReleaseStrategy(
    release_this_gene_index=release_gene,
    release_this_life_stage=Male,
    release_time_interval=14, # freq
    release_size_max_per_timestep=50000.0, # vol
);
my_org_strat1 = [1 => org_constraints1]            
my_node_strat = NodeStrategy(1, my_org_strat1)    
my_node_species = [species]                     

prob = GeneDrive.create_decision_model(         
    node,
    tspan;
    node_strategy=my_node_strat, 
    node_species=my_node_species, 
    optimizer=i,
    slack_small=false,
);

soldec_target1 = solve_decision_model_scenarios(
    prob,
    TargetPercentageByDate;
    wildtype=wild_gene,
    percent_suppression=0.20,
    target_timestep=200,
)

# save target1
resultshistavg_target1 = GeneDrive.format_decision_model_results(soldec_target1)
write_dict_to_csv(resultshistavg_target1, "histavgresults_target1", output_path)

resultsfutavg_target1_2030 = GeneDrive.format_decision_model_results(soldec_target1_2030)
write_dict_to_csv(resultsfutavg_target1_2030, "futavgresults2030_target1", output_path)

# save target2
resultshistavg_target2 = GeneDrive.format_decision_model_results(soldec_target2)
write_dict_to_csv(resultshistavg_target2, "histavgresults_target2", output_path)

resultsfutavg_target2_2030 = GeneDrive.format_decision_model_results(soldec_target2_2030)
write_dict_to_csv(resultsfutavg_target2_2030, "futavgresults2030_target2", output_path)

# grab as needed 
avgresults2000_target1 = read_csvs_to_dict(output_path, "histavgresults_target1")
avgresults2030_target1 = read_csvs_to_dict(output_path, "futavgresults2030_target1")

avgresults2000_target2 = read_csvs_to_dict(output_path, "histavgresults_target2")
avgresults2030_target2 = read_csvs_to_dict(output_path, "futavgresults2030_target2")

############################################################################################
#  OPTIMIZATION: STOCHASTIC (both freq + vol constraints)
############################################################################################

# update temp per experiment 
node = Node(:NhaTrang, organisms, newscen2000, coordinates);

# decision model
org_constraints = ReleaseStrategy(
    release_this_gene_index=release_gene,
    release_this_life_stage=Male,
    release_time_interval=7,
    release_size_max_per_timestep=50000.0,
);
my_org_strat = [1 => org_constraints]            
my_node_strat = NodeStrategy(1, my_org_strat)    
my_node_species = [species]    

prob = GeneDrive.create_decision_model(
    node,
    tspan;
    node_strategy=my_node_strat,
    node_species=my_node_species,
    optimizer=i,
    slack_small=true,
);

sol_newscen2000_int7lim50k = solve_decision_model_scenarios(
    prob,
    TargetPercentageByDate;
    wildtype=wild_gene,
    percent_suppression=0.20,
    target_timestep=200,
)

# save: freq = 7, vol = 50k 
results2000_int7lim50k = GeneDrive.format_decision_model_results(sol_2000_int7lim50k)
results2030_int7lim50k = GeneDrive.format_decision_model_results(sol_2030_int7lim50k)

# save: highest prob = most variable year
newresults2000_int7lim50k =
    GeneDrive.format_decision_model_results(sol_newscen2000_int7lim50k)
newresults2030_int7lim50k =
    GeneDrive.format_decision_model_results(sol_newscen2030_int7lim50k)

# grab as needed 
results2000_int7lim50k = read_csvs_to_dict(output_path, "results2000_int7lim50k")
results2030_int7lim50k = read_csvs_to_dict(output_path, "results2030_int7lim50k")

newresults2000_int7lim50k = read_csvs_to_dict(output_path, "newresults2000_int7lim50k")
newresults2030_int7lim50k = read_csvs_to_dict(output_path, "newresults2030_int7lim50k")
