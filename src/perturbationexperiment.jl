
# perturb temperature inputs
hotter_temperature = perturb_temperature_timeseries(temperature, 2.0);

# build and solve new dynamic model 
node_PERT = Node(:YorkeysKnob, organisms, hotter_temperature, coordinates);
soldyn_PERT = solve_dynamic_model(node_PERT, [releases], solver, tspan);

# build and solve new decision model
prob_PERT = create_decision_model(
    node_PERT,
    tspan;
    node_strategy=mystrategy,
    species=species,
    optimizer=i,
)
soldec4 = solve_decision_model3(
    prob_PERT,
    TargetPercentageByDate;
    wildtype=wild_gene,
    percent_suppression=0.40,
    target_timestep=200,
)

# results, new decision model
plot_decision_ridl_females(soldec4)
results4 = format_decision_model_results(soldec4)
sum(results4[:node_1_organism_1_control_M].control_M_G3)
plot(results4[:node_1_organism_1_control_M].control_M_G3)

# apply new optimized strategy in new dynamic model 
times, values = get_release_data(results4[:node_1_organism_1_control_M].control_M_G3)
releases2 = Release(node_PERT, species, Male, release_gene, times, values);
soldyn_opt2 = solve_dynamic_model(node_PERT, [releases2], solver, tspan);

# results, new dynamic model 
results_optimalsched1 = format_dynamic_model_results(node_PERT, soldyn_opt2)
plot_dynamic_ridl_females(node_PERT, soldyn_opt2)
