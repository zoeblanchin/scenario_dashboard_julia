import Pkg
Pkg.activate(".")
using DataFrames
using JSON3
using GeoJSON
using CSV
include("..//config//layout_config.jl")
# using for the different useful functions should be added

function read_geojson_file()
    cd("C:\\Users\\zoeb\\Documents\\scenario_dashboard\\scenario_dashboard_julia\\config")
    fp = JSON3.read(read("geolocation.json"))
    return fp
end

mutable struct DataRaw
    directory
    key::String
    sector::String
    df
end

DataRaw(directory, key, sector = "Power") = DataRaw(directory, key_to_julia[key], sector, read_sol_file(directory,key_to_julia[key]))

function read_sol_file(directory, key::String)
    # reading the sol file and creating a dataframe with only strings adn with the correct column names
    f = open(directory, "r")
    col_names = header_mapping[key]["columns"]
    df = DataFrame([col_names[i] => String[] for i in 1:length(col_names)])
    break_flag = false
    enter_first = false
    enter_second = false
    
    # TotalTradeCapacity is juste once in the sol file
    if key == "TotalTradeCapacity"
        enter_second = true
    end

    for (i,line) in enumerate(eachline(f))
        if startswith(line, key) && enter_second
            split1 = split(line, "[")[2]
            split2 = split(split1, "]")[1]
            split3 = split(split2, ",")
            split3 = String.(reduce(vcat, split3))
            value = last(split(line, " "))
            push!(split3, value)
            push!(df, split3)
            break_flag = true 
        elseif startswith(line, key) && !enter_first
            enter_first = true
        elseif !startswith(line, key) && !break_flag && enter_first
            enter_second = true
        elseif break_flag
            break
        end
    end

    
    return create_df(df, key)
end

function filter_sector(self::DataRaw)
    # filter only power sector technologies
    # to more dynamic user input

    # to remove
    cd("C:\\Users\\zoeb\\Documents\\scenario_dashboard\\scenario_dashboard_julia\\data")

    df_input = CSV.read("Tag_Technology_to_Sector.csv", DataFrame; types = Dict(:Technology => String, :Sector => String), delim=";")
    self.df = innerjoin(df_input, self.df, on=:Technology)
    if self.sector == "Power"
        self.df = self.df[coalesce.(in.(self.df.Sector, Ref(["Power", "Storages"])), false),:]
    else
        self.df = self.df[coalesce.(self.df.Sector .== self.sector, false)]
    end

    return self.df
end

function aggregate_technologies(self::DataRaw)
    # Aggregating some technologies together and summing the corresponding values
    replace!(self.df.Technology, aggregation...)
    col_names = copy(header_mapping[self.key]["columns"])
    pop!(col_names)
    grouped_df = groupby(self.df, col_names)
    self.df = combine(grouped_df, :Value => sum=>:Value)
    return self.df
end

function create_df(raw_df, key)
    # making numeric valyes for Year and Value columns
    raw_df.Value_num = passmissing(parse).(Float64, raw_df.Value)
    raw_df.Year_num = passmissing(parse).(Int64, raw_df.Year)
    DataFrames.select!(raw_df, Not(:Value))
    DataFrames.select!(raw_df, Not(:Year))
    rename!(raw_df, :Value_num=>:Value)
    rename!(raw_df, :Year_num=>:Year)

    df = mapcols(col->replace(col,missing=>NaN),raw_df)

    # convert unit if required from PJ to TWh
    if key in ["ProductionByTechnologyAnnual", "Export", "UseAnnual"]
        df.Value .= round.(df.Value/3.6, digits=0)
    # remove x from nodes
    # for c in eachcol(select(df, Cols(startswith.("Region"))))
    # end
    end
    
    return df
end

function aggregate_regions(self::DataRaw)
    # aggregate regions & offshore nodes
end

function replace_offshore(self::DataRaw)
end

function aggregate_column(self::DataRaw, column::String, method="sum")
    agg_cols = names(self.df, Not([column, "Value"]))
    if method == "sum"
        grouped_df = groupby(self.df, agg_cols)
        self.df = combine(grouped_df, :Value => sum=>:Value)
    elseif method == "max"
        grouped_df = groupby(self.df, agg_cols)
        self.df = combine(grouped_df, :Value => maximum =>:Value)
    end
end

function filter_column(self::DataRaw, column, by_filter)
    # filter column with the filter by_filter
    # self.df = self.df[coalesce.(in.(self.df[!,column], by_filter), false)]
    self.df = filter(column => in(by_filter), self.df)
    sort_reindex_values(self)
end

function sort_reindex_values(self::DataRaw)
    # sort the value by ascending order
    sort!(self.df, :Value)
    # no need to reindex
end

function pivot_table(self::DataRaw)
    new_df_tmp = unstack(self.df, :Region1, :Value)
    new_df = new_df_tmp[:,Not([:Fuel, :Year])]
    self.df = mapcols(col->replace(col,missing=>0),new_df)
end




