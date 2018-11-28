# Code for the cell death plots in Figures 4 (base setup) and 7 (rotational setup)

# Required functions ------------------------------------------------------
source("functions.R")
readdata <- function(filepath) {
  print(filepath)
  d <- readChasteResultsFile("celldeathcount.dat",filepath,columns=c("total","deaths"))
  d <- d[,c("time","deaths")]
  d$deaths[1:2] = NA
  d$seed <- strsplit(filepath,"Seed|/results")[[1]][2]
  d$time = (d$time-min(d$time))/24
  d$setup <- filepath
  return(d)
}



# Restrained data ---------------------------------------------------------
d_comparison <- applyFunctionToResultsDirectories(readdata,
                                                  maindir = paste0(results_directory,"/PinnedComparison/ExponentialRepulsion/SpringLength30e-1"))
d_comparison <- rbindlist(d_comparison)
mean_comparison <- as.data.frame(summarise(group_by(d_comparison,time),deaths=mean(deaths)))


# Base Setup ----------------------------------------------------------------
d <- applyFunctionToResultsDirectories(readdata,
        maindir = paste0(results_directory,"/DifferentSpringLengths/3d/LogSpringLength30e-1_AdhesionMultiplier01"))
d <- rbindlist(d)
d$title <- "Cell deaths"
mean_deaths <- as.data.frame(summarise(group_by(d,time),deaths=mean(deaths)))
mean_deaths$title <- "Cell deaths"

# Plot and output
p_base <- ggplot(d) + 
  geom_line(aes(x=time,y=deaths,group=seed, colour="Individual\n realisations"), size=1, alpha=0.6) + 
  geom_line(aes(x=time,y=deaths,colour="Mean"),size=2,data=mean_deaths) +
  labs(x="Time [days]",y="Cell death rate\n[cells per day]", colour=NULL) +
  geom_line(aes(x=time,y=deaths,colour="Restrained SC"),size=2,data=mean_comparison) +
  scale_colour_manual(values=c(brewer_colours[2],"black",brewer_colours[1]))
#print(p_base)
p_out1 <- outputPaperPlot(p_base,"cell_deaths_base",manual_colour = T, pheight=600, pwidth=1000, legend.position=c(0.18,0.23))


# Rotational force results ------------------------------------------------
setup = "LogSpringLength30e-1_AdhesionMultiplier10e-1"
d_rot <- applyFunctionToResultsDirectories(readdata,pattern=setup,
              maindir = paste0(results_directory,'/RotationalForce/3d'))
d_rot <- rbindlist(d_rot)
d_rot$title <- "Cell deaths"
d_rot$setup <- tstrsplit(d_rot$setup,"3d/|/Seed")[[2]]
d_rot <- cbind(d_rot,extractParametersFromID(d_rot$setup))
d_rot$RotationalSpringConstant = d_rot$RotationalSpringConstant*10
mean_deaths_rot <- as.data.frame(summarise(group_by(d_rot,time,LogSpringLength,AdhesionMultiplier,RotationalSpringConstant),deaths=mean(deaths)))
mean_deaths_rot$title <- "Cell deaths"

# Plot and output
p_rot <- ggplot() +
  geom_line(aes(x=time,y=deaths,colour=factor(RotationalSpringConstant)),size=2,data=mean_deaths_rot) +
  geom_line(aes(x=time,y=deaths, linetype=""),size=2,colour="black",data=mean_comparison) +
  scale_linetype_manual(values=2) +
  ylim(100,170) +
  labs(x="Time [days]",y="Cell death rate\n[cells per day]",colour=TeX("$k_\\phi \\; \\left[ \\mu N \\right]$")) +
  guides(linetype=F) +
  scale_colour_manual(values=brewer_colours[-1]) 
#print(p_rot)
p_out2 <- outputPaperPlot(p_rot,"cell_deaths_rotational",manual_colour=T,pheight=600,legend.position=c(0.13,0.3))



