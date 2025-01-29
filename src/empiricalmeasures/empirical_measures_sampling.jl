########################################################################################################################
########################################################################################################################
## sampling
"""
`sample(em::EmpiricalMeasure)`

returns a sample from an empirical measure;

# Example:
- 'sample(em)' returns an object from `objects(em)` sampled with sampling weights given by `weights(em)`
"""
function sample(em::EmpiricalMeasure)
    obj = objects(em;sort = false)
    wei = weights(em;sort = false)
    return sample(obj,Weights(wei))
end

"""
`sample(em::EmpiricalMeasure,n::Int64)`

sample with replacement from an empirical measure;

# Example:
- 'sample(em,n)' returns a sample of length `n` from `objects(em)` with sampling weights given by `weights(em)`
"""
function sample(em::EmpiricalMeasure,n::Int64)
    obj = objects(em;sort = false)
    wei = weights(em;sort = false)
    return sample(obj,Weights(wei),n)
end

########################################################################################################################
########################################################################################################################
## subsampling

"""
`subsample(em::EmpiricalMeasure,p)`

given an empirical measure `em` returns a (random) empirical measure with the same objects, but the weights are "subsampled with probability `p`"

# Illustration
- consider a sample `X = [1,1,1,1,2,2,2,2,2,3]`
- its empirical measure is `em_X = EmpiricalMeasure(objects = [1,2,3],weights = [4,5,1])`
- subsampling from `X` with probability `p` means to create a (random) subsample `Y` where each element each element of `X` is retained with probability `p` and discarded it with probability `1-p`. Example: `Y = [1,1,2,2,2]`
- The corresponding "subsampled" empirical measure is `em_Y = EmpiricalMeasure(objects = [1,2,3],weights = [2,3,0])`
"""
function subsample(em::EmpiricalMeasure,p::Float64)
    em_sub = EmpiricalMeasure{eltype(em)}()
    for (k,wk) ∈ em
        em_sub[k] = rand(Binomial(wk,p))
    end
    return em_sub
end

"""
`subsampledsum(em::EmpiricalMeasure,p;rescale = false)`

estimate the sum of a empirical measure from a (random) subsample with probability `p` (see `subsample` documentation)

# Example
- let `em = EmpiricalMeasure(objects = [11,12,13],weights = [4,5,1])`.
- the sum of `em` is `11⋅4 + 12⋅5 + 13⋅1 = 117`
- a (random) subsample with probability `p=0.5` of `em` is `em_sub = EmpiricalMeasure(objects = [11,12,13],weights = [2,3,0])`
- the subsampled sum is `11⋅2 + 12⋅3 + 13⋅0  = 58`
- if `rescale = true` the result is divided by `p` to give `58/0.5 = 116` as an estimate of the original sum
"""
function subsampledsum(em::EmpiricalMeasure,p::Float64;rescale = false)
    s = 0
    for (k,wk) ∈ em
        s += k*rand(Binomial(wk,p))
    end
    if rescale 
        return s/p
    else
        return s
    end
end

"""
`subsampledsum(em::EmpiricalMeasure,p,size::Int)`

returns an array of size `size` of subsampled sums (with probability `p`) from the empirical measure `em`
"""
function subsampledsum(D::EmpiricalMeasure,p::Float64,size::Int64;rescale = false)
    return [subsampledsum(D::EmpiricalMeasure,p::Float64;rescale = rescale) for j∈1:size]
end

########################################################################################################################
########################################################################################################################
## thinning

"""
`thin(n::Int64,p)`

the p-thinning `k` of an integer `n` is obtained by flipping a biased coin (that comes up heads with probability `p`) `n` times and counting the number of heads `k`.

in other words: `thin(n::Int64,p)` samples from the `Binomial(n,p)` distribution.
"""
function thin(n::Int64,p)
    return rand(Binomial(n,p))
end

"""
`thin(em::EmpiricalMeasure{Int},p)`

the p-thinning of an empirical measure `em` with `Int` objects is obtained as follows:
- let `objects(em) = [n_1,…,n_r]` and `weights(em) = [w_1,…,w_r]`. let `N = w_1 + … + w_r` be the sum of all the weights.
- then the associated sample is `x = [n_1,…,n_1,…,n_r,…,n_r]` where each integer `n_i` is repeated `w_i` times
- go through each element `n` of `x` and replace it with `k = thin(n,p)` i.e. its p-thinning (see documentation of `thin(n::Int64,p)` above)
- the result is a new sample `y = [k_1,…,k_N]` where `y[j] ≤ x[j]` for all `j`.
- the p-thinning of the original measure `em` is the empirical measure of the sample `y`
- N.B. the outcome of this algorithm is random
"""
function thin(em::EmpiricalMeasure{Int},p)
    em_thinned = EmpiricalMeasure{Int}()
    for (k,wk) ∈ em
        for i∈1:wk
            k_thinned = thin(k,p)
            em_thinned[k_thinned] = get(em_thinned,k_thinned,0) + 1
        end
    end
    return em_thinned
end