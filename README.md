# Master Thesis - Exploração do método Surrogate em otimização estrutural de modelos CAD utilizando algoritmos bioinspirados

## Overview

This repository contains the source code, numerical models, and case studies developed during the Master's research on surrogate-assisted multiobjective optimization for computationally expensive structural optimization problems.

The proposed framework combines multiobjective evolutionary algorithms with Radial Basis Function (RBF) surrogate models and finite element simulations performed in ANSYS Workbench. The objective is to reduce the number of expensive function evaluations while maintaining the quality of the obtained Pareto-optimal solutions.

The repository includes implementations based on:

* MODE (Multiobjective Differential Evolution)
* MOPSO (Multiobjective Particle Swarm Optimization)
* MOEA/D (Multiobjective Evolutionary Algorithm based on Decomposition)

## Requirements

The framework was developed and tested using:

* MATLAB R2024b
* ANSYS Workbench 19.1
* Windows 10 / Windows 11

Additional MATLAB toolboxes may be required depending on the selected configuration.

## How the Framework Works

The optimization process follows the workflow below:

1. Generate an initial Design of Experiments (DOE).
2. Evaluate the initial solutions using ANSYS.
3. Build an RBF surrogate model.
4. Execute the selected multiobjective optimization algorithm using the surrogate model.
5. Periodically select promising solutions.
6. Evaluate the selected solutions using ANSYS.
7. Update the database and rebuild the surrogate model.
8. Repeat until the stopping criterion is reached.

This strategy significantly reduces the number of expensive finite element evaluations.

## Running an Optimization Experiment

### Step 1 – Open MATLAB

Open MATLAB and set the repository root folder as the current working directory.

### Step 2 – Configure ANSYS

Verify that:

* ANSYS Workbench 19.1 is installed.
* The project paths are correctly configured.
* ANSYS can be executed from MATLAB.

Update any local paths if necessary (run_experiment_0_3_config_only.m and run_experiment_2_3_config_only.m mainly).

### Step 3 – Select the Case Study

Choose the desired case study and ANSYS project.

Examples include:

* Coffee Table
* Placa

### Step 4 – Configure the Optimization Parameters

Edit the configuration structure before execution.

Typical parameters include:

```matlab
Config.Pop.Size
Config.Iter.Max
Config.Surrogate.Initial
Config.Surrogate.Limit
Config.Update.Curve
Config.Ansys.BatchNumber
```

### Step 5 – Run the Main Script

Execute the corresponding MATLAB script.

For example:

```matlab
run_compare_mode_mopso_moead_Placa.m
run_compare_mode_mopso_moead_Coffee.m
```

or the equivalent script associated with the selected experiment.

## Output Files

The framework may generate:

* Pareto fronts
* Hypervolume (HV)
* Inverted Generational Distance (IGD)
* Spacing metric
* Optimization history
* MATLAB workspace files
* ANSYS simulation outputs

Results are automatically stored in the configured results directory.

## Case Studies

### Coffee Table

A structural optimization problem involving:

* Minimization of structural mass
* Maximization of safety factor

### Placa

A structural optimization benchmark involving:

* Plate thickness
* Hole radius
* Hole position

The objective is to minimize structural mass while satisfying mechanical performance requirements.

## Research Context

This repository was developed as part of a Master's research project focused on surrogate-assisted multiobjective optimization for expensive engineering design problems.

The proposed methodology integrates:

* Space-filling sampling techniques
* Surrogate modeling based on RBF interpolation
* Adaptive surrogate updates
* Multiobjective evolutionary optimization
* Finite Element Analysis (FEA)

## Running an Optimization Experiment by Youself

This repository considers the repeatability of the problem under study, however if you wish to perform the most accurate analysis possible, from the creation of new seeds and backups, you must modify the run_experiment_0_3_config_only.m and run_experiment_2_3_config_only.m files in the areas Config.Surrogates.Seed.Flag = true; making it false, Config.Metaheuristic.Seed.Flag = true; making it false, and Config.Database.Overwrite = false; making it true.

## Citation

If this repository contributes to your research, please cite the associated Master's thesis and any related publications.

## License

This repository is provided for academic and research purposes.
