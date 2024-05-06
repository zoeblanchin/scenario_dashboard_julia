using DataFrames
using PlotlyJS
using Plots
using Colors
using ColorSchemes
include("..//config//layout_config.jl")
include("..//data//data_class.jl")

mutable struct PlotObject
    df_list
    year
    key
    sector::String
    scenarios
    color_to_tech
end

PlotObject(key, 
            df_list, 
            scenarios,
            year=nothing, 
            sector="Power") = PlotObject(df_list, 
                                        isnothing(year) ? unique(df_list[1].Year) : year,
                                        key_to_julia[key],
                                        sector,
                                        scenarios,
                                        key in ["trade_map", "hydrogen_infrastructure", "export"] ? "" : create_col_palette(df_list)
                                        )

function create_col_palette(df_list)
    additional_colors = palette(:tab20)
    technology_list = []

    for df in df_list
        technology_list = vcat(technology_list, unique(df.Technology))
    end

    expanded_colour_dict = Dict()
    i = 1
    for technology in unique(technology_list)
        if technology in keys(colour_codes)
            expanded_colour_dict[technology] = colour_codes[technology]
        else
            expanded_colour_dict[technology] = additional_colors[i%20+1]
            i = i+1
        end
    end

    return expanded_colour_dict

end

function stacked_bar_integrated(self::PlotObject, aggregation=true)
    titles = map(String,"$(self.key)_$(y)_$(self.sector)" for y in self.year, i=1:1)
    fig = make_subplots(rows=length(self.year),
                        cols=1,
                        subplot_titles=titles
    )
    
    for (df,s) in zip(self.df_list, self.scenarios)
        region_col = "Region"
        if (aggregation==true)
            grouped_df = groupby(df, ["Year", "Technology", "Region"])
            df = combine(grouped_df, :Value => sum=>:Value)
            region_col = "Region"
        end
        df.Scenario .= s
        for (j,y) in enumerate(self.year)
            for t in unique(df[df[!,:Year].== y,:].Technology)
                subset_df = df[(df.Year.==y) .&& (df.Technology.==t),:]
                x_region = subset_df[:,region_col]
                x_scenario = subset_df[:,:Scenario]
                y_value = subset_df.Value
                add_trace!(fig, PlotlyJS.bar(x=[x_region, x_scenario], y=y_value, name=t, marker_color=self.color_to_tech[t], legendgroup=t, showlegend= (j==1)), row=j, col=1)
            end
        end
    end
    relayout!(fig, barmode="stack", height=2700, font=Dict(:size=>26), yaxis_title=header_mapping[self.key]["units"])
    return fig
end

function stacked_bar_side(self::PlotObject, x="Year")
    # make subplot titles
    region_list = unique([i for df in self.df_list for i in df.Region])
    titles = map(String,"$(r)_$(s)" for r in region_list, s in self.scenarios)
    fig = make_subplots(rows=length(region_list),
                        cols=length(self.scenarios),
                        subplot_titles=titles
    )
    
    for (i,df) in enumerate(self.df_list)
        for (j,r) in enumerate(region_list)
            # check if region is in data
            if r in df.Region
                # sum and sort
                df_region = df[df[!,:Region].==r,:]
                grouped_df = groupby(df_region, ["Technology"])
                df_region = combine(grouped_df, :Value => sum=>:Value)
                sort!(df_region, :Value)
                technologies = unique(df_region.Technology)

                for t in technologies
                    subset_df = df[(df.Region.==r) .&& (df.Technology.==t),:]
                    xx = subset_df[:,x]
                    y_value = subset_df.Value
                    add_trace!(fig, PlotlyJS.scatter(x=xx, 
                                        y=y_value, 
                                        name=t,
                                        mode="lines",
                                        fillcolor=self.color_to_tech[t],
                                        line_color=self.color_to_tech[t],
                                        legendgroup=t,
                                        stackgroup=r,
                                        showlegend= (j==2)
                                        ),
                                        row=j, col=i)
                end
            end
        end
    end
    relayout!(fig, barmode="stack", height=13700, font=Dict(:size=>22), yaxis_title=header_mapping[self.key]["units"])
    return fig
end

function create_dict_tade_geo_fig(self::PlotObject, capacities=[])
    scenario_to_year = Dict()
    self.year = [2018.0, 2050.0]
    if isempty(capacities)
        for (df,s) in zip(self.df_list, self.scenarios)
            scenario_to_year[s] = [
                plot_trade_capacity(self, df[(df.Year.==y),:], y, s, read_geojson_file(),nothing, false)
                for y in self.year
            ]
        end
    else
        for(df,s,c) in zip(self.df_list, self.scenarios, capacities)
            scenario_to_year[s] = [
                plot_trade_capacity(self, df[(df.Year.==y),:], y, s, read_geojson_file(), c, false)
                for y in self.year
            ]
        end
    end
    return scenario_to_year
end

function plot_trade_capacity(self, df, year, scenario, geojson, capacities=nothing, pie_chart=false,show_marker=false)
    lataxis = [35,70]
    lonaxis = [-9.7, 38]
    fig = PlotlyJS.Plot()

    sub_df = df[(df.Value .!= 0),:]
    for (index, row) in enumerate(eachrow(sub_df))
        i = row.Value
        try
            i = max(row.Value,
                    sub_df[(sub_df.Region1.==row.Region2) .&& (sub_df.Region2 .==row.Region1),:].Value[1]
                    )
        catch BoundsError
            i = row.Value
        end

        try
            lat = (geojson[row.Region2]["latitude"], geojson[row.Region1]["latitude"])
            lon = (geojson[row.Region2]["longitude"], geojson[row.Region1]["longitude"])
        catch KeyError
            print("$(row.Region2),$(row.Region1) Key not found in available data")
        end

        add_trace!(fig, PlotlyJS.scattergeo(locationmode="country names",
                                    lat=[geojson[row.Region2]["latitude"], geojson[row.Region1]["latitude"]],
                                    lon=[geojson[row.Region2]["longitude"], geojson[row.Region1]["longitude"]],
                                    mode="lines+markers",
                                    name="$(i) GW",
                                    text="$(i) GW",
                                    legendgroup=row.Value,
                                    showlegend=(index==1) | (index==nrow(sub_df)),
                                    line=attr(width=show_marker ? 1 : i, color=:grey),
                                    marker=attr(size=((isnothing(capacities) && pie_chart==false) ? 5 : 1), color=:black, sizemode="area", line_width=0.5, line_color=:black)
        ))
        
        if show_marker
            add_trace!(fig, PlotlyJS.scattergeo(locationmode="country names",
                                        lat=[(geojson[row.Region2]["latitude"] + geojson[row.Region1]["latitude"])/2],
                                        lon=[(geojson[row.Region2]["longitude"] + geojson[row.Region1]["longitude"])/2],
                                        mode="text",
                                        name="<b>$(i)</b>",
                                        showlegend=false,
                                        textfont=attr(color=:black, size =9),
                                        text="$(i)" ))
        end
    end
    if !isnothing(capacities) && (pie_chart==false)
        for (index, row) in enumerate(eachrow(capacities))
            add_trace!(fig, PlotlyJS.scattergeo(locationmode="country names",
                                        lat=[geojson[row.Region]["latitude"]],
                                        lon=[geojson[row.Region]["longitude"]],
                                        mode="markers",
                                        name="$(row.Region), $(row.Value) GW",
                                        legendgroup=row.Value,
                                        showlegend= (index==1) | (index==nrow(capacities)),
                                        marker=attr(size=row.Value/3, color=row.Value>0 ? colour_codes["Hydrogen"] : RGB{N0f8}(229/255,229/255,229/255), sizemode="area")))
        end
    end
    relayout!(fig,margin=attr(autoexpand=false, l=0))
    if pie_chart && !isnothing(capacities)
        capacities = capacities[in.(capacities.Technology, Ref(keys(colour_codes))),:]

        # determine size of pie relative to sum of installed capacities
        grouped_df = groupby(capacities, ["Region", "Year"])
        max_capa_df = combine(grouped_df, :Value=>sum=>:Value)
        max_capa = findmax(max_capa_df[(max_capa_df.Year.==year),:].Value)[1]
        for r in unique(capacities.Region)
            x_domain = (geojson[r]["longitude"] - lonaxis[1])/(lonaxis[2]-lonaxis[1])
            y_domain = (geojson[r]["latitude"] - lataxis[1])/(lataxis[2]-lataxis[1])
            subset_capa = capacities[(capacities.Region .==r) .&& (capacities.Year .==year),:]
            colors = [colour_codes[c] for c in subset_capa.Technology]
            if sum(subset_capa.Value) >0
                add_trace!(fig, PlotlyJS.pie(labels=subset_capa.Technology,
                                    values=subset_capa.Value,
                                    marker=attr(colors=colors),
                                    textinfo="none",
                                    domain=attr(x=[max(0,x_domain-0.02), x_domain + 0.02],
                                                y=[max(0,y_domain - 0.02), y_domain + 0.02])
                                                ))
            end
        end
    end
    relayout!(fig, title_text="Total Trade Capacities [GW] for $(scenario) in $(year)",
    geo=attr(
            lataxis=attr(range=[lataxis[1], lataxis[2]]),
            lonaxis=attr(range=[lonaxis[1], lonaxis[2]]),
            showland=true,
            countrycolor="white",
            showlakes=true,
            showcoastlines=false,
            landcolor=RGB{N0f8}(229/255,229/255,229/255)),
            width=2000)
    return fig
end



            


