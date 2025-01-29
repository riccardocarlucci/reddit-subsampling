####################################################################################
####################################################################################
# linspace and logspace; strangely enough Julia does not seem to have a native "logspace" \: so I had to implement it myself
"""
`linspace(a,b,length)`

an alias for `range(a,b,length = length)`

N.B. `length` is automatically parsed to an `Int` whenever possible, so it is possible to enter `linspace(a,b,1e5)` instead of having to type 5 zeroes.
"""
linspace(a,b,length) = range(a,b;length = length |> Int)

"""
`linspace(x,length)`

returns a linearly spaced iterator with prescribed `length` from `minimum(x)` to `maximum(x)`

N.B. `length` is automatically parsed to an `Int` whenever possible, so it is possible to enter `linspace(a,b,1e5)` instead of having to type 5 zeroes.
"""
linspace(x,length) = linspace(extrema(x)...,length)


"""
`logspace(a,b,length;base = 10)`

returns a (dense) logarithmically spaced array from `a` to `b` with prescribed `length`. default `base = 10`

N.B. `length` is automatically parsed to an `Int` whenever possible, so it is possible to enter `logspace(x,1e5)` instead of having to type 5 zeroes.
"""
function logspace(a,b,length;base = 10)
    if base == 10 
        y=exp10.(range(log10(a),log10(b),length = length |> Int))
    elseif base == 2 
        y=exp2.(range(log2(a),log2(b),length = length |> Int))
    else
        y=base.^range(log(a)/log(base),log(b)/log(base),length = length |> Int)
    end
    return y
end

"""
`logspace(x,length;base =)`

returns a (dense) logarithmically spaced array with prescribed `length` from `minimum(x)` to `maximum(x)`

N.B. `length` is automatically parsed to an `Int` whenever possible, so it is possible to enter `logspace(x,1e5)` instead of having to type 5 zeroes.
"""
logspace(x,length;base = 10) = logspace(extrema(x)...,length;base = base)


####################################################################################
####################################################################################
# check if a list contains duplicate elements
"""
`hasduplicates(list)`

Check if `list` contains duplicate elements
"""
function hasduplicates(list)
    Di = Dict{eltype(list),Int64}()
    has_duplicates = false
    for x ∈ list
        Di[x] = get(Di,x,0) + 1
        if Di[x] > 1
            has_duplicates = true
            break
        end
    end
    return has_duplicates
end

####################################################################################
####################################################################################
# 0.25 and 0.75 quantiles (for brevity, since I use them a lot)
quantile25(data) = quantile(data,0.25)
quantile75(data) = quantile(data,0.75)

####################################################################################
####################################################################################
""" `parameter_scan(foo,x,p_range,n_sample::Int64,functionals)`

let `x ↦ foo(x,p)` a function (returning a random output) depending on a parameter `p`.

this parameter scan routine create a sample of size `n_sample` from the function `foo(x,p)` for each `p∈p_range`.
and then evaluates the desired statistical `functionals` on the sample for each `p∈p_range`.

Example:
- `foo(x,p) = rand(Binomial(x,p))` samples from the binomial distribution `Binomial(x,p)` and we interpret the success probability `p` as a parameter.
- x = 10
- p_range = range(0,1,length = 10)
- n_sample = 1000
- functionals = (mean,std)
- output: two arrays [mean(foo(x,p)) for p∈p_range] and [std(foo(x,p)) for p∈p_range]

"""
function parameter_scan(foo,x,p_range,n_sample::Int64,functionals)
    np = length(p_range)
    nf = length(functionals)
    results = [zeros(np) for j∈1:nf]
    for (k,p) ∈ enumerate(p_range)
        sample = [foo(x,p) for j∈1:n_sample]
        for (i,F) ∈ enumerate(functionals)
            results[i][k] = F(sample)
        end       
    end
    return results
end

""" `parameter_scan(foo,x,p_range,n_sample,functionals)`

similar to `parameter_scan(foo,x,p_range,n_sample::Int64,functionals)` but now `n_sample` can be an array or an iterator with the same length as `p_range`.

this allows to sample from `foo(x,p)` a number of time `n_p` depending on `p`. choose a large/small `n_p` if `foo(x,p)` is expected to have a large/small variability.
"""
function parameter_scan(foo,x,p_range,n_sample,functionals)
    @assert length(p_range) == length(n_sample)
    np = length(p_range)
    nf = length(functionals)
    results = [zeros(np) for j∈1:nf]
    for (k,p) ∈ enumerate(p_range)
        sample = [foo(x,p) for j∈1:n_sample[k]]
        for (i,F) ∈ enumerate(functionals)
            results[i][k] = F(sample)
        end       
    end
    return results
end