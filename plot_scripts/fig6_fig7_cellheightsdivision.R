# Code to generate the histogram of cell heights in Figures 6 (base) and 7 (rotational)

# Functions ---------------------------------------------------------------
source("functions.R")
getDivisionHeights <- function(filepath) {
  print(filepath)
  d <- readCellData(filepath,"HeightAtDivision",dimensions=3)
  d <- unique(d,by='id')
  d <- dplyr::filter(d,HeightAtDivision<=1.0)
  d <- d[,c("time","HeightAtDivision")]
  d$time <- as.numeric(d$time)/24
  d <- dplyr::filter(d,time<750)
  return(d)
}
labelling_fn <- function(string) { 
  TeX(paste("$s_d = 10^{-", string, "} $")) }


# Base Setup --------------------------------------------------------------
setups_used = "LogSpringLength10e-1_AdhesionMultiplier01|LogSpringLength30e-1_AdhesionMultiplier01"
d <- applyFunctionToResultsDirectories(getDivisionHeights,pattern=setups_used,
          maindir = paste0(results_directory,"DifferentSpringLengths/3d"))
d <- rbindlist(d,idcol="folder")
tmp <- tstrsplit(d$folder,"Seed")
d$folder <- tmp[1]
d$seed <- tmp[2]
d <- cbind(d,extractParametersFromID(d$folder))
rownames(d) <- c()
p <- ggplot(d) + 
  geom_histogram(aes(x=HeightAtDivision, fill=factor(LogSpringLength)), colour="white",binwidth = 0.1) + 
  facet_wrap(~LogSpringLength, labeller = as_labeller(labelling_fn, default = label_parsed)) +
  scale_y_continuous(labels=function(x) {x/(length(unique(d$seed))*10^3)}) +
  guides(colour=F,fill=F) +
  scale_fill_brewer(palette=brewer_palette) +
  labs(x=TeX("Height of differentiated daughter $\\[CD \\]$"), y=TeX("Cell count $\\left[ \\times 10^{3} \\right]$"))
p_out <- outputPaperPlot(p,"heightatdivision_base",pwidth=1000,pheight=650)


# Rotational Setup --------------------------------------------------------
setups_used="LogSpringLength10e-1_AdhesionMultiplier10e-1_RotationalSpringConstant01|LogSpringLength30e-1_AdhesionMultiplier10e-1_RotationalSpringConstant01"
d_rot <- applyFunctionToResultsDirectories(getDivisionHeights,pattern=setups_used,
              maindir = paste0(results_directory,"RotationalForce/3d"))
d_rot <- rbindlist(d_rot,idcol="folder")
tmp <- tstrsplit(d_rot$folder,"Seed")
d_rot$folder <- tmp[1]
d_rot$seed <- tmp[2]
d_rot <- cbind(d_rot,extractParametersFromID(d_rot$folder))

# Plot
p2 <- ggplot(d_rot) +
  geom_histogram(aes(x=HeightAtDivision, fill=factor(LogSpringLength)), colour="white",binwidth = 0.1) +
  facet_wrap(~LogSpringLength, labeller = as_labeller(labelling_fn, default = label_parsed)) +
  scale_y_continuous(labels=function(x) {x/(length(unique(d_rot$seed))*10^3)}) +
  guides(colour=F,fill=F) +
  scale_fill_brewer(palette=brewer_palette) + 
  labs(x=TeX("Height of differentiated daughter $\\[CD \\]$"), y=TeX("Cell count $\\left[ \\times 10^{3} \\right]$"))
p_out <- outputPaperPlot(p2,"heightatdivision_rotational",pwidth=1000,pheight=600)
