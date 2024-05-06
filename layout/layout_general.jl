using Dash
using PlotlyJS
using Plots
using Colors
using ColorSchemes
function discrete_background_color_bins(df, n_bins=5, columns="all")
    bounds = [i*(1.0/n_bins) for i in 1:(n_bins+1)]
    if columns == "all"
        df_numeric_columns = select(df, findall(col->eltype(col) <: Number, eachcol(df)))
        if "id" in names(df)
            # adding a line to suppress id column
        end
    else
        df_numeric_columns = df[:,columns]
    end
    df_max = maximum(maximum.(eachcol(df_numeric_columns)))
    df_min = minimum(minimum.(eachcol(df_numeric_columns)))
    ranges = [ ((df_max - df_min)*i)+df_min for i in bounds]
    styles = Dict[]
    legend = Component[]
    color_palette = ColorScheme(Colors.sequential_palette(300,50, logscale=true))
    for i in 1:length(bounds)-1
        min_bound = ranges[i]
        max_bound = ranges[i+1]
        backgroundColor = string("#",lowercase(hex.(colormap("Blues",n_bins))[i]))
        color = i>(length(bounds)/2.) ? "white" : "inherit"

        for column in names(df_numeric_columns)
            push!(styles,
                Dict(
                    "if" => Dict(
                        "filter_query" =>
                        string("{$(column)} >= $(min_bound)", ((i<length(bounds) ? " && {$(column)} < $(max_bound)" : ""))),
                        "column_id" => column
                    ),
                    "backgroundColor" => backgroundColor,
                    "color" => color
                )
            )
        end
        push!(legend,
        html_div(style=Dict("display"=>"inline-block", "width" => "60px"), children =
            html_div(
                style=Dict("backgroundColor" => backgroundColor,
                            "borderLeft" => "1px rgb(50,50,50) solid",
                            "height"=> "10px")
            ),
            html_small(round(min_bound, digits=2), style = Dict("paddingLeft"=>"2px"))))
    end
    return (styles, html_div(legend, style=Dict("padding"=>"5px 0 5px 0")))
end

function my_img()
    return html_img("logo.png")
end



