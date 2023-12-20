# ARCH2021 AFF

This is the JuliaReach repeatability evaluation (RE) package for the ARCH-COMP
2021 category report: Continuous and Hybrid Systems with Linear Continuous
Dynamics of the 5th International Competition on Verifying Continuous and Hybrid
Systems (ARCH-COMP '21).

To cite the work, you can use:

```
@inproceedings{AlthoffAFFFSSW21,
  author    = {Matthias Althoff and
               Erika {\'{A}}brah{\'{a}}m and
               Marcelo Forets and
               Goran Frehse and
               Daniel Freire and
               Christian Schilling and
               Stefan Schupp and
               Mark Wetzlinger},
  editor    = {Goran Frehse and
               Matthias Althoff},
  title     = {{ARCH-COMP21} Category Report: Continuous and Hybrid Systems with
               Linear Continuous Dynamics},
  booktitle = {{ARCH}},
  series    = {EPiC Series in Computing},
  volume    = {80},
  pages     = {1--31},
  publisher = {EasyChair},
  year      = {2021},
  url       = {https://doi.org/10.29007/lhbw},
  doi       = {10.29007/lhbw}
}
```

## Installation

*Note:* Running the full benchmark suite should take no more than one hour with
a reasonable internet connection (may take longer otherwise).

There are two ways to install and run this RE: either using the Julia script,
or using the included Dockerfile. In both cases, first clone this repository:

```shell
$ git clone https://github.com/JuliaReach/ARCH2021_AFF.git
$ cd ARCH2021_AFF
```

**Using the Julia script.** First install the Julia language in your system following
the instructions in the [Downloads page](http://julialang.org/downloads). Once
you have installed Julia installed in your system, do

```shell
$ julia startup.jl
```
to run all the benchmarks. After this command has finished, the results will be stored
under the folder `result/results.csv` and the generated plots in your working directory.

**Using the Docker container.** To build the container, you need the program `docker`.
For installation instructions on different platforms, consult
[the Docker documentation](https://docs.docker.com/install/).
For general information about `Docker`, see
[this guide](https://docs.docker.com/get-started/).
Once you have installed Docker, start the `measure_all` script:
script:

```shell
$ ./measure_all
```
The output results will be saved under the folder `result/`,
and the generated plots will be in your working directory.

---

The Docker container can also be run interactively.
To run it interactively, type:

```shell
$ docker run -it juliareach bash

$ julia

julia> include("startup.jl")
```

## About this RE

This repeatability evaluation package relies on Julia's package manager, `Pkg`, to create an environment that can be used to exactly use the same package versions in different machines. For further instructions on creating this RE, see [this wiki](https://github.com/JuliaReach/ARCH2020_NLN_RE/wiki/Instructions-for-creating-this-RE).
