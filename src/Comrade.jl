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
import Distributions as Dists
using DocStringExtensions
using ChainRulesCore
using ComradeBase
using FITSIO
using FileIO: File, @format_str
using FillArrays: Fill
using ForwardDiff
using FFTW: fft, fftfreq, fftshift, ifft, ifft!, ifftshift, plan_fft
using FFTW
#using MappedArrays: mappedarray
import MeasureBase as MB
using NFFT
using PaddedViews
using PDMats
using PyCall: pyimport, PyNULL, PyObject
using SpecialFunctions #: gamma, erf
#using Bessels
using Random
using RectiGrids
using Reexport
using Requires: @require
using StructArrays: StructVector, StructArray, append!!
using Tables
using ZygoteRules
# Write your package code here.

@reexport using ComradeBase
export AD
# using ComradeBase: DataNames


const ehtim = PyNULL()

"""
    load_ehtim()

Loads the [eht-imaging](https://github.com/achael/eht-imaging) library and stores it in the
exported `ehtim` variable.

# Notes
This will fail if ehtim isn't installed in the python installation that PyCall references.
"""
function load_ehtim()
    #try
    copy!(ehtim, pyimport("ehtim"))
    #catch
    #    @warn "No ehtim installation found in python path. Some data functionality will not work"
    #end
end


export rad2μas, μas2rad, ehtim, load_ehtim, logdensity_def, logdensityof

"""
    rad2μas(x)
Converts a number from radians to micro-arcseconds (μas)
"""
@inline rad2μas(x) = 180/π*3600*1e6*x

"""
    μas2rad(x)
Converts a number from micro-arcseconds (μas) to rad
"""
@inline μas2rad(x) = x/(180/π*3600*1e6)


#include("interface.jl")
#include("images/images.jl")
import ComradeBase: flux, radialextent, intensitymap, intensitymap!, phasecenter
export create_cache
include("observations/observations.jl")
include("models/models.jl")
include("distributions/radiolikelihood.jl")
include("visualizations/visualizations.jl")
include("bayes/bayes.jl")
include("inference/inference.jl")
include("calibration/calibration.jl")


end
