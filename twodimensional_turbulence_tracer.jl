using Oceananigans
using Printf

grid = RectilinearGrid(GPU(),
                       size = (1024, 1024),
                       x = (-π, π),
                       y = (-π, π),
                       topology = (Periodic, Periodic, Flat))

model = NonhydrostaticModel(; grid, advection=WENO(), tracers=:c)

δ = 0.5
cᵢ(x, y) = exp(-(x^2 + y^2) / 2δ^2)
ϵ(x, y) = 2rand() - 1
set!(model, u=ϵ, v=ϵ, c=cᵢ)

simulation = Simulation(model; Δt=1e-3, stop_time=80)
conjure_time_step_wizard!(simulation, cfl=0.2, IterationInterval(10))

function progress_message(sim)
    max_abs_u = maximum(abs, sim.model.velocities.u)
    walltime = prettytime(sim.run_wall_time)

    return @info @sprintf("Iteration: %04d, time: %1.3f, Δt: %.2e, max(|u|) = %.1e, wall time: %s\n",
                          iteration(sim), time(sim), sim.Δt, max_abs_u, walltime)
end

add_callback!(simulation, progress_message, IterationInterval(500))

u, v, w = model.velocities

ζ = Field(∂x(v) - ∂y(u))

output = (ζ=ζ, c=model.tracers.c)

filename = "tracer_diffusion"

simulation.output_writers[:velocities] = JLD2OutputWriter(model, output; filename = filename * ".jld2",
                                                          schedule = TimeInterval(0.2),
                                                          overwrite_existing = true)

run!(simulation)

# Load output and animate

ζ_timeseries = FieldTimeSeries(filename * ".jld2", "ζ")
c_timeseries = FieldTimeSeries(filename * ".jld2", "c")

times = ζ_timeseries.times

using CairoMakie
set_theme!(Theme(fontsize = 20))

fig = Figure(size=(1200, 600))

axis_kwargs = (xlabel = "x",
               ylabel = "y",
               limits = ((-π, π), (-π, π)),
               aspect = AxisAspect(1))

axζ = Axis(fig[2, 1]; title = "vorticity", axis_kwargs...)
axc = Axis(fig[2, 2]; title = "tracer", axis_kwargs...)

n = Observable(1)

ζ = @lift ζ_timeseries[$n]
c = @lift c_timeseries[$n]

heatmap!(axζ, ζ; colormap = :balance, colorrange = (-2, 2))
heatmap!(axc, c; colormap = :speed, colorrange = (0, 0.5))

title = @lift "t = " * string(round(times[$n], digits=1))

Label(fig[1, 1:2], title, fontsize=24, tellwidth=false)

# record animation

frames = 1:length(times)

@info "Making an animation of vorticity and tracer..."

record(fig, filename * ".mp4", frames, framerate=24) do i
    @info "frame $i out of $(length(times))"
    n[] = i
end
