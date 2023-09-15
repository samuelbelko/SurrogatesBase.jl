module SurrogatesBase

import Statistics: mean, var
import Base: rand

export AbstractSurrogate,
    add_point!,
    update_hyperparameters!, hyperparameters,
    posterior, mean, var, rand, logpdf

"""
    abstract type AbstractSurrogate{D, R} end

An abstract type for surrogate interface, parametrized by domain type `D` and
range type `R` of the underlying function that is being approximated.

    (s::AbstractSurrogate{D, R})(x::D) where {D, R}

Subtypes of `AbstractSurrogate` need to be callable with input points `x` that
evaluates the surrogate at `x`.

 # Examples
 ```jldoctest
 julia> struct ZeroSurrogate{D, R} <: AbstractSurrogate{D, R} end

 julia> (::ZeroSurrogate{D,R})(x::D) where {D,R} = 0

 julia> s = ZeroSurrogate{Int, Int}()
 ZeroSurrogate{Int64, Int64}()

 julia> s(4) == 0
 true
 ```
 """
abstract type AbstractSurrogate{D, R} <: Function end

"""
    add_point!(s::AbstractSurrogate{D, R}, new_x::D, new_y::R) where {D, R}

Add an evaluation `new_y` at point `new_x` to the surrogate.
"""
function add_point! end
"""
    add_point!(s::AbstractSurrogate{D, R}, new_xs::AbstractVector{D}, new_ys::AbstractVector{R}) where {D, R}

Add evaluations `new_ys` at points `new_xs` to the surrogate.

Use `add_point!(s, eachslice(X, dims = 2), new_ys)` if `X` is a matrix.
"""
function add_point!(s::AbstractSurrogate{D, R},
    new_xs::AbstractVector{D},
    new_ys::AbstractVector{R}) where {D, R}
    add_point!.(Ref(s), new_xs, new_ys)
end

"""
    update_hyperparameters!(s::AbstractSurrogate, prior)

Use prior on hyperparameters passed in `prior` to perform an update.

See also [`hyperparameters`](@ref).
"""
function update_hyperparameters! end

"""
    hyperparameters(s::AbstractSurrogate)

Return a `NamedTuple`, in which names are hyperparameters and values are currently used
values of hyperparameters in `s`.

See also [`update_hyperparameters!`](@ref).
"""
function hyperparameters end

"""
    posterior(s::AbstractSurrogate{D, R}, xs::AbstractVector{D}) where {D, R}

Return a joint posterior at points `xs`.

Use `posterior(s, eachslice(X, dims = 2))` if `X` is a matrix.
"""
function posterior end
"""
    posterior(s::AbstractSurrogate{D, R}, x::D) where {D, R}

Return posterior at point `x`.
"""
posterior(s::AbstractSurrogate{D, R}, x::D) where {D, R} = posterior(s, [x])

"""
    mean(s::AbstractSurrogate{D, R}, x::D) where {D, R}

Return mean at point `x`.
"""
function mean end
"""
    mean(s::AbstractSurrogate{D, R}, xs::AbstractVector{D}) where {D, R}

Return a vector of means at points `xs`.

Use `mean(s, eachslice(X, dims = 2))` if `X` is a matrix.
"""
function mean(s::AbstractSurrogate{D, R}, xs::AbstractVector{D}) where {D, R}
    mean.(Ref(s), xs)
end

"""
    var(s::AbstractSurrogate{D, R}, x::D) where {D, R}

Return variance at point `x`.
"""
function var end

"""
    var(s::AbstractSurrogate{D, R}, xs::AbstractVector{D}) where {D, R}

Return a vector of variances at points `xs`.
"""
function var(s::AbstractSurrogate{D, R}, xs::AbstractVector{D}) where {D, R}
    var.(Ref(s), xs)
end

"""
    rand(s::AbstractSurrogate{D, R}, xs::AbstractVector{D}) where {D, R}

Return a sample from the joint posterior at points `xs`.
"""
function rand end

"""
    rand(s::AbstractSurrogate{D,R}, x::D)

Return a sample from the posterior distribution at a point `x`.
"""
rand(s::AbstractSurrogate{D, R}, x::D) where {D, R}= only(rand(s::AbstractSurrogate, [x]))

"""
    logpdf(s::AbstractSurrogate)

Return a log marginal posterior predictive probability.
"""
function logpdf end

end
