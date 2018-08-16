source("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figure_generation/graphs/functions.R")
library(latex2exp)


# Get data ----------------------------------------------------------------
d <- applyFunctionToResultsDirectories(readStemAttached,"/Users/millerc2/Documents/Chaste/Results/RotationalForce/3d/")
d <- rbindlist(d)

d_norot0 <- applyFunctionToResultsDirectories(readStemAttached,"/Users/millerc2/Documents/Chaste/Results/DifferentSpringLengths/3d/", pattern = "AdhesionMultiplier00")
d_norot1 <- applyFunctionToResultsDirectories(readStemAttached,"/Users/millerc2/Documents/Chaste/Results/DifferentSpringLengths/3d/", pattern = "AdhesionMultiplier01")
d_norot <- rbindlist(c(d_norot0,d_norot1))
d_norot$id <- paste(d_norot$id,"RotationalSpringConstant0000e-2",sep="_")
d_norot$RotationalSpringConstant <- 0.0

d <- rbind(d,d_norot)
rm(d_norot,d_norot0,d_norot1)

# Calculate the fit parameters --------------------------------------------
getFits <- function(d) {
  fits <- by(d, d$id, function(x) {
    fit <- with(x,findExpSurvFit(time,Freq,seed,id)[[1]])
    return(data.frame(fit,id=x$id[1]))
  } )
  fits <- rbindlist(fits)
  fits <- cbind(fits,extractParametersFromID(fits$id))
  return(fits)
}
fits <- getFits(d)


# Check the fits on a facet -----------------------------------------------
calculateFitLine <- function(rate,time)
{
  #time <- max(0:d$time)
  fit <- exp(-rate*time)
  return( data.frame(time,fit) )
}
fitted_data <- by(fits$fit,fits$id,calculateFitLine,time=0:max(d$time))
fitted_data <- rbindlist(fitted_data,idcol="id")
fitted_data <- cbind(fitted_data,extractParametersFromID(fitted_data$id))
ggplot() + 
  geom_point(aes(x=time,y=Freq/max(d$Freq),colour=factor(AdhesionMultiplier),group=interaction(seed,AdhesionMultiplier)),alpha=0.1,data=d) +
  geom_line(aes(x=time,y=fit,colour=factor(AdhesionMultiplier)), data=fitted_data) + 
  facet_grid(LogSpringLength~RotationalSpringConstant) +
  scale_y_continuous(limits=c(0,1.0))


# Plot rates --------------------------------------------------------------
fits$adhesion = fits$AdhesionMultiplier*500
fits$RotationalSpringConstant = fits$RotationalSpringConstant*10
labelling_fn <- function(string) 
  TeX(paste("$\\alpha^* = ", string, "\\; \\left[ \\mu N \\right] $")) 
p1 <- ggplot(fits) + 
  geom_point(aes(x=10^(-1.0*LogSpringLength),y=fit,colour=factor(RotationalSpringConstant)),size=5,pch=15) + 
  geom_line(aes(x=10^(-1.0*LogSpringLength),y=fit,colour=factor(RotationalSpringConstant)),size=2,linetype="dashed") + 
  facet_wrap(~adhesion, labeller = as_labeller(labelling_fn, default = label_parsed)) + #, scales="free_y") +
  scale_x_log10(labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  labs(x=TeX("$s_d$ \\[cell diameters\\]"),y=TeX("$\\lambda$ \\[per day\\]"),colour=TeX("$k_\\phi \\; \\left[ \\mu N \\right]"))
print(p1)

setwd("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figures/graphs/")
outputPaperPlot(p1,"loss_rate_rotational",pwidth=1400,legend.position=c(0.92,0.7))

# Now a zoomed version of the rotational force for adhesion multiplier = 1
full_plot_colours <- brewer.pal(length(unique(fits$RotationalSpringConstant)),brewer_palette)
p2 <- ggplot(filter(fits,AdhesionMultiplier==0 & RotationalSpringConstant > 0.0)) +
  geom_point(aes(x=10^(-1.0*LogSpringLength),y=fit,colour=factor(RotationalSpringConstant)),size=5,pch=15) + 
  geom_line(aes(x=10^(-1.0*LogSpringLength),y=fit,colour=factor(RotationalSpringConstant)),size=2,linetype="dashed") +
  scale_x_log10(labels = scales::trans_format("log10", scales::math_format(10^.x))) + scale_y_continuous(limits=c(0,0.015)) +
  labs(x=TeX("$s_d$ \\[cell diameters\\]"),y=TeX("$\\lambda$ \\[per day\\]"),colour=TeX("$k_\\phi \\; \\left[ \\mu N \\right]")) +
  scale_colour_manual(values=full_plot_colours[-1])
print(p2)

setwd("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figures/graphs/")
outputPaperPlot(p2,"loss_rate_rotational_zoom",manual_colour=T,legend.position=c(0.85,0.57))
