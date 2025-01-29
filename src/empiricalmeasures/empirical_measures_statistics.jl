########################################################################################################################
########################################################################################################################
## moments

"""
`mass(em::EmpiricalMeasure)`

returns the mass of an empirical measure i.e. the sum of all the weights i.e. its moment of order 0

# Example
- let `em = EmpiricalMeasure(objects,weights)` then `mass(em)` returns the sum of `weights`
"""
function mass(em::EmpiricalMeasure)
    return sum(values(em.data))
end

"""
`sum(em::EmpiricalMeasure)`

returns the weighted sum (i.e. non-normalized 1st-order moment) of an empirical measure

# Example
- `em = EmpiricalMeasure([1,2,3],[8,3,5])` then `sum(em)` returns `1⋅8 + 2⋅3 + 3⋅5`
"""
function sum(em::EmpiricalMeasure{T}) where {T<:Real}
    if length(em) == 0
        return zero(T)
    else
        return sum(k*wk for (k,wk) ∈ em)
    end
end

"""
`norm(em::EmpiricalMeasure,p=2)`

returns the weighted l^p-norm of an empirical measure

# Example
- let `em = EmpiricalMeasure(objects = [1,2,3], [8,3,5],p)` then `sum(em)` returns `(1^p⋅8 + 2^p⋅3 + 3^p⋅5)^(1/p)`
"""
function norm(em::EmpiricalMeasure{T},p=2) where {T<:Real}
    if length(em) == 0
        return zero(T)
    else
        return sum(k^p*wk for (k,wk) ∈ em)^(1/p)
    end
end

########################################################################################################################
########################################################################################################################
## moments of associated distribution
"""
`mean(em::EmpiricalMeasure)`

convert the empirical measure to an empirical distribution (with normalized weights) and return the mean
"""
function mean(em::EmpiricalMeasure)
    return sum(k*wk for (k,wk) ∈ em)/mass(em)
end

"""
`var(em::EmpiricalMeasure)`

convert the empirical measure to an empirical distribution (with normalized weights) and return the variance
"""
function var(em::EmpiricalMeasure)
    μ1 = mean(em)
    μ2 = sum(k^2*wk for (k,wk) ∈ em)/mass(em)
    return μ2-μ1^2
end

"""
`std(EM::EmpiricalMeasure)`

convert the empirical measure to an empirical distribution (with normalized weights) and return the standard deviation
"""
function std(em::EmpiricalMeasure)
    return sqrt(var(em))
end

"""
`moment(em::EmpiricalMeasure,p)`

returns the raw moment of order p of an empirical measure

# Example
- let `em = EmpiricalMeasure(objects = [1,2,3], [8,3,5],p)` then `sum(em)` returns `(1^p⋅8 + 2^p⋅3 + 3^p⋅5) / (8 + 3 + 5)`
"""
function moment(em::EmpiricalMeasure{T},p) where {T<:Real}
    return sum(k^p*wk for (k,wk) ∈ em)/mass(em)
end

########################################################################################################################
########################################################################################################################
## moments of associated distribution

function quantile(em::EmpiricalMeasure,q)
    @assert 0 ≤ q ≤ 1 "q must lie in the interval [0,1]"
    objects,F = cdf(em)
    i = searchsortedfirst(F,q)
    return objects[i]
end


function median(em::EmpiricalMeasure)
    return quantile(em::EmpiricalMeasure,0.5)
end


########################################################################################################################
########################################################################################################################
## implement cdf / ccdf of an empirical measure


function pdf(em::EmpiricalMeasure)
    sorted_dict = sort(em.data)
    objects = sorted_dict |> keys |> collect
    weights = sorted_dict |> values |> collect
    objects,weights/sum(weights)
end

function cdf(em::EmpiricalMeasure)
    objects,weights = pdf(em)
    F = cumsum(weights)
    return objects,F/F[end]
end

function ccdf(em::EmpiricalMeasure)
    objects,F = cdf(em)
    return objects, 1.0 .- F
end