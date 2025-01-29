"""
`EmpiricalMeasure{T}`

Implements an "empirical measure" type as a dictionary from objects (of type `T`) to (integer) weights.

Idea: the empirical measure corresponding to a sample `["a","b","b","a","d","c","b"]` is: `EmpiricalMeasure{String}(objects = ["a","b","c","d"],weights = [2,3,1,1])` where `["a","b","c","d"]`

Constructors
- `em = EmpiricalMeasure{T}()` creates an empty EmpiricalMeasure `em` with objects of type `T`. The empirical measure can be filled at a later time as a normal dictionary.
- `em = EmpiricalMeasure(objects,weights)` creates a new EmpiricalMeasure instance from an array of `objects` and `weights`.

Things you can do with an EmpiricalMeasure:
- Use the auxiliary function `empiricalmeasure(sample)` to construct an empirical measure directly from a `sample`
- Create an empirical measure step by step, just like a Dict e.g. `em = EmpiricalMeasure{String}()` returns an empty empirical measure which can be filled e.g. with `em["a"] = 23`, `em["b"] = 12` etc.
- Look up an EmpiricalMeasure just like a Dict i.e. `em[obj]` returns the weight `w` associated to the object `obj`.
- Compute statistical functionals such as mean, variance, moments, cdf, ccdf (nter a help command such as `?mean(em::EmpiricalMeasure)` in the REPL for the relevant documentation)
- Sample with replacement from the objects of the empirical measure (enter the help command `?sample(em::EmpiricalMeasure)` in the REPL for the relevant documentation)
- Subsampling and Thinning (enter the help commands `?subsample` and `?thin` in the REPL for the relevant documentation)
"""
mutable struct EmpiricalMeasure{T}
    data::Dict{T,Int}
    
    # empty constructor
    function EmpiricalMeasure{T}() where {T}
        new(Dict{T,Int}())
    end

    # constructor from an already existing dict
    EmpiricalMeasure{T}(dict::Dict{T, Int}) where {T} = new(dict)

    # constructor from objects and their weights 
    function EmpiricalMeasure{T}(objects,weights) where {T}
        if size(objects) ≠ size(weights)
            throw(DimensionMismatch("objects and weights must have the same size got size(objects) = $(size(objects)) and size(weights) = $(size(weights)) instead."))
        end
        if hasduplicates(objects)
            throw(ArgumentError("The objects are not unique!"))
        end
        new(Dict{T, Int}(objects .=> weights))
    end
end

# convenience outer constructors (with no need for type declarations)
EmpiricalMeasure() = EmpiricalMeasure{Any}()
EmpiricalMeasure(dict) = EmpiricalMeasure{keytype(dict)}(dict)
EmpiricalMeasure(objects, weights) = EmpiricalMeasure{eltype(objects)}(objects,weights)


"""
`empiricalmeasure(data_sample)`

Returns an `EmpiricalMeasure` from a `data_sample`.

# Examples
- `empiricalmeasure([1,2,1,1,5])` returns `EmpiricalMeasure{Int64}(objects = [1,2,5],weights = [3,1,1])`
"""
function empiricalmeasure(data_sample)
    return countmap(data_sample) |> EmpiricalMeasure
end

# this function specifies how to display an EmpiricalMeasure in the REPL
function Base.show(io::IO, em::EmpiricalMeasure{T}) where T
    println(io, "EmpiricalMeasure{$T}")
    if length(em.data) ≤ 20
        obj = objects(em)
        wei = weights(em)
        right_order = sortperm(obj)
        println(io, "objects = $(obj[right_order])")
        println(io, "weights = $(wei[right_order])")
    else # if there's too many objects, we just show the first and the last one.
        O = [minimum(keys(em.data)),maximum(keys(em.data))] # objects to show
        W = [em[O[1]],em[O[2]]]       # weights to show

        println(io, "objects = [$(O[1]),…,$(O[2])]")
        println(io, "weights = [$(W[1]),…,$(W[2])]")
    end
end

# These functions allow to access and modify the underlying Dict
Base.getindex(em::EmpiricalMeasure, key) = em.data[key]
Base.setindex!(em::EmpiricalMeasure, value, key) = (em.data[key] = value)
Base.get(em::EmpiricalMeasure,key,default_value) = get(em.data,key,default_value)

# Define a function to iterate over the key-value pairs
Base.iterate(em::EmpiricalMeasure) = iterate(em.data)
Base.iterate(em::EmpiricalMeasure, state) = iterate(em.data, state)

# return a (dense) array with the objects and the weights of an empirical measure
function objects(em::EmpiricalMeasure;sort = true)    
    if sort
        sorted_dict = StatsBase.sort(em.data)
        return keys(sorted_dict) |> collect
    else
        return em.data |> keys |> collect
    end
end

function weights(em::EmpiricalMeasure;sort = true)    
    if sort
        sorted_dict = StatsBase.sort(em.data)
        return values(sorted_dict) |> collect
    else
        return em.data |> values |> collect
    end
end

# Define a function to get the length of the EmpiricalMeasure
Base.length(em::EmpiricalMeasure) = length(em.data)

# Define a function to iterate over the key-value pairs
Base.eltype(em::EmpiricalMeasure) = keytype(em.data)