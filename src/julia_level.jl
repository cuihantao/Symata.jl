# This is for testing using Symata code from Julia

## These just call apprules, so they are in general no more efficient than calling from Symata directly.
## In contrast, the trig functions below filter numeric arguments and are exactly as efficient as pure Julia
## when called from within Julia functions for which the compiler can infer types.
## Similar filters could be written for the functions wrapped here.
##
for f in (:Expand, :Factor, :Head, :Take, :Simplify, :Integrate, :DirichletEta, :Times, :List, :Plus, :Exp, :Power, :Length)
    @eval ($f)(mx...) = apprules(mxpr($(QuoteNode(f)),mx...))
    @eval export $f
end

## Use Julia inference and dispatch to call numeric functions directly with no overhead when possible.
## TODO: Handle two arg functions, etc.
for f in (:cos, :sin, :abs, :tan, :exp, :log, (:acos, :ArcCos) , (:asin, :ArcSin), (:atan, :ArcTan ),
          :cot, :cosh, :sinh, :tanh, :sqrt, :erf, :erfc, :gamma, :zeta)
    local uf
    if isa(f, Tuple)
        uf = f[2]
        f = f[1]
    else
        uf = Symbol(uppercasefirst(string(f)))
    end
    @eval ($uf)(x::AbstractFloat) = ($f)(x)
    @eval ($uf)(x::AbstractArray{T}) where {T<:AbstractFloat} = ($f)(x)
    @eval ($uf)(x::Complex{T}) where {T<:AbstractFloat} = ($f)(x)
    @eval ($uf)(x) = apprules(mxpr($(QuoteNode(uf)),x))
    @eval export $uf
end

# Integrate(mx::Mxpr,symorlist) = apprules(mxpr(:Integrate,mx,symorlist))
# export Integrate

const Pi = :Pi
export Pi

const E = Base.MathConstants.e     # could make this the symbol ?
export E

#### Arithmetic operators

## methods for Julia math functions that operate
## on symbols and Mxpr. Some of these are used
## in Symata code. They can also be used at the Julia
## repl.

# SJSym is an alias of Symbol

"""
    _symatamath()

define math methods in the Symata module that operate on symbols. This allows Julia expressions such as
```
:a + :b
:a - 3
:c^2
```

Note: we now call syamtamath() after its definition. It defines these operators in the Symata module scope.

obsolete: These methods are disabled by default because they extend `Base` methods for `Base` types. These methods are
in general reserved for definition in future versions of Julia. There is some chance that these will be given conflicting
definitions in the Julia base language in the future. However, we know of no such plans at present.

These are all binary methods between Julia `Number`s and `Symbol`s extending `*`, `+`, `-`, and `^`.

There are similar methods for arithmetic operators between numbers or symbols and Symata expressions, but
these are defined by default.
"""
function _symatamath()
    @eval begin
        Base.:*(a::Number,b::SJSym) = mxpr(:Times,a,b)  # why not mmul ? TODO: try using mmul, etc. here
        Base.:*(a::SJSym,b::SJSym) = mxpr(:Times,a,b)
        Base.:*(a::SJSym,b::Number) = mxpr(:Times,b,a)
        Base.:+(a::SJSym,b::Number) = mxpr(:Plus,b,a)
        Base.:+(a::SJSym,b::SJSym) = mxpr(:Plus,a,b)
        Base.:+(a::Number,b::SJSym) = mxpr(:Plus,a,b)
        Base.:-(a::Number,b::SJSym) = mplus(a, mxpr(:Times,-1,b))
        Base.:-(a::SJSym,b::Number) = mplus(a, -b)
        Base.:-(a::SJSym,b::SJSym) = mplus(a, mxpr(:Times,-1,b))
        Base.:/(a::SJSym,b::SJSym) = mmul(a, mmul(-1,b))
        Base.:/(a::Number,b::SJSym) = mmul(a, mmul(-1,b))
        Base.:/(a::SJSym,b::Number) = mmul(a, mmul(-1,b))
        Base.:^(base::SJSym,expt::Integer) = mxpr(:Power,base,expt)
        Base.:^(base::SJSym,expt) = mxpr(:Power,base,expt)
    end
    nothing
end

_symatamath()

"""
    symatamath()

defines Base methods for arithmetic operators `*`, `+`, `-`, `^` between `Symbols` and between `Symbols` and `Numbers`. `symatamath()` is *not*
necessary when running Symata and using J(expr) to evaluate Julia code.  `J()` evaluates in the Symata
module where these methods are already defined.  `symatamath()` is useful in Julia mode where expressions
are evaluated in  `Main`.

These methods are not defined in `Main` by default because defining `Base` methods between core Julia objects could
conflict with future versions of Julia.
"""
function symatamath()
    @eval begin
        Base.:*(a::Number,b::SJSym) = mxpr(:Times,a,b)  # why not mmul ?
        Base.:*(a::SJSym,b::SJSym) = mxpr(:Times,a,b)
        Base.:*(a::SJSym,b::Number) = mxpr(:Times,b,a)
        Base.:+(a::SJSym,b::Number) = mxpr(:Plus,b,a)
        Base.:+(a::SJSym,b::SJSym) = mxpr(:Plus,a,b)
        Base.:+(a::Number,b::SJSym) = mxpr(:Plus,a,b)
        Base.:-(a::Number,b::SJSym) = mplus(a, mxpr(:Times,-1,b))
        Base.:-(a::SJSym,b::Number) = mplus(a, -b)
        Base.:-(a::SJSym,b::SJSym) = mplus(a, mxpr(:Times,-1,b))
        Base.:^(base::SJSym,expt::Integer) = mxpr(:Power,base,expt)
        Base.:^(base::SJSym,expt) = mxpr(:Power,base,expt)
    end
    nothing
end

## Arithmetic methods involving annotated Symata types. These will never conflict with Base Julia,
## so they are safe to define.

Base.:*(a::Mxpr,b::Mxpr) = mxpr(:Times,a,b)
Base.:*(a::Mxpr,b) = mxpr(:Times,a,b)
Base.:*(a,b::Mxpr) = mxpr(:Times,a,b)

# Base.:*(a::Mxpr,b::Mxpr) = mxpr(:Times,a,b)
# Base.:*(a::Mxpr,b) = mxpr(:Times,a,b)
# Base.:*(a,b::Mxpr) = mxpr(:Times,a,b)

Base.:+(a::Mxpr,b::Mxpr) = mxpr(:Plus,a,b)
Base.:+(a::Mxpr,b) = mxpr(:Plus,a,b)
Base.:+(a,b::Mxpr) = mxpr(:Plus,a,b)

# Base.:+(a::Mxpr,b::Mxpr) = mxpr(:Plus,a,b)
# Base.:+(a::Mxpr,b) = mxpr(:Plus,a,b)
# Base.:+(a,b::Mxpr) = mxpr(:Plus,a,b)

Base.:-(a,b::Mxpr) = mxpr(:Plus,a,mxpr(:Times,-1,b))
Base.:-(a::Mxpr) = mxpr(:Times,-1,a)

Base.:^(base::Mxpr,expt::Integer) = mxpr(:Power,base,expt)
Base.:^(base::Mxpr,expt) = mxpr(:Power,base,expt)

Base.:/(a::Mxpr, b) = mxpr(:Times, a, mxpr(:Power, b, -1))
Base.inv(m::Mxpr) = mxpr(:Power, m, -1)

## (Aug 16, 2018) Upgrading for Julia v1.0 from v0.7 Comment these
## out. I think this code is very old
# Base.:-(a,b::Mxpr) = mxpr(:Plus,a,mxpr(:Times,-1,b))
# Base.:-(a::Mxpr) = mxpr(:Times,-1,a)
# Base.:^(base::Mxpr,expt::Integer) = mxpr(:Power,base,expt)
# Base.:^(base::Mxpr,expt) = mxpr(:Power,base,expt)
# Base.:/(a::Mxpr,b) = mxpr(:Times,a,mxpr(:Power,b,-1))

## Symata uses module-local functions * + - ^ /
## For anything not defined in Symata, the Base methods are called.
##
## (Aug 16, 2018) Upgrading for Julia v1.0 from v0.7
## Julia v1.0 says I am extending Base on the LHS
## and that I must import the Symbols. That is:
## Base.:*(args...) = Base.:*(args...) Makes no sense.
## What's going on here ?
## I will comment thest out for now,.

# *(args...) = Base.:*(args...)
# +(args...) = Base.:+(args...)
# -(args...) = Base.:-(args...)
# ^(args...) = Base.:^(args...)
# /(args...) = Base.:/(args...)

## This was commented out long before (Aug 16, 2018)
# Already defined elsewhere (... where ?)
# I = im
# export I

# TODO: make an infix assignment operator... hm or  macro
