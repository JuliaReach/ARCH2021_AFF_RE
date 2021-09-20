using BenchmarkTools, Plots, Plots.PlotMeasures, LaTeXStrings
using BenchmarkTools: minimum, median

SUITE = BenchmarkGroup()
model = "CLAMPED"
cases = ["CB21d-100-C", # constant input set
         "CB21d-100-F", # bounded but arbitrarily-varying input set
         "CB21d-100-C-discrete",
         "CB21d-100-F-discrete"]

measure = [] # maximum value of the velocity at node 70
validation = []
SUITE[model] = BenchmarkGroup()

include("clamped.jl")

# ----------------------------------------
#  CB21d-100-C
# ----------------------------------------
S = clamped(N=100, a=1e-6, b=1e-6, damped=true, homogeneize=true)
alg = LGG09(δ=1e-6, vars=[70, 170], n=201)
e170 = alg.template.directions[2]
ΔF0 = Interval(0.99, 1.01)
X0 = Singleton(zeros(200)) × ΔF0
prob = InitialValueProblem(S, X0)

sol_CB21d100C = solve(prob, NSTEPS=10_000, alg=alg)  # warm-up run
property = 1 # nothing to verify
push!(validation, property)
push!(measure, ρ(e170, sol_CB21d100C))

SUITE[model][cases[1]] = @benchmarkable solve($prob, NSTEPS=10_000, alg=$alg)

# ----------------------------------------
#  CB21d-100-F
# ----------------------------------------
S = clamped(N=100, a=1e-6, b=1e-6, damped=true, homogeneize=false, constant=false)
alg = LGG09(δ=1e-7, vars=[70, 170], n=200)
e170 = alg.template.directions[2]
X0 = Singleton(zeros(200))
prob = InitialValueProblem(S, X0)

sol_CB21d100F = solve(prob, NSTEPS=100_000, alg=alg) # warm-up run
property = 1 # nothing to verify
push!(validation, Int(property))
push!(measure, ρ(e170, sol_CB21d100F))

SUITE[model][cases[2]] = @benchmarkable solve($prob, NSTEPS=100_000, alg=$alg)

# ----------------------------------------
#  CB21d-100-C-discrete
# ----------------------------------------
dtn = 9.88e-7
S = clamped(N=100, a=1e-6, b=1e-6, damped=true, homogeneize=true)
alg = LGG09(δ=dtn, vars=[70, 170], n=201, approx_model=NoBloating())
e170 = alg.template.directions[2]
ΔF0 = Interval(0.99, 1.01)
X0 = Singleton(zeros(200)) × ΔF0
prob = InitialValueProblem(S, X0)

sol_CB21d100C_discrete = solve(prob, T=0.01, alg=alg)  # warm-up run
property = 1 # nothing to verify
push!(validation, property)
push!(measure, ρ(e170, sol_CB21d100C_discrete))

SUITE[model][cases[3]] = @benchmarkable solve($prob, T=0.01, alg=$alg)

# ----------------------------------------
#  CB21d-100-F-discrete
# ----------------------------------------
S = clamped(N=100, a=1e-6, b=1e-6, damped=true, homogeneize=false, constant=false)
alg = LGG09(δ=dtn, vars=[70, 170], n=200, approx_model=NoBloating())
e170 = alg.template.directions[2]
X0 = Singleton(zeros(200))
prob = InitialValueProblem(S, X0)

sol_CB21d100F_discrete = solve(prob, T=0.01, alg=alg) # warm-up run
property = 1 # nothing to verify
push!(validation, Int(property))
push!(measure, ρ(e170, sol_CB21d100F_discrete))

SUITE[model][cases[4]] = @benchmarkable solve($prob, T=0.01, alg=$alg)

# ==============================================================================
# Execute benchmarks and save benchmark results
# ==============================================================================

# tune parameters
tune!(SUITE)

# run the benchmarks
results = run(SUITE, verbose=true)

# return the sample with the smallest time value in each test
println("minimum time for each benchmark:\n", minimum(results))

# return the median for each test
println("median time for each benchmark:\n", median(results))

# export runtimes
runtimes = Dict()
for (i, c) in enumerate(cases)
   t = median(results[model][c]).time * 1e-9
   runtimes[c] = round(t, digits=4)
end

for (i, c) in enumerate(cases)
   print(io, "JuliaReach, $model, $c, $(validation[i]), $(runtimes[c]), $(measure[i])\n")
end

# ==============================================================================
# Plot
# ==============================================================================

# Constant force case
fig = Plots.plot()
Plots.plot!(fig, sol_CB21d100C, vars=(0, 170),
           color=:blue, alpha=0.5, lw=1.0, linecolor=:blue,
           tickfont=font(30, "Times"), guidefontsize=45,
           xlab=L"t",
           ylab=L"v_{70}",
           xtick=([0, 0.0025, 0.005, 0.0075, 0.01],
                  [L"0.0", L"0.0025", L"0.0050", L"0.0075", L"0.0100"]),
           ytick=([-60, -40, -20, 0, 20, 40, 60],
                  [L"-60", L"-40", L"-20", L"0", L"20", L"40", L"60"]),
           xlims=(0, 0.01), ylims=(-75, 75),
           bottom_margin=6mm, left_margin=5mm, right_margin=15mm, top_margin=3mm,
           size=(1000, 1000))

savefig(fig, joinpath(@__DIR__, "ARCH-COMP21-JuliaReach-Clamped_CB21d100C-vel.pdf"))
savefig(fig, joinpath(@__DIR__, "ARCH-COMP21-JuliaReach-Clamped_CB21d100C-vel.png"))

# Time-varying force case
fig = Plots.plot()
Plots.plot!(fig, sol_CB21d100F, vars=(0, 170),
           color=:blue, alpha=0.5, lw=1.0, linecolor=:blue,
           tickfont=font(30, "Times"), guidefontsize=45,
           xlab=L"t",
           ylab=L"v_{70}",
           xtick=([0, 0.0025, 0.005, 0.0075, 0.01],
                  [L"0.0", L"0.0025", L"0.0050", L"0.0075", L"0.0100"]),
           ytick=([-60, -40, -20, 0, 20, 40, 60],
                  [L"-60", L"-40", L"-20", L"0", L"20", L"40", L"60"]),
           xlims=(0, 0.01), ylims=(-85, 85),
           bottom_margin=6mm, left_margin=5mm, right_margin=15mm, top_margin=3mm,
           size=(1000, 1000))

savefig(fig, joinpath(@__DIR__, "ARCH-COMP21-JuliaReach-Clamped_CB21d100F-vel.pdf"))
savefig(fig, joinpath(@__DIR__, "ARCH-COMP21-JuliaReach-Clamped_CB21d100F-vel.png"))

sol_CB21d100C = nothing
sol_CB21d100F = nothing
sol_CB21d100C_discrete = nothing
sol_CB21d100F_discrete = nothing
GC.gc()

#=
fig = plot()
plot!(fig, sol_CB21d100C, vars=(0, 70), lw=0.0, c=:blue, xlab="t", ylab="Position at node 70")
savefig(fig, joinpath(@__DIR__, "ARCH-COMP21-JuliaReach-Clamped_CB21d100C-pos.png"))

fig = plot()
plot!(fig, sol_CB21d100C, vars=(0, 170), lw=0.0, c=:blue, xlab="t", ylab="Velocity at node 70")
savefig(fig, joinpath(@__DIR__, "ARCH-COMP21-JuliaReach-Clamped_CB21d100C-vel.pdf"))

fig = plot(xlab="t", ylab="Velocity at node 70", xlims=(2e-4, 1e-3), ylims=(60, 75))
plot!(fig, sol_CB21d100C, vars=(0, 170), lw=0.0, c=:blue)
savefig(fig, joinpath(@__DIR__, "ARCH-COMP21-JuliaReach-Clamped_CB21d100C-vel-zoom.pdf"))

# Time-varying force case
fig = plot()
plot!(fig, sol_CB21d100F, vars=(0, 70), lw=0.0, c=:blue, xlab="t", ylab="Position at node 70")
savefig(fig, joinpath(@__DIR__, "ARCH-COMP21-JuliaReach-Clamped_CB21d100F-pos.png"))

fig = plot()
plot!(fig, sol_CB21d100F, vars=(0, 170), lw=0.0, c=:blue, xlab="t", ylab="Velocity at node 70")
savefig(fig, joinpath(@__DIR__, "ARCH-COMP21-JuliaReach-Clamped_CB21d100F-vel.png"))

fig = plot(xlab="t", ylab="Velocity at node 70", xlims=(7e-3, 10e-3), ylims=(0, 80))
plot!(fig, sol_CB21d100F, vars=(0, 170), lw=0.0, c=:blue)
savefig(fig, joinpath(@__DIR__, "ARCH-COMP21-JuliaReach-Clamped_CB21d100F-vel-zoom.png"))
=#
