

# Script functions --------------------------------------------------------
source("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figure_generation/graphs/functions.R")
readdata <- function(filepath) {
  d <- readChasteResultsFile("nodevelocities.dat",filepath,columns=c("id","x","y","z","vx","vy","vz"))
  celltypes <- readChasteResultsFile("results.vizcelltypes",filepath)
  i_diff <- which(celltypes$v != 0)
  d <- d[i_diff,]
  
  mean_vx <- as.data.frame(summarise(group_by(d,time),v=mean(vx)))
  mean_vy <- as.data.frame(summarise(group_by(d,time),v=mean(vy)))
  mean_vz <- as.data.frame(summarise(group_by(d,time),v=mean(vz)))
  
  mean_vx$direction <- "X"
  mean_vy$direction <- "Y"
  mean_vz$direction <- "Z"
  
  output <- rbind(mean_vx,mean_vy,mean_vz)
  output$time <- (output$time-min(output$time))/24
  output$v[output$time==0] = NA
  output$seed <- strsplit(filepath,"Seed|/results")[[1]][2]
  output$id <- filepath
  
  return(output)
}



# Li setup results --------------------------------------------------------
setwd("/Users/millerc2/Documents/Chaste/Results/LiSetup/3d/")
setwd("/Users/millerc2/Documents/Chaste/Results/DifferentSpringLengths/3d/LogSpringLength30e-1_AdhesionMultiplier01")

d <- applyFunctionToResultsDirectories(readdata)
d <- rbindlist(d)
mean_v <- as.data.frame(summarise(group_by(d,time,direction),v=mean(v)))

# Get in the comparative data
setwd("/Users/millerc2/Documents/Chaste/Results/PinnedComparison/ExponentialRepulsion/SpringLength30e-1/3d")
d_normal <- applyFunctionToResultsDirectories(readdata)
d_normal <- rbindlist(d_normal)
mean_normal <- as.data.frame(summarise(group_by(d_normal,time,direction),v=mean(v)))

p <- ggplot(d) + geom_line(aes(x=time,y=v,group=seed,colour="Individual\n realisations"), size=1) + 
  geom_line(aes(x=time,y=v,colour="Mean"),size=2,data=mean_v) +
  geom_line(aes(x=time,y=v,colour="Pinned SC\n mean"),size=2,data=mean_normal) +
  facet_wrap(~direction) + labs(x="Time [days]",y="Velocity\n[cell diameters per hour]",colour=NULL) +
  scale_colour_manual(values=c(brewer_colours[2],"black",brewer_colours[1])) 
print(p)

outputPaperPlot(p,"cell_velocities",pwidth=1400, pheight=700, manual_colour=T,legend.position=c(0.13,0.72))



# Rotational force results ------------------------------------------------
setwd('/Users/millerc2/Documents/Chaste/Results/RotationalForce/3d/')
setup = "LogSpringLength30e-1_AdhesionMultiplier10e-1"
d_rot <- applyFunctionToResultsDirectories(readdata,pattern=setup)
d_rot <- rbindlist(d_rot)
d_rot$id <- tstrsplit(d_rot$id,".//|/Seed")[[2]]
d_rot <- cbind(d_rot,extractParametersFromID(d_rot$id))
d_rot$RotationalSpringConstant = d_rot$RotationalSpringConstant*10
rot_mean_v <- as.data.frame(summarise(group_by(d_rot,time,direction,RotationalSpringConstant),v=mean(v)))

# Get in the comparative data
setwd("/Users/millerc2/Documents/Chaste/Results/PinnedComparison/ExponentialRepulsion/SpringLength01e-1")
d_normal <- applyFunctionToResultsDirectories(readdata)
d_normal <- rbindlist(d_normal)
mean_normal <- as.data.frame(summarise(group_by(d_normal,time,direction),v=mean(v)))

# Plot
p2 <- ggplot() + 
  geom_line(aes(x=time,y=v,colour=factor(RotationalSpringConstant)),size=2,data=rot_mean_v) + 
  geom_line(aes(x=time,y=v, linetype=""),colour="black",size=2,data=mean_normal) +
  facet_wrap(~direction) + 
  scale_linetype_manual(values=2) +
  labs(x="Time [days]",y="Velocity\n[cell diameters per hour]",colour=TeX("$k_\\phi \\; \\left[ \\mu N \\right]$"), linetype="Pinned") +
  guides(linetype=guide_legend(order=1),colour=guide_legend(order=2))
print(p2)

setwd("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figures/graphs/")
outputPaperPlot(p2,"cell_velocities_rot",pwidth=1400,legend.position=c(0.87,0.25),legend.box="horizontal",legend.box.just="bottom")



