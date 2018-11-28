# Code for the cell velocity plots in Figures 4 (base setup) and 7 (rotational setup)

# Script functions --------------------------------------------------------
source("functions.R")
readdata <- function(filepath) {
  print(filepath)
  d <- readChasteResultsFile("nodevelocities.dat",filepath,columns=c("id","x","y","z","vx","vy","vz"))
  celltypes <- readChasteResultsFile("results.vizcelltypes",filepath)
  i_diff <- which(celltypes$v != 0)
  d <- d[i_diff,]
  d <- filter(d,z>3)  
  
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


# Restrained results ------------------------------------------------------
d_normal <- applyFunctionToResultsDirectories(readdata,
                maindir = paste0(results_directory,"PinnedComparison/ExponentialRepulsion/SpringLength30e-1"))
d_normal <- rbindlist(d_normal)
mean_normal <- as.data.frame(summarise(group_by(d_normal,time,direction),v=mean(v)))


# Base setup results --------------------------------------------------------
d <- applyFunctionToResultsDirectories(readdata,
        maindir = paste0(results_directory,"/DifferentSpringLengths/3d/LogSpringLength30e-1_AdhesionMultiplier01/"))
d <- rbindlist(d)
mean_v <- as.data.frame(summarise(group_by(d,time,direction),v=mean(v)))

# Plot and output
p_base <- ggplot(d) + geom_line(aes(x=time,y=v*10^4,group=seed,colour="Individual\n realisations"), size=1) + 
  geom_line(aes(x=time,y=v*10^4,colour="Mean"),size=2,data=mean_v) +
  geom_line(aes(x=time,y=v*10^4,colour="Restrained SC"),size=2,data=mean_normal) +
  facet_wrap(~direction) + labs(x="Time [days]",y=TeX("Velocity $\\left[ \\times 10^{-4} \\; CD . h^{-1} \\right]$"),colour=NULL) +
  scale_colour_manual(values=c(brewer_colours[2],"black",brewer_colours[1])) 
#print(p_base)
p_out <- outputPaperPlot(p_base,"cell_velocities_base",pwidth=1400, pheight=700, manual_colour=T,legend.position=c(0.13,0.75))
rm(d)


# Rotational force results ------------------------------------------------
setup = "LogSpringLength30e-1_AdhesionMultiplier10e-1"
d_rot <- applyFunctionToResultsDirectories(readdata,pattern=setup,
                maindir = paste0(results_directory,"RotationalForce/3d") )
d_rot <- rbindlist(d_rot)
d_rot$id <- tstrsplit(d_rot$id,"3d/|/Seed")[[2]]
d_rot <- cbind(d_rot,extractParametersFromID(d_rot$id))
d_rot$RotationalSpringConstant <- d_rot$RotationalSpringConstant*10
rot_mean_v <- as.data.frame(summarise(group_by(d_rot,time,direction,RotationalSpringConstant),v=mean(v)))

# Plot and output
p_rot <- ggplot() + 
  geom_line(aes(x=time,y=v*10^4,colour=factor(RotationalSpringConstant)),size=2,data=rot_mean_v) + 
  geom_line(aes(x=time,y=v*10^4, linetype=""),colour="black",size=2,data=mean_normal) +
  facet_wrap(~direction) + 
  scale_linetype_manual(values=2) +
  labs(x="Time [days]",y=TeX("Velocity $\\left[ \\times 10^{-4} \\; CD . h^{-1} \\right]$"),colour=TeX("$k_\\phi \\; \\left[ \\mu N \\right]$")) +
  guides(linetype=F) +
  scale_colour_manual(values=brewer_colours[-1]) 
#print(p_rot)
p_out <- outputPaperPlot(p_rot,"cell_velocities_rotational",pwidth=1400,manual_colour=T,legend.position=c(0.91,0.27))



