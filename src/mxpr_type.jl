abstract AbstractMxpr

type Mxpr{T} <: AbstractMxpr
    head::Symbol
    args::Array{Any,1}
    jhead::Symbol    # Actual exact Julia head: :call, etc
    clean::Bool      # Is the expression canonicalized ?
end



# The will be changed. The field `jhead` will probably disappear.
# How many and what kinds of dirty bits may change.
