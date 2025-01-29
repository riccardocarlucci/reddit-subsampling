######################################################################
## logarithmic plots with better appearance

# Julia GR plotting backend messes up if a logarithmic plot contains zero elements, so we have to remove them before plotting...
function prepare_for_logplot(x,y)
    index = (x .> 0) .& (y .> 0)
    x_positive = @view x[index]
    y_positive = @view y[index]
    ticks_x = exp10.(-40:+40)
    ticks_y = exp10.(-40:+40)
    return x_positive,y_positive,ticks_x,ticks_y
end

"""
`logplot(x,y;kwargs...)`

plot `y` vs `x` on a log10-log10 scale
"""
function logplot(x,y;kwargs...)
    x_positive,y_positive,ticks_x,ticks_y = prepare_for_logplot(x,y)
    return plot(x_positive,y_positive; xaxis = :log, yaxis = :log, xticks = ticks_x, yticks = ticks_y, minorticks = 10, kwargs...)
end


"""
`logplot!(x,y;kwargs...)`

plot `y` vs `x` (on top the current figure) on a log10-log10 scale
"""
function logplot!(x,y;kwargs...)
    x_positive,y_positive,ticks_x,ticks_y = prepare_for_logplot(x,y)
    return plot!(x_positive,y_positive; xaxis = :log, yaxis = :log, xticks = ticks_x, yticks = ticks_y, minorticks = 10, kwargs...)
end

######################################################################
# semilog plot (y in log scale)

function prepare_for_semilogplot(x,y)
    index = (y .> 0)
    x_slice = @view x[index]
    y_slice = @view y[index]
    ticks_y = exp10.(-40:+40)
    return x_slice,y_slice,ticks_y
end

"""
`semilogplot(x,y;kwargs...)`

plot `y` vs `x` where `y` is in log10 scale
"""
function semilogplot(x,y;kwargs...)
    x_slice,y_slice,ticks_y = prepare_for_semilogplot(x,y)
    return plot(x_slice,y_slice; yaxis = :log, yticks = ticks_y, yminorticks = 10, kwargs...)
end

"""
`semilogplot!(x,y;kwargs...)`

plot `y` vs `x` (on top the current figure) where `y` is in log10 scale 
"""
function semilogplot!(x,y;kwargs...)
    x_slice,y_slice,ticks_y = prepare_for_semilogplot(x,y)
    return plot!(x_slice,y_slice; yaxis = :log, yticks = ticks_y, yminorticks = 10, kwargs...)
end

######################################################################
# semilog plot (x in log scale)

"""
`semilogplot(x,y;kwargs...)`

plot `y` vs `x` where `x` is in log10 scale
"""
function xsemilogplot(x,y;kwargs...)
    y_slice,x_slice,ticks_x = prepare_for_semilogplot(y,x)
    return plot(x_slice,y_slice; xaxis = :log, xticks = ticks_x, xminorticks = 10, kwargs...)
end

"""
`semilogplot!(x,y;kwargs...)`

plot `y` vs `x` (on top the current figure) where `x` is in log10 scale 
"""
function xsemilogplot!(x,y;kwargs...)
    y_slice,x_slice,ticks_x = prepare_for_semilogplot(y,x)
    return plot!(x_slice,y_slice; xaxis = :log, xticks = ticks_x, xminorticks = 10, kwargs...)
end

######################################################################
# pp-plot and qq-plot

"""
`pp_plot(sample,y;kwargs...)`

probability-probability plot of a `sample` i.e. a parametric plot of the cumulative distirbution function `x ↦ P[sample ≤ x]` of the sample against the cumulative distribution function `x ↦ P[Z ≤ x]` of a normal distribution `Z∼N(μ,σ)` with `μ = mean(sample)` and `σ = std(sample)`

useful to check deviations from normality
"""
function pp_plot(sample;steps = 1000,kwargs...)
    t = range(minimum(sample),maximum(sample),length = steps)
    μ,σ = mean(sample),std(sample)
    F_sample = ecdf(sample).(t)
    F_normal = cdf.(Normal(μ,σ),t)
    plot(legend = false,xlabel = "cumulative distribution: data",ylabel = "cumulative distribution: normal")
    plot!(t -> t,0,1;line = :dash,color = :gray)
    plot!(F_sample,F_normal;color = 1,kwargs...)
end

"""
`qq_plot(sample,y;kwargs...)`

quantile-quantile plot of a `sample` i.e. a parametric plot of the quantile function `q ↦ quantile(sample,x)` of the sample against the quantile function `x ↦ quantile(Z,x)` of a normal distribution `Z∼N(μ,σ)` with `μ = mean(sample)` and `σ = std(sample)`

useful to check deviations from normality
"""
function qq_plot(sample;steps = 1000,kwargs...)
    q = range(1/steps,1-1/steps,length = steps)
    μ,σ = mean(sample),std(sample)
    Q_sample = [quantile(sample,qi) for qi ∈ q]
    Q_normal = quantile.(Normal(μ,σ),q)
    plot(legend = false,xlabel = "quantiles: data",ylabel = "quantiles: normal")
    plot!(t -> t,Q_sample[1],Q_sample[end];line = :dash,color = :gray)
    plot!(Q_sample,Q_normal;color = 1,kwargs...)
end