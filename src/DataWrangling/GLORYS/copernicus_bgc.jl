# Copernicus Marine global biogeochemistry hindcast (GLOBAL_MULTIYEAR_BGC_001_029, PISCES at 1/4°)
abstract type CopernicusBGCDataset <: GLORYSDataset end

struct CopernicusBGCStatic <: CopernicusBGCDataset end
struct CopernicusBGCDaily <: CopernicusBGCDataset end
struct CopernicusBGCMonthly <: CopernicusBGCDataset end

dataset_name(::CopernicusBGCStatic) = "CopernicusBGCStatic"
dataset_name(::CopernicusBGCDaily) = "CopernicusBGCDaily"
dataset_name(::CopernicusBGCMonthly) = "CopernicusBGCMonthly"

Base.size(::CopernicusBGCDataset, variable) = (1440, 681, 75)

all_dates(::CopernicusBGCStatic, var) = [nothing]
all_dates(::CopernicusBGCDaily, var) = range(DateTime("1993-01-01"), stop=DateTime("2026-08-31"), step=Day(1))
all_dates(::CopernicusBGCMonthly, var) = range(DateTime("1993-01-01"), stop=DateTime("2026-08-01"), step=Month(1))

copernicusmarine_dataset_id(::CopernicusBGCStatic) = "cmems_mod_glo_bgc_my_0.25deg_static"
copernicusmarine_dataset_id(::CopernicusBGCDaily) = "cmems_mod_glo_bgc_my_0.25deg_P1D-m"
copernicusmarine_dataset_id(::CopernicusBGCMonthly) = "cmems_mod_glo_bgc_my_0.25deg_P1M-m"

native_horizontal_resolution(::CopernicusBGCDataset) = 1 / 4

# Concentrations in mmol m⁻³, chlorophyll in mg m⁻³, net primary production in mg C m⁻³ day⁻¹,
# and the surface partial pressure of CO₂ in Pa
const CopernicusBGC_daily_variable_names = Dict(
    :chlorophyll => "chl",
    :nitrate => "no3",
    :phosphate => "po4",
    :dissolved_silicate => "si",
    :dissolved_oxygen => "o2",
    :net_primary_production => "nppv",
)

const CopernicusBGC_monthly_variable_names = merge(CopernicusBGC_daily_variable_names, Dict(
    :dissolved_iron => "fe",
    :phytoplankton_carbon => "phyc",
    :ph => "ph",
    :carbon_dioxide_partial_pressure => "spco2",
))

available_variables(::CopernicusBGCStatic) = Dict(:depth => "deptho")
available_variables(::CopernicusBGCDaily) = CopernicusBGC_daily_variable_names
available_variables(::CopernicusBGCMonthly) = CopernicusBGC_monthly_variable_names

longitude_interfaces(::Metadata{<:CopernicusBGCDataset}) = (-180.125, 179.875)
latitude_interfaces(::Metadata{<:CopernicusBGCDataset}) = (-80.125, 90.125)
