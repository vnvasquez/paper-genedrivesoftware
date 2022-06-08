# define optimizer, build problem 
i = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "linear_solver" => "pardiso");  
prob = GeneDrive.create_decision_model(node, tspan; node_strategy = mystrategy, 
    species = species, 
    optimizer = i)   

# zero objective, solve
soldec0 = GeneDrive.solve_decision_model(prob); 
plot_decision_ridl_females(soldec0)

# custom objective, solve 
soldec3 = solve_decision_model3(prob, TargetPercentageByDate; wildtype=wild_gene,
    percent_suppression=.40, target_timestep=200) 

# results of custom objective
results3 = format_decision_model_results(soldec3)
sum(results3[:node_1_organism_1_control_M].control_M_G3)
plot(results3[:node_1_organism_1_control_M].control_M_G3)

# compare decision and dynamic model output 
times, values = get_release_data(results3[:node_1_organism_1_control_M].control_M_G3)
releases = Release(node, species, Male, release_gene, times, values);                                                  
soldyn_opt1 = solve_dynamic_model(node, [releases], solver, tspan);  
results_optimalsched1 = format_dynamic_model_results(node, soldyn_opt1)