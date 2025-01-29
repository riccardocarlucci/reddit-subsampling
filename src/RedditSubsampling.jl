module RedditSubsampling

# this part implements the EmpiricalMeasure data type
using Distributions,StatsBase
import Distributions: length, sum, mean, median, quantile, moment, var, std, pdf, cdf, ccdf
import StatsBase: sample
export EmpiricalMeasure, empiricalmeasure, objects, weights
export length, mass, sum, norm, mean, var, std, moment, median, quantile, pdf, cdf, ccdf
export sample, subsample, subsampledsum, thin
include("empiricalmeasures/empirical_measures.jl")
include("empiricalmeasures/empirical_measures_statistics.jl")
include("empiricalmeasures/empirical_measures_sampling.jl")

# this part implements logarithmic plots
using Plots
export logplot,logplot!,semilogplot,semilogplot!,xsemilogplot,xsemilogplot!,qq_plot,pp_plot
include("plotting/plotting.jl")

# this part implements various useful functions
export linspace,logspace,quantile25,quantile75,parameter_scan
include("miscellanea/miscellanea.jl")

end
