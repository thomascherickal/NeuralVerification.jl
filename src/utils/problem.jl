"""
    Problem(network, input, output)

Problem definition for neural verification.
- `network` is of type `Network`
- `input` belongs to `AbstractPolytope` in `LazySets.jl`
- `output` belongs to `AbstractPolytope` in `LazySets.jl`

The verification problem consists of: for all  points in the input set,
the corresponding output of the network must belong to the output set.
"""
struct Problem{P<:AbstractPolytope, Q<:AbstractPolytope}
    network::Network
    input::P
    output::Q
end

"""
    Result
Supertype of all result types.

See also: [`BasicResult`](@ref), [`CounterExampleResult`](@ref), [`AdversarialResult`](@ref), [`ReachabilityResult`](@ref)
"""
abstract type Result end

status(result::Result) = result.status

function validate_status(st::Symbol)
    @assert st ∈ (:SAT, :UNSAT, :Unknown) "unexpected status code: `:$st`.\nOnly (:SAT, :UNSAT, :Unknown) are accepted"
    return st
end

"""
    BasicResult(status::Symbol)

Result type that captures whether the input-output constraint is satisfied.
Possible status values:\n
    :SAT (io constraint is satisfied always)\n
    :UNSAT (io constraint is violated)\n
    :Unknown (could not be determined)
"""
struct BasicResult <: Result
    status::Symbol
end

"""
    CounterExampleResult(status, counter_example)

Like `BasicResult`, but also returns a `counter_example` if one is found (if status = :UNSAT).
The `counter_example` is a point in the input set that, after the NN, lies outside the output set.
"""
struct CounterExampleResult <: Result
    status::Symbol
    counter_example::Vector{Float64}
    CounterExampleResult(s, ce) = new(validate_status(s), ce)
end

"""
    AdversarialResult(status, max_disturbance)

Like `BasicResult`, but also returns the maximum allowable disturbance in the input (if status = :UNSAT).
"""
struct AdversarialResult <: Result
	status::Symbol
	max_disturbance::Float64
    AdversarialResult(s, md) = new(validate_status(s), md)
end

"""
    ReachabilityResult(status, reachable)

Like `BasicResult`, but also returns the output reachable set given the input constraint (if status = :UNSAT).
"""
struct ReachabilityResult <: Result
	status::Symbol
	reachable::Vector{<:AbstractPolytope}
    ReachabilityResult(s, r) = new(validate_status(s), r)
end

# Additional constructors:
CounterExampleResult(s) = CounterExampleResult(s, Float64[])
AdversarialResult(s)    = AdversarialResult(s, -1.0)
ReachabilityResult(s)   = ReachabilityResult(s, AbstractPolytope[])
