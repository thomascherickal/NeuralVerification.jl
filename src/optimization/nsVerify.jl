"""
    NSVerify(optimizer, m::Float64)

NSVerify finds counter examples using mixed integer linear programming.

# Problem requirement
1. Network: any depth, ReLU activation
2. Input: hyperrectangle or hpolytope
3. Output: halfspace

# Return
`CounterExampleResult`

# Method
MILP encoding (using `m`). No presolve.
Default `optimizer` is `GLPKSolverMIP()`. Default `m` is `1000.0` (should be large enough to avoid approximation error).

# Property
Sound and complete.

# Reference
[A. Lomuscio and L. Maganti,
"An Approach to Reachability Analysis for Feed-Forward Relu Neural Networks,"
*ArXiv Preprint ArXiv:1706.07351*, 2017.](https://arxiv.org/abs/1706.07351)
"""
@with_kw struct NSVerify{O<:AbstractMathProgSolver}
    optimizer::O = GLPKSolverMIP()
    m::Float64   = 1000.0  # The big M in the linearization
end

function solve(solver::NSVerify, problem::Problem)
    model = Model(solver = solver.optimizer)
    neurons = init_neurons(model, problem.network)
    deltas = init_deltas(model, problem.network)
    add_set_constraint!(model, problem.input, first(neurons))
    add_complementary_set_constraint!(model, problem.output, last(neurons))
    encode_mip_constraint!(model, problem.network, solver.m, neurons, deltas)
    zero_objective!(model)
    status = solve(model, suppress_warnings = true)
    if status == :Optimal
        return CounterExampleResult(:UNSAT, getvalue(first(neurons)))
    end
    if status == :Infeasible
        return CounterExampleResult(:SAT)
    end
    return CounterExampleResult(:Unknown)
end
