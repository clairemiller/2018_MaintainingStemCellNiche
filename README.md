# Miller, C., Crampin, E., Osborne, J. (2021). Maintaining the stem cell niche in multicellular models of epithelia.

This project provides all code required, additional to Chaste core code, to reproduce the results and plots shown in the above paper. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine.

### Prerequisites

* Chaste core code and all dependencies. See installing section below.
* R to run plot scripts. Also require the following R packages:
    * GitHub packages, install using `library(devtools)` then `install_github("[repo]")`
      * exponentialsurvival to calculate decay fits, repo: [MikeLydeamore/exponentialsurvival](https://github.com/MikeLydeamore/exponentialsurvival.git).
      * chasteR to read in Chaste output files, repo: [clairemiller/chasteR](https://github.com/clairemiller/chasteR)
    * CRAN packages, install using `install.packages("[package name]")`
      * ggplot2
      * dplyr
      * latex2exp
      * RColorBrewer

### Installing

This code uses a modified version of the core Chaste code. This modified version can be cloned from my [Chaste Repository](https://github.com/clairemiller/Chaste.git). Either follow the link or clone into a folder using the following command
```
git clone https://github.com/clairemiller/Chaste.git [folder]
```

Navigate to the `projects` folder and clone this project into a new folder.
```
git clone https://github.com/clairemiller/2019_MaintainingStemCellNicheEpithelia.git 2019_MaintainingStemCellNicheEpithelia
```

Instructions on installing dependencies and running Chaste code can be found at the [Chaste wiki](https://chaste.cs.ox.ac.uk/trac/wiki). 


## Running the simulations

The code for each set of simulations can be found in the `test` folder in the project directory. The fill simulation must be run before any other simulation. This is file `TestFillTissue.hpp`. As with all of the code in this project, the fill simulation takes a seed as input. So in order to run the test, it must first be compiled, then executed with the seed value as input. I.e. from the main Chaste directory run the following commands:
```
scons b=GccOpt co=1 projects/2019_MaintainingStemCellNicheEpithelia/test/TestFillTissue.hpp
./projects/build/optimised/TestFillTissueRunner -seed [seed]
```

## Running the plot code

All the plot code can be found in the project directory in the folder `plot_scripts`. All plotting code is in R. The user will have to change the necessary file paths for the results plot outputs in the scripts.

## Authors

* **Claire Miller** - *Main developer* - The University of Melbourne
* **James Osborne** - *Supervisor and code advice* - The University of Melbourne
* **Edmund Crampin** - *Supervisor* - The University of Melbourne

## License

This project is open source. 

## Acknowledgments

* Fitting code uses package 'exponentialsurvival' by Michael Lydeamore, accessible at https://github.com/MikeLydeamore/exponentialsurvival.git

