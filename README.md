# GeneDrive.jl

Code and data for initial paper submission.

Authors: Váleri N. Vásquez<sup>1,2</sup>, David Anthoff<sup>1</sup>

Affiliations: 
1. Energy and Resources Group, Rausser College of Natural Resources, University of California Berkeley, CA, USA
2. Department of Electrical Engineering and Computer Sciences, College of Engineering, University of California Berkeley, CA, USA

## Hardware and software requirements

To run the replication code, install [Julia](http://julialang.org/) in such a way that the Julia binary is on the `PATH`. 

This code was tested on Julia version 1.8.5.

## Linear Solver

HSL is the linear solver used in this work. Obtain a license and download `HSL_jll.jl` from https://licences.stfc.ac.uk/product/julia-hsl. Get the openblas version.

After downloading HSL_jll, extract the content into the subfolder `packages` of this repository. You should then have a folder named `HSL_jll.jl-2023.5.26` in the `packages` folder. As a final step, you should rename that folder to `HSL_jll`.

## Running the replication script

To recreate the outputs for this paper, open an OS shell. Change into the folder where you downloaded the content of this replication repository, then run the following command to compute results:

```
julia src/main.jl
```

The script is configured such that it automatically downloads and installs any required Julia packages.

## Result files

Results will be stored in the folder `output`.
