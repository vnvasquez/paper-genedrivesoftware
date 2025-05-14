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

function read_csvs_to_dict(mypath::String, category::String)
    @show category
    result_dict = Dict{Symbol, Any}()
    csv_files = filter(x -> occursin("$(category)_", x), readdir(mypath))
    @show csv_files
    for file_name in csv_files
        @show file_name
        key = Symbol(replace(file_name, "$(category)_" => "", ".csv" => ""))
        df = CSV.read(joinpath(mypath, file_name), DataFrame)
        if ncol(df) == 1
            result_dict[key] = df[!, 1]
        else
            result_dict[key] = df
        end
    end
    return result_dict
end