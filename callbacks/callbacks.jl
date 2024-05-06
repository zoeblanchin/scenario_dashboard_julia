using DataFrames
using Dash
using PlotlyJS
using Plots
using DashBootstrapComponents
using Colors
using FixedPointNumbers
include("..//data//data_class.jl")
include("..//data//data_plot.jl")
include("..//data//config.jl")
include("..//layout//global_layout.jl")
include("..//layout//layout_general.jl")
include("..//config//layout_config.jl")

using Gtk

function get_callbacks(app)
    callback!(app,
    Output((type="dynamicDirectory", index= MATCH), "children"),
    Input((type="dynamicPath", index= MATCH), "n_clicks"),
    prevent_initial_call = true
    ) do n_clicks
    if n_clicks >0
        file_directory = open_dialog("Select Solution File", GtkNullContainer(), ("*.txt, *.sol",))
        print(file_directory)
    end
    return file_directory
    end


    callback!(app,
    Output("container", "children"),
    [Input("add", "n_clicks")],
    [State("container", "children")],
    prevent_initial_call = true
    ) do n_clicks, div_children
        # print(div_children)
        new_child = html_div(
            dbc_card(
                children=
                [
                    dbc_row(children=[
                        dbc_row(children=[
                            dbc_col(children=[html_p("Scenario:", style=HEADER)]),
                            dbc_col(children=[dbc_input(id=(type="dynamicScenario", index=n_clicks),
                                                        placeholder="Name",
                                                        required=true,
                                                        type="text"
                                                        )])],
                            style=Dict("margin"=>"8px")),
                    dbc_row(children=[
                        dbc_col(children=[html_p("Folder Path:", style=HEADER)]),
                        dbc_col(children=[
                            dbc_button("Browse",
                            id=(type="dynamicPath", index=n_clicks),
                            n_clicks=0,
                            style=BUTTON,
                            className="d-grid"),
                            html_p(id=(type="dynamicDirectory", index=n_clicks), children="")
                        ])
                    ], style=Dict("margin"=>"8px"))    
                    ], style = CARD_STYLE)
                ]
            )
        )
        # println(typeof(new_child))
        # push!(div_children, new_child)
        return [new_child]
end

    callback!(app,
    Output("fuel", "children"),
    [Input("dropdownmenu", "value")],
    prevent_initial_call = true
    ) do key
    if key=="trade_map"
        new_child = [
            dbc_col(children=html_h5("Fuel:"), width=2),
            dbc_col(children=[dcc_dropdown(
                options=[
                    (label="Power", value="Power"),
                    (label="Natural Gas", value="gas_natural", disabled=true),
                    (label="H2", value="H2", disabled=true)
                ],
                id="fuels",
                value="power"
            )], width=3)
        ]
    else
        new_child = [dbc_col(children=html_h5(" "), id="fuels"), dbc_col(children=[])]
    end
    return new_child
end

    callback!(app,
    [Output("summary", "children"),
    Output("individual", "children"),
    Output("loading-output-1", "children")],
    [Input((type = "dynamicScenario", index=ALL), "value"),
    Input((type = "dynamicDirectory", index=ALL), "children"),
    Input("dropdownmenu", "value"),
    Input("fuels", "value"),
    Input("save", "n_clicks")],
    prevent_initial_call = true
    ) do scenario, directory, key, fuel, n_clicks
    if n_clicks>0
        list_dfs = []
        capacities = []
        for (s,d) in zip(scenario, directory)
            data_rw = DataRaw(d, key, "Power")
            if key in ["capacities", "production"]
                filter_sector(data_rw)
                aggregate_technologies(data_rw)
                aggregate_regions(data_rw)
            elseif key in ["hydrogen_infrastructure"]
                filter_column(data_rw, :Fuel, ["H2"])
                replace_offshore(data_rw)
                df = DataRaw(d, "capacities")
                replace_offshore(df)
                filter_column(df, :Technology, hydrogen_technologies)
                aggregate_column(df, "Technology", "sum")
                push!(capacities, df.df)
            elseif key in ["trade_map"]
                filter_column(data_rw, :Fuel, [fuel])
                replace_offshore(data_rw)

                # prepare data for the pie chart
                df = DataRaw(d, "capacities")
                replace_offshore(df)
                filter_sector(df)
                aggregate_technologies(df)
                push!(capacities, df.df)
            elseif key in ["export"]
                aggregate_column(data_rw, "TS", "sum")
                filter_column(data_rw, :Fuel, ["Power"])
                filter_column(data_rw, :Year, [2050])
                pivot_table(data_rw)
            end
            push!(list_dfs, data_rw.df)
        end

        plt_obj = PlotObject(key, list_dfs, scenario, [2018, 2030, 2040, 2050], "Power")

        if key in ["capacities", "production"]
            return [[dcc_graph(figure=stacked_bar_integrated(plt_obj, true))],
            [dcc_graph(figure=stacked_bar_side(plt_obj))],
            []]
        elseif key in ["trade_map", "hydrogen_infrastructure"]
            figure_dict = create_dict_tade_geo_fig(plt_obj,capacities)
            lis = [dbc_col(children=[dbc_row(children=[dcc_graph(figure=y) for y in figure_dict[s]])]) for s in scenario]
            return [[dbc_row(children=lis, style=Dict("height"=>2000))],
            [],
            []]
        elseif key in ["export"]
            tables = []
            for df in list_dfs
                (styles, legend) = discrete_background_color_bins(df)
                push!(tables, dbc_col(
                    children=[
                        dbc_row(children=
                        [
                            dash_datatable(data=Dict.(pairs.(eachrow(df))), columns = [Dict("name"=>i, "id"=>i) for i in names(df)]
                            , style_data_conditional=styles
                            )
                        ])
                    ]
                ))
            end
            return [[dbc_row(children=tables)],
            [],
            []]
        else
            return [[], [], []]
        end
    end
end
end
