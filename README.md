# ATOC30006-demos

This repository includes scripts to reproduce animations used during the course ["Modern and future climate" (ATOC30006)](https://handbook.unimelb.edu.au/2024/subjects/atoc30006/print) at the University of Melbourne.

Simulations use the [Julia programming language](https://julialang.org) and  are based on the Julia package: Oceananigans.jl. We refer you to the Oceananigans.jl [repository](https://github.com/CliMA/Oceananigans.jl) and the [documentation](https://clima.github.io/OceananigansDocumentation/stable/) for more information.

Steps to reproduce the animations:

1. [Download Julia](https://julialang.org/downloads/)

2. Clone this repository.

3. From the local copy directory of this repository, launch Julia and type

```julia
julia> using Pkg

julia> Pkg.activate(".")
```

to install all the required packages.

4. Then:

```julia
julia> include("the_script_you_want_to_run.jl")
```

should do the job!

Contents:

* `twodimensional_turbulence_tracer.jl`: two-dimensional turbulence and a passive tracer. Change the positional argument `GPU()` to `CPU()` in the grid constructor, if you are running this on a device that does not have an Nvidia GPU. If running on CPU, then consider reducing the resolution from 1024 to 128 to begin with.
