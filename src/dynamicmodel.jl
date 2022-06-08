tspan = (1,365)                                               
solver = OrdinaryDiffEq.Tsit5()                               
soldyn = solve_dynamic_model(node, solver, tspan);           
results = format_dynamic_model_results(node, soldyn) 