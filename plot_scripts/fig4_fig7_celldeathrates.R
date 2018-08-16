

# Required functions ------------------------------------------------------
source("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figure_generation/graphs/functions.R")
readdata <- function(filepath) {
  d <- readChasteResultsFile("celldeathcount.dat",filepath,columns=c("total","deaths"))
  d <- d[,c("time","deaths")]
  d$deaths[1] = NA
  d$seed <- strsplit(filepath,"Seed|/results")[[1]][2]
  d$time = (d$time-min(d$time))/24
  d$setup <- filepath
  return(d)
}



# Base Setup --------------------------------------------------------------
setwd("/Users/millerc2/Documents/Chaste/Results/DifferentSpringLengths/3d/LogSpringLength30e-1_AdhesionMultiplier01")

d <- applyFunctionToResultsDirectories(readdata)
d <- rbindlist(d)
d$title <- "Cell deaths"

mean_deaths <- as.data.frame(summarise(group_by(d,time),deaths=mean(deaths)))
mean_deaths$title <- "Cell deaths"

ggplot(d)+geom_line(aes(x=time,y=deaths,colour=seed))

# Get in the comparative data
setwd("/Users/millerc2/Documents/Chaste/Results/PinnedComparison/LiRepulsion/SpringLength01e-1_SpringParameter01/3d")
d_comparison <- applyFunctionToResultsDirectories(readdata)
d_comparison <- rbindlist(d_comparison)
mean_comparison <- as.data.frame(summarise(group_by(d_comparison,time),deaths=mean(deaths)))

p <- ggplot(d) + 
  geom_line(aes(x=time,y=deaths,group=seed, colour="Individual\nRealisations"), size=1, alpha=0.6) + 
  geom_line(aes(x=time,y=deaths,colour="Mean"),size=2,data=mean_deaths) +
  labs(x="Time [days]",y="Cell death rate\n[cells per day]", colour=NULL) +
  geom_line(aes(x=time,y=deaths,colour="Pinned SC mean"),size=2,data=mean_comparison) +
  scale_colour_manual(values=c(brewer_colours[2],"black",brewer_colours[1]))
print(p)

outputPaperPlot(p,"cell_deaths",manual_colour = T, pheight=700, legend.position=c(0.3,0.2))



# Rotational force results ------------------------------------------------
setwd('/Users/millerc2/Documents/Chaste/Results/RotationalForce/3d/')
setup = "LogSpringLength30e-1_AdhesionMultiplier10e-1"
d_rot <- applyFunctionToResultsDirectories(readdata,pattern=setup)
d_rot <- rbindlist(d_rot)
d_rot$title <- "Cell deaths"
d_rot$setup <- tstrsplit(d_rot$setup,".//|/Seed")[[2]]
d_rot <- cbind(d_rot,extractParametersFromID(d_rot$setup))
d_rot$RotationalSpringConstant = d_rot$RotationalSpringConstant*10
mean_deaths_rot <- as.data.frame(summarise(group_by(d_rot,time,LogSpringLength,AdhesionMultiplier,RotationalSpringConstant),deaths=mean(deaths)))
mean_deaths_rot$title <- "Cell deaths"

# Get in the comparative data
setwd("/Users/millerc2/Documents/Chaste/Results/PinnedComparison/ExponentialRepulsion/SpringLength01e-1")
d_comparison <- applyFunctionToResultsDirectories(readdata)
d_comparison <- rbindlist(d_comparison)
mean_comparison <- as.data.frame(summarise(group_by(d_comparison,time),deaths=mean(deaths)))
mean_comparison$title <- "Cell deaths"

p2 <- ggplot() +
  geom_line(aes(x=time,y=deaths,colour=factor(RotationalSpringConstant)),size=2,data=mean_deaths_rot) +
  geom_line(aes(x=time,y=deaths, linetype=""),size=2,colour="black",data=mean_comparison) +
  scale_linetype_manual(values=2) +
  labs(x="Time [days]",y="Cell death rate\n[cells per day]",colour=TeX("$k_\\phi \\; \\left[ \\mu N \\right]$"), linetype="Pinned")
print(p2)

setwd("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figures/graphs/")
outputPaperPlot(p2,"cell_deaths_rot",pheight=600,legend.position=c(0.75,0.7),legend.box="horizontal")



