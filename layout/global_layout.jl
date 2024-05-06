using Dash
using DashBootstrapComponents

include("..//config//layout_config.jl")

sidebar = html_div(style=SIDEBAR_STYLE) do 
        dbc_row(
            [html_h3("GENeSYS-MOD Dashboard"),
            html_br(),
            html_br(style=Dict("margin"=>"8px")),
            html_hr(style=Dict("height"=>"2px", "opacity"=>"1","margin"=>"8px"))]
        ),
        dbc_row(
            html_div(id="container", children=[])
        ),
        dbc_row(
            [
                dbc_col(
                    [
                        dbc_button(
                            "Add",
                            id = "add",
                            n_clicks=0,
                            className="d-grid",
                            style=BUTTON
                        )
                    ]
                ),
                dbc_col(
                    [
                        dbc_button(
                            "Save",
                            id="save",
                            n_clicks=0,
                            className="d-grid",
                            style=BUTTON
                        ),
                        dcc_loading(
                            id="loading-1",
                            type="circle",
                            children=html_div(id="loading-output-1")
                        )
                    ]
                )
            ],
            style = Dict("margin-top"=>"1rem")
        )      
end

content = html_div(style=CONTENT_STYLE) do 
    children = [
        dbc_row(
            [
                dbc_col(children = html_h3("Scenario Explorer"), style = Dict("margin"=>"8px")),
                # dbc_col(children = my_img())
            ]
        ),
        dbc_row(
            children=
            [
                dbc_col(children = html_h5("Result"), width=2),
                dbc_col(children = [dcc_dropdown(
                    options = [
                        (label= "Installed Capacities [GW]", value="capacities"),
                        (label= "Annual Production [TWh]", value="production"),
                        (label= "Export 2050 [TWh]", value="export"),
                        (label="Demand [TWh]", value="Demand [TWh]", disabled=true),
                        (label="Hydrogen Infrastructure", value="hydrogen_infrastructure", disabled=true),
                        (label="Trade Capacity Power [GW]", value="trade_map")
                    ],
                    id="dropdownmenu",
                    placeholder="Select:"
                )], width=3)
            ],
            style=Dict("margin"=>"12px")
        ),
        dbc_row(
            children=[], id="fuel", style=Dict("margin"=>"12px")
        ),
        dbc_row(
            children=dcc_tabs([
                dcc_tab(label="Overview", children=[], id="summary"),
                dcc_tab(label="Regions", children=[], id="individual")
            ],
            id="my_tabs")
        )
    ]
    

    
end