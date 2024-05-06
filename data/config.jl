using FixedPointNumbers

aggregation = Dict(
    "P_Nuclear"=>"Nuclear",
    "P_Coal_Hardcoal"=>"Hardcoal",
    "P_Coal_Lignite"=>"Lignite",
    "P_Oil"=>"Oil",
    "P_Gas_OCGT"=>"Gas",
    "P_Gas_CCGT"=>"Gas",
    "P_Gas_CCS"=>"Gas",
    "P_Gas_Engines"=>"Gas",
    "RES_Hydro_Large"=>"Hydro Reservoir",
    "RES_Hydro_Small"=>"Hydro Run-of-River",
    "RES_Wind_Offshore_Deep"=>"Wind_Offshore",
    "RES_Wind_Offshore_Transitional"=>"Wind_Offshore",
    "RES_Wind_Offshore_Shallow"=>"Wind_Offshore",
    "RES_Wind_Onshore_Opt"=>"Wind_Onshore",
    "RES_Wind_Onshore_Avg"=>"Wind_Onshore",
    "RES_Wind_Onshore_Inf"=>"Wind_Onshore",
    "RES_PV_Utility_Opt"=>"PV",
    "RES_PV_Utility_Avg"=>"PV",
    "RES_PV_Rooftop_Residential"=>"PV",
    "RES_PV_Utility_Tracking"=>"PV",
    "RES_PV_Utility_Inf"=>"PV",
    "RES_PV_Rooftop_Commercial"=>"PV",
    "P_Biomass"=>"Biomass",
    "P_Biomass_CCS"=>"Biomass",
    "D_PHS"=>"Pumped Hydro",
    "D_PHS_Residual"=>"Pumped Hydro",
)

colour_codes = Dict(
    "Nuclear"=>RGB{N0f8}(112/255,112/255,112/255),
    "Hardcoal"=>RGB{N0f8}(229/255,229/255,229/255),
    "Gas"=>RGB{N0f8}(224/255,91/255,9/255),
    "Pumped Hydro"=>RGB{N0f8}(81/255,219/255,204/255),
    "Oil"=>:black,
    "Biomass"=>RGB{N0f8}(186/255,167/255,65/255),
    "Hydro Reservoir"=>RGB{N0f8}(7/255,154/255,136/255),
    "Hydro Run-of-River"=>RGB{N0f8}(8/255,173/255,151/255),
    "PV"=>RGB{N0f8}(249/255,208/255,2/255),
    "Wind Onshore"=>RGB{N0f8}(35/255,94/255,188/255),
    "Wind Offshore"=>RGB{N0f8}(104/255,149/255,221/255),
    "Hydrogen"=>RGB{N0f8}(191/255,0/255,191/255),
    "X_Electrolysis"=>:magenta,
    "solar_rooftop"=>RGB{N0f8}(225/255,239/255,96/255),
    "solar_tracking"=>RGB{N0f8}(225/255,246/255,191/255),
    "Transport"=>RGB{N0f8}(37/255,160/255,139/255),
    "Industry"=>RGB{N0f8}(234/255,197/255,99/255),
    "Buildings"=>RGB{N0f8}(240/255,243/255,190/255),
    "Demand"=>RGB{N0f8}(223/255,222/255,220/255),
    "DK"=>RGB{N0f8}(42/255,157/255,142/255),
    "UK"=>RGB{N0f8}(230/255,111/255,81/255),
    "Power"=>RGB{N0f8}(38/255,70/255,83/255),
    "NO1"=>RGB{N0f8}(37/255,160/255,139/255),
    "NO3"=>RGB{N0f8}(234/255,197/255,99/255),
    "NO4"=>RGB{N0f8}(240/255,243/255,190/255),
    "NO5"=>RGB{N0f8}(199/255,197/255,193/255),
    "NO2"=>RGB{N0f8}(230/255,111/255,81/255),
)

agg_countries = Dict(
    "NO" => ["NO1", "NO2", "NO3", "NO4", "NO5", "OFF_NO"]
)

order_legend = ["Gas", "Nuclear", "Oil", "Biomass", "Hydro Reservoir", "Hydro Run-of-River", "Pumped Hydro", "Wind Onshore", "Wind Offshore", "PV"]

header_mapping = Dict(
    "TotalCapacityAnnual"=>Dict(
        "columns"=>["Year", "Technology", "Region", "Value"],
        "units"=>"GW"
    ),
    "RateOfActivity"=>Dict(
        "columns"=>["Year", "TS", "Technology", "Mode", "Region", "Value"],
        "units"=>"TWh"
    ),
   "ProductionByTechnologyAnnual"=>Dict(
    "columns"=>["Year", "Technology", "Fuel", "Region", "Value"],
    "units"=>"TWh"
    ),
    "StorageLevelTSStart"=>Dict(
    "columns"=>["Technology", "Year", "TS", "Region", "Value"],
    "units"=>"TWh"
    ),
    "UseAnnual"=>Dict(
    "columns"=>["Year", "Fuel", "Region", "Value"],
    "units"=>"TWh"
    ),
    "TotalDiscountedCostByTechnology"=>Dict(
    "columns"=>["Year", "Technology", "Region", "Value"]
    ),
    "TotalTradeCapacity"=>Dict(
    "columns"=>["Year", "Fuel", "Region1", "Region2", "Value"],
    "units"=>"GW"
    ),
    "Export"=>Dict(
    "columns"=>["Year", "TS", "Fuel", "Region1", "Region2", "Value"],
    ),
)

key_to_julia = Dict(
    "production"=>"ProductionByTechnologyAnnual",
    "capacities"=>"TotalCapacityAnnual",
    "trade_map"=>"TotalTradeCapacity",
    "demand"=>"UseAnnual",
    "storage_level"=>"StorageLevelTSStart",
    "operation"=>"RateOfActivity",
    "export"=>"Export",
    "discountedcosts"=>"TotalDiscountedCostByTechnology",
    "hydrogen_infrastructure"=>"Export"
)

hydrogen_technologies = ["X_Electrolysis"]