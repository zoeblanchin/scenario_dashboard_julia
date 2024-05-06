using DataFrames
using DashBootstrapComponents
using Dash
include("layout//global_layout.jl")
include("callbacks//callbacks.jl")

external_stylesheets = [dbc_themes.BOOTSTRAP]
app = dash(external_stylesheets=external_stylesheets, update_title="Dahsboard")
app.layout = html_div([dcc_location(id="url"), sidebar, content])
get_callbacks(app)

run_server(app, "0.0.0.0", debug=true)

