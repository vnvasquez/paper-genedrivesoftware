# GeneDrive.jl: A Julian approach to simulating biological dynamics and control

Code and data for initial paper submission.

Authors: Váleri N. Vásquez<sup>1,2</sup>, David Anthoff<sup>1</sup>

Affiliations: 
1. Energy and Resources Group, Rausser College of Natural Resources, University of California Berkeley, CA, USA
2. Department of Electrical Engineering and Computer Sciences, College of Engineering, University of California Berkeley, CA, USA

## Hardware and software requirements

You need to install [Julia](http://julialang.org/) to run the replication code. We tested this code on Julia version 1.9.1.

Make sure to install Julia in such a way that the Julia binary is on the `PATH`.

## Linear Solver

We use HSL as the linear solver. You need to obtain a license and download `HSL_jll.jl` from https://licences.stfc.ac.uk/product/julia-hsl. You should get the LBT version.

Once you downloaded `HSL_jll` you need to modify the project in this repository to use that version of `HSL_jll`. To do so, activate the project in this repository, and then in the package REPL run

```
pkg> dev <PATH TO YOUR DOWNLOAD OF HSL_JLL>
```

## Running the replication script

To recreate all outputs and figures for this paper, open a OS shell and change into the folder where you downloaded the content of this replication repository. Then run the following command to compute all results:

```
julia src/main.jl
```

The script is configured such that it automatically downloads and installs any required Julia packages.

## Result and figure files

All results and figures will be stored in the folder `output`.
