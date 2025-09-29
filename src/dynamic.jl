############################################################################################
#  DYNAMIC SIMULATION 
############################################################################################

# update temp per experiment 
node_histmed = Node(:NhaTrang, organisms, TimeSeriesTemperature(ext1997), coordinates);
node_histhigh = Node(:NhaTrang, organisms, TimeSeriesTemperature(ext2005), coordinates);

node_futmed = Node(:NhaTrang, organisms, TimeSeriesTemperature(ext2037), coordinates);
node_futhigh = Node(:NhaTrang, organisms, TimeSeriesTemperature(ext2039), coordinates);

# natural pop fluctuations (no intervention)
soldyn_histHI = solve_dynamic_model(node_histhigh, solver, tspan);
save_dynamic_solution(node_histhigh, soldyn_histHI, "res_soldyn0histhi", output_path)

soldyn_histMED = solve_dynamic_model(node_histmed, solver, tspan);
save_dynamic_solution(node_histmed, soldyn_histMED, "res_soldyn0histmed", output_path)

soldyn_futHI = solve_dynamic_model(node_futhigh, solver, tspan);
save_dynamic_solution(node_futhigh, soldyn_futHI, "res_soldyn0futhi", output_path)

soldyn_futMED = solve_dynamic_model(node_futmed, solver, tspan);
save_dynamic_solution(node_futmed, soldyn_futMED, "res_soldyn0futmed", output_path)

# include baseline dynamic figure (Fig5a, Fig5b)
title_Fig5a = "Fig5a: Historical Temperature Regimes (Natural Dynamics)"
Fig5ab_dynamics(node, soldyn_histMED, soldyn_histHI, title_Fig5a, output_path)

title_Fig5b = "Fig5b: Future Temperature Regimes (Natural Dynamics)"
Fig5ab_dynamics(node, soldyn_futMED, soldyn_futHI, title_Fig5b, output_path)

# grab control schedules prescribed by optimization 
############################################################################################
# hist det
times1, values1 =
    get_release_data(resultshistavg_target1[:node_1_organism_1_control_M].control_M_G3);
releases1 = Release(node_histmed, species, Male, release_gene, times1, values1);
# hist stoch
times2, values2 =
    get_release_data(results2000_int7lim50k[:node_1_organism_1_control_M].control_M_G3);
releases2 = Release(node_histmed, species, Male, release_gene, times2, values2);
# fut det
times3, values3 =
    get_release_data(resultsfutavg_target1_2030[:node_1_organism_1_control_M].control_M_G3);
releases3 = Release(node_futmed, species, Male, release_gene, times3, values3);
# fut stoch
times4, values4 =
    get_release_data(results2030_int7lim50k[:node_1_organism_1_control_M].control_M_G3);
releases4 = Release(node_futmed, species, Male, release_gene, times4, values4);
# prob hist stoch 
newtimes_hist, newvals_hist =
    get_release_data(newresults2000_int7lim50k[:node_1_organism_1_control_M].control_M_G3);
newreleases_hist =
    Release(node_histhigh, species, Male, release_gene, newtimes_hist, newvals_hist);
# prob fut stoch 
newtimes_fut, newvals_fut =
    get_release_data(newresults2030_int7lim50k[:node_1_organism_1_control_M].control_M_G3);
newreleases_fut =
    Release(node_futhigh, species, Male, release_gene, newtimes_fut, newvals_fut);

# run dynamics with controls 
############################################################################################
# hist det 
soldyn_1med = solve_dynamic_model(node_histmed, [releases1], solver, tspan);
save_dynamic_solution(node_histmed, soldyn_1med, "res_soldyn1med", output_path)

soldyn_1hi = solve_dynamic_model(node_histhigh, [releases1], solver, tspan);
save_dynamic_solution(node_histhigh, soldyn_1hi, "res_soldyn1hi", output_path)

# hist stoch
soldyn_2med = solve_dynamic_model(node_histmed, [releases2], solver, tspan);
save_dynamic_solution(node_histmed, soldyn_2med, "res_soldyn2med", output_path)

soldyn_2hi = solve_dynamic_model(node_histhigh, [releases2], solver, tspan);
save_dynamic_solution(node_histhigh, soldyn_2hi, "res_soldyn2hi", output_path)

# prob hist stoch 
newsoldyn_2hi = solve_dynamic_model(node_histhigh, [newreleases_hist], solver, tspan);
save_dynamic_solution(node_histhigh, newsoldyn_2hi, "newres_soldyn2hi", output_path)

# fut det
soldyn_3med = solve_dynamic_model(node_futmed, [releases3], solver, tspan);
save_dynamic_solution(node_futmed, soldyn_3med, "res_soldyn3med", output_path)

soldyn_3hi = solve_dynamic_model(node_futhigh, [releases3], solver, tspan);
save_dynamic_solution(node_futhigh, soldyn_3hi, "res_soldyn3hi", output_path)

# fut stoch 
soldyn_4med = solve_dynamic_model(node_futmed, [releases4], solver, tspan);
save_dynamic_solution(node_futmed, soldyn_4med, "res_soldyn4med", output_path)

soldyn_4hi = solve_dynamic_model(node_futhigh, [releases4], solver, tspan);
save_dynamic_solution(node_futhigh, soldyn_4hi, "res_soldyn4hi", output_path)

# prob fut stoch 
newsoldyn_4hi = solve_dynamic_model(node_futhigh, [newreleases_fut], solver, tspan);
save_dynamic_solution(node_futhigh, newsoldyn_4hi, "newres_soldyn4hi", output_path)
