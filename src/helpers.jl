function write_dict_to_csv(mydict::Dict, category, mypath::String)
    for (key, value) in mydict
        name = "$(category)_$(key).csv"
        if key == :Time
            value = DataFrame(Time = value)
            CSV.write(joinpath(mypath,name), value)
        else
            value = mydict[key]
            CSV.write(joinpath(mypath,name), value)
        end
    end
end

function save_dynamic_solution(node::Node, sol1, title, mypath)
    results1 = format_dynamic_model_results(node, sol1)
    ridl_base_F_1_sol1 = []

    for k in keys(node.organisms)
        k = string(k)
        ridl_base_F_1_sol1 =
            results1[k]["Female"]["WW"][1, :] .+ results1[k]["Female"]["WR"][1, :] .+
            results1[k]["Female"]["RR"][1, :]
    end
    x = sol1.t[1:(end - 1)]                
    y = ridl_base_F_1_sol1[1:(end - 1)]   

    df = DataFrame(time = x, dynamics = y)
    CSV.write(joinpath(mypath, title * ".csv"), df)
    return x,y
end 


function Fig5ab_dynamics(node::Node, sol1, sol2, title, mypath)
    results1 = format_dynamic_model_results(node, sol1)
    results2 = format_dynamic_model_results(node, sol2)
    ridl_base_F_1_sol1 = []
    ridl_base_F_1_sol2 = []

    for k in keys(node.organisms)
        k = string(k)
        ridl_base_F_1_sol1 =
            results1[k]["Female"]["WW"][1, :] .+ results1[k]["Female"]["WR"][1, :] .+
            results1[k]["Female"]["RR"][1, :]
    end

    for k in keys(node.organisms)
        k = string(k)
        ridl_base_F_1_sol2 =
            results2[k]["Female"]["WW"][1, :] .+ results2[k]["Female"]["WR"][1, :] .+
            results2[k]["Female"]["RR"][1, :]
    end

    traces = PlotlyJS.GenericTrace{Dict{Symbol, Any}}[]
    push!(
        traces,
        PlotlyJS.scatter(;
            name="WW: MED", 
            x= timesteps = sol1.t[1:(end - 1)],
            y=ridl_base_F_1_sol1[1:(end - 1)],
            mode="lines",
            line_shape="linear",
            line_color="green",
            fillcolor="transparent",
            line_width=2,
            line_dash="dot",
        ),
    )
    push!(
        traces,
        PlotlyJS.scatter(;
            name="WW: HI", 
            x= timesteps = sol2.t[1:(end - 1)],
            y=ridl_base_F_1_sol2[1:(end - 1)],
            mode="lines",
            line_shape="linear",
            line_color="purple",
            fillcolor="transparent",
            line_width=2,
            line_dash="dashdot",
        ),
    )
    p = PlotlyJS.plot(
        traces,
        PlotlyJS.Layout(
            plot_bgcolor = "white",
            title=PlotlyJS.attr(text="$(title)", yanchor="top", x=0.5, xanchor="center"),
            xaxis_title="Time [Days]",
            yaxis_title="Population [Count]",
            width=800,
            height=450,
            font_size=12,
            fillcolor="transparent",
            xaxis=PlotlyJS.attr(tickfont_size=14,showgrid=true, showline = true, zeroline=false,
                gridcolor = "LightGray"),
            yaxis=PlotlyJS.attr(tickfont_size=14, yanchor = "center", y=0.5, zeroline=false,
                gridcolor = "LightGray", showgrid = true),
            legend=PlotlyJS.attr(
                yanchor="bottom",
                y=-0.35,
                xanchor="center",
                x=0.5,
                orientation="h",
                font_size=11.2,
            ),
        ),
    )
    savefig(p, joinpath(mypath, title * ".pdf"))
end