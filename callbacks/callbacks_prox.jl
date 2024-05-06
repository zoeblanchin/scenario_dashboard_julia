using DataFrames
using PlotlyJS
using Plots
using Colors
using ColorSchemes
using FixedPointNumbers
using JSON3
using Dash
include("..//data//data_class.jl")
include("..//data//data_plot.jl")
include("..//data//config.jl")
# include("..//layout//global_layout.jl")
include("..//layout//layout_general.jl")
include("..//config//layout_config.jl")

data_rw = DataRaw("C:\\Users\\zoeb\\Documents\\scenario_dashboard\\Solution_julia.sol", "export", "Power")

aggregate_column(data_rw, "TS", "sum")
filter_column(data_rw, :Fuel, ["Power"])
filter_column(data_rw, :Year, [2050])
pivot_table(data_rw)

(styles, legend) = discrete_background_color_bins(data_rw.df)

print(styles)

# df = DataRaw("C:\\Users\\zoeb\\Documents\\scenario_dashboard\\Solution_julia.sol", "export")
# filter_sector(df)
# aggregate_technologies(df)
# capacities = [df.df]

# plt_object = PlotObject("trade_map", list_dfs, ["scenario"], [2018, 2030, 2040, 2050], "Power")

# figure_dict = create_dict_tade_geo_fig(plt_object,capacities)
# figure = figure_dict["scenario"][1]

# display(figure)



