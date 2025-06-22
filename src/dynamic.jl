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
soldyn_histMED = solve_dynamic_model(node_histmed, solver, tspan);

soldyn_futHI = solve_dynamic_model(node_futhigh, solver, tspan);
soldyn_futMED = solve_dynamic_model(node_futmed, solver, tspan);

# grab control schedules prescribed by optimization 
############################################################################################
#avgresults2000_target1 = read_csvs_to_dict(output_path, "histavgresults_target1")
# hist det
times1, values1 =
    get_release_data(avgresults2000_target1[:node_1_organism_1_control_M].control_M_G3);
releases1 = Release(node_histmed, species, Male, release_gene, times1, values1);
# hist stoch
times2, values2 =
    get_release_data(results2000_int7lim50k[:node_1_organism_1_control_M].control_M_G3);
releases2 = Release(node_histmed, species, Male, release_gene, times2, values2);
# fut det
times3, values3 =
    get_release_data(avgresults2030_target1[:node_1_organism_1_control_M].control_M_G3);
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
res_soldyn1med = format_dynamic_model_results(node_histmed, soldyn_1med);
write_dynamicdict_to_csv(res_soldyn1med, "res_soldyn1med", output_path)
# Access dynamic results by, e.g.: 
# read_csvs_to_dict(output_path, "res_soldyn1med")
# res_soldyn1med['AedesAegypti"]

soldyn_1hi = solve_dynamic_model(node_histhigh, [releases1], solver, tspan);
res_soldyn1hi = format_dynamic_model_results(node_histhigh, soldyn_1hi)
write_dynamicdict_to_csv(res_soldyn1hi, "res_soldyn1hi", output_path)

# hist stoch
soldyn_2med = solve_dynamic_model(node_histmed, [releases2], solver, tspan);
res_soldyn2med = format_dynamic_model_results(node_histmed, soldyn_2med);
write_dynamicdict_to_csv(res_soldyn2med, "res_soldyn2med", output_path)

soldyn_2hi = solve_dynamic_model(node_histhigh, [releases2], solver, tspan);
res_soldyn2hi = format_dynamic_model_results(node_histhigh, soldyn_2hi)
write_dynamicdict_to_csv(res_soldyn2hi, "res_soldyn2hi", output_path)

# fut det
soldyn_3med = solve_dynamic_model(node_futmed, [releases3], solver, tspan);
res_soldyn3med = format_dynamic_model_results(node_futmed, soldyn_3med)
write_dynamicdict_to_csv(res_soldyn3med, "res_soldyn3med", output_path)

soldyn_3hi = solve_dynamic_model(node_futhigh, [releases3], solver, tspan);
res_soldyn3hi = format_dynamic_model_results(node_futhigh, soldyn_3hi)
write_dynamicdict_to_csv(res_soldyn3hi, "res_soldyn3hi", output_path)

# fut stoch 
soldyn_4med = solve_dynamic_model(node_futmed, [releases4], solver, tspan);
res_soldyn4med = format_dynamic_model_results(node_futmed, soldyn_4med)
write_dynamicdict_to_csv(res_soldyn4med, "res_soldyn4med", output_path)

soldyn_4hi = solve_dynamic_model(node_futhigh, [releases4], solver, tspan);
res_soldyn4hi = format_dynamic_model_results(node_futhigh, soldyn_4hi)
write_dynamicdict_to_csv(res_soldyn4hi, "res_soldyn4hi", output_path)

# prob hist stoch 
newsoldyn_2hi = solve_dynamic_model(node_histhigh, [newreleases_hist], solver, tspan);
newres_soldyn2hi = format_dynamic_model_results(node_histhigh, newsoldyn_2hi)
write_dynamicdict_to_csv(newres_soldyn2hi, "newres_soldyn2hi", output_path)

# prob fut stoch 
newsoldyn_4hi = solve_dynamic_model(node_futhigh, [newreleases_fut], solver, tspan);
newres_soldyn4hi = format_dynamic_model_results(node_futhigh, newsoldyn_4hi)
write_dynamicdict_to_csv(newres_soldyn4hi, "newres_soldyn4hi", output_path)
