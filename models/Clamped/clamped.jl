#=
This model is taken from [1]. The theoretical derivations of the analytic solution can be found in [2].

[1] Malakiyeh, Mohammad Mahdi, Saeed Shojaee, and Klaus-Jürgen Bathe. "The Bathe time integration method revisited for prescribing desired numerical dissipation." Computers & Structures 212 (2019): 289-298.

[2] Mechanical Vibrations, Gerardin et al, page 250-251.
=#

using ReachabilityAnalysis, LinearAlgebra, LazySets
using ReachabilityAnalysis: solve, discretize
using LazySets.Arrays
using SparseArrays

LazySets.set_ztol(Float64, 1e-15)
LazySets.set_atol(Float64, 1e-15)
LazySets.set_rtol(Float64, 1e-15)

function clamped_matrices(; N=1000, E=30e6, ρ=7.3e-4, A=1, L=200)
    ℓ = L / N
    K = (E * A / ℓ) * SymTridiagonal(fill(2.0, N), fill(-1.0, N))
    K[end, end] = E * A / ℓ

    M = (ρ * A * ℓ / 2) * Diagonal(vcat(fill(2.0, N-1), 1.0))
    M[end, end] = ρ * A * ℓ / 2

    return M, K
end

function clamped_free(; N)
    M, K = clamped_matrices(N=N)
    C = zeros(N, N) # no damping
    sys = SecondOrderLinearContinuousSystem(M, C, K)
end

function clamped_forced(; N, F=10e3, E=30e6, A=1)
    M, K = clamped_matrices(N=N)
    C = zeros(N, N) # no damping
    F = vcat(zeros(N-1), F) # the right-most node is excited
    sys = SecondOrderAffineContinuousSystem(M, C, K, F)
end

function clamped(; a=0.0, b=0.0, # ignored if damped = false
                   constant=true,
                   N,            # number of elements
                   homogeneize,  # flag to homogeneize the system
                   damped)       # flag to consider damping C = a*K + b*M

    sys = clamped_forced(N=N)
    M = sys.M; K = sys.K; F = sys.b

    invM = inv(M)
    ZN = zeros(N, N)
    IN = Matrix(1.0I, N, N)

    if damped
        C = a*K + b*M
        A = [ZN           IN       ;
            -invM*K       -invM*C]

    else
        A = [ZN           IN ;
            -invM*K       ZN]
    end

    f0 = vcat(zeros(N), invM * F)

    if homogeneize
        n = 2N
        Aext = zeros(n+1, n+1)
        Aext[1:n, 1:n] .= A
        Aext[1:n, n+1] .= f0
        Aext = sparse(Aext)
        S = @system(x' = Aext*x)

    else
        S = @system(x' = A*x + f0)
    end

    if !constant
        @assert homogeneize == false

        # model time-varying forcing
        X = Universe(statedim(S))
        ΔF = Interval(0.99, 1.01)
        S = @system(x' = S.A * x + S.c * u, u ∈ ΔF, x ∈ X)
    end

    return S
end
