# define solution method, solve 
tspan = (1, 365)
solver = OrdinaryDiffEq.Tsit5()
soldyn = solve_dynamic_model(node, solver, tspan);

# results 
results = format_dynamic_model_results(node, soldyn)
plot_dynamic_ridl_females(node, soldyn_opt)
