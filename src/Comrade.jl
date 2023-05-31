"""
    Comrade
Composable Modeling of Radio Emission
"""
module Comrade

using AbstractFFTs
using AbstractMCMC
using Accessors: @set
using ArgCheck: @argcheck
using BasicInterpolators
using DensityInterface
import Distributions as Dists
using DocStringExtensions
using ChainRulesCore
using FITSIO
using FillArrays: Fill
using ForwardDiff
using FFTW: fft, fftfreq, fftshift, ifft, ifft!, ifftshift, plan_fft
using FFTW
#using MappedArrays: mappedarray
using NamedTupleTools
using NFFT
using PaddedViews
using PDMats
using SpecialFunctions #: gamma, erf
#using Bessels
using Random
using RectiGrids
using Reexport
using SkyModels
using StaticArraysCore
using StructArrays: StructVector, StructArray, append!!
import StructArrays
using Tables
using TypedTables
# Write your package code here.

@reexport using SkyModels
@reexport using ComradeBase

export linearpol, mbreve, evpa
using ComradeBase: AbstractDims, AbstractModel, AbstractPolarizedModel, AbstractHeader
using ComradeBase: load



export rad2μas, μas2rad, logdensity_def, logdensityof
export rad2μas, μas2rad, logdensity_def, logdensityof


#include("interface.jl")
#include("images/images.jl")
import ComradeBase: flux, radialextent, intensitymap, intensitymap!,
                    intensitymap_analytic, intensitymap_analytic!,
                    intensitymap_numeric, intensitymap_numeric!,
                    visibilities, visibilities!,
                    _visibilities, _visibilities!,
                    visibilities_analytic, visibilities_analytic!,
                    visibilities_numeric, visibilities_numeric!
export create_cache
include("observations/observations.jl")
include("models/models.jl")
include("distributions/radiolikelihood.jl")
include("visualizations/visualizations.jl")
include("bayes/bayes.jl")
include("inference/inference.jl")
include("calibration/calibration.jl")


# Load extensions using requires for verions < 1.9
if !isdefined(Base, :get_extension)
    using Requires
end

@static if !isdefined(Base, :get_extension)
    function __init__()
        @require Pyehtim="3d61700d-6e5b-419a-8e22-9c066cf00468" include(joinpath(@__DIR__, "../ext/ComradePyehtimExt.jl"))
    end
end



end
