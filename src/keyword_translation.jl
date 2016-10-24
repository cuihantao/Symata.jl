const KeywordDict = Dict( :Complex => :complex,
                          :Basic => :basic,
                          :Conditions => :conds,
                          :Modulus => :modulus,
                          :Gaussian => :gaussian,
                          :Force => :force,
                          :Deep => :deep)

@sjdoc Deep """
   Deep

an option for the functions `Together` and `Expand`.
"""

@sjdoc Conditions """
   Conditions

an option for `Integrate` and other integral transforms.
"""

@sjdoc Modulus """
    Modulus

an option for `Factor`.
"""

@sjdoc Gaussian """
    Gaussian

an option specifiying that solutions including Gaussian integers should be returned.
"""

# Convert Mxpr to sympy, pulling out Rule(a,b) to dict of keyword args.
# That is, we separate keyword args from positional argss
function sjtopy_kw{T<:Mxpr}(mx::T, kws)
    args = margs(mx)
    nargs = newargs()
    for i in 1:length(args)
        if is_Mxpr(args[i], :Rule)
            lhs = get(KeywordDict, args[i][1], args[i][1])
            rhs = args[i][2]
            kws[lhs] = rhs
        else
            push!(nargs, sjtopy(args[i]))
        end
    end
    nargs
end

function sjtopy_kw{T<:Mxpr}(mx::T)
    kws = Dict()  # type ? probably symbols
    nargs  = sjtopy_kw(mx, kws)
    return (nargs, kws)
end

# Separate the Rule()'s from other arguments in an Mxpr expression
# Store keywords in a Dict so they can by passed as keword arguments.
# These do the same as above, but no conversion to sympy.
function separate_rules{T<:Mxpr}(mx::T, kws)
    args = margs(mx)
    nargs = newargs()
    for i in 1:length(args)
        if is_Mxpr(args[i], :Rule)
            length(args[i]) != 2 && error("Rule requires two arguments. " * length(args[i]) * " found.")
            kws[args[i][1]] = args[i][2]
        else
            push!(nargs, args[i])
        end
    end
    nargs
end

function separate_rules{T<:Mxpr}(mx::T)
    kws = Dict()  # type ? probably symbols
    nargs  = separate_rules(mx, kws)
    return (nargs, kws)
end

# Mma uses the expression Rule(a,b) to represent a keyword
# argument. It also uses Rule for many other things. This is awkward.
# Here, we separate keyword Rules from all other args including Rules
# that are not meant to be keywords.
# kws -- Dict of legal keywords with their default values.
# Only Rules with keywords in kws will be extracted
function separate_known_rules{T<:Mxpr}(mx::T, kws)
    args = margs(mx)
    nargs = newargs()
    for i in 1:length(args)
        a = args[i]
        if is_Mxpr(a, :Rule)
            @checknargs a :Rule 2
            if haskey(kws,a[1])
                kws[a[1]] = a[2]
            else
                push!(nargs, a)
            end
        else
            push!(nargs, a)
        end
    end
    nargs
end