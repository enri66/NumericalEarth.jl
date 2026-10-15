include("runtests_setup.jl")
include("download_utils.jl")

using CopernicusMarine

using NumericalEarth.DataWrangling: BoundingBox, metadata_path
using NCDatasets: NCDataset
using Oceananigans.Fields: location

@testset "Download and set Copernicus BGC nitrate and oxygen" begin
    region = BoundingBox(longitude=(200, 202), latitude=(35, 37))
    date = DateTime(2019, 2, 1)

    for arch in test_architectures, name in (:nitrate, :dissolved_oxygen)
        md = Metadatum(name; dataset=CopernicusBGCDaily(), region, date)
        source = Field(md, arch; inpainting=nothing)
        Nz = size(source, 3)
        k = searchsortedfirst(znodes(source.grid, Center()), -500)
        surface = Array(interior(source, :, :, Nz))
        deep = Array(interior(source, :, :, k))
        @test all(isfinite, surface)
        @test all(isfinite, deep)

        if name == :nitrate
            @test all(0 .≤ surface .< 5)
            @test all(deep .> surface)
        else
            @test all(150 .< surface .< 350)
        end
    end
end

@testset "Download and set Copernicus BGC pH" begin
    region = BoundingBox(longitude=(200, 202), latitude=(35, 37))
    md = Metadatum(:ph; dataset=CopernicusBGCMonthly(), region, date=DateTime(2019, 2, 1))
    source = Field(md; inpainting=nothing)
    Nz = size(source, 3)
    k = searchsortedfirst(znodes(source.grid, Center()), -500)
    surface = interior(source, :, :, Nz)
    @test all(8.0 .< surface .< 8.2)
    @test all(interior(source, :, :, k) .< surface)
end

@testset "Download Copernicus BGC sea floor depth" begin
    region = BoundingBox(longitude=(200, 202), latitude=(35, 37))
    md = Metadatum(:depth; dataset=CopernicusBGCStatic(), region)
    download(md)
    depth = NCDataset(metadata_path(md)) do ds
        ds["deptho"][:, :]
    end
    @test all(depth .> 4000)
end

@testset "Download and set Copernicus BGC surface pCO₂" begin
    region = BoundingBox(longitude=(200, 202), latitude=(35, 37))
    md = Metadatum(:carbon_dioxide_partial_pressure; dataset=CopernicusBGCMonthly(), region, date=DateTime(2019, 2, 1))
    @test location(md) === (Center, Center, Nothing)

    source = Field(md; inpainting=nothing)
    @test all(25 .< interior(source) .< 50)
end
