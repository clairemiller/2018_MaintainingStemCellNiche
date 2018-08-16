source("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figure_generation/graphs/functions.R")
library(latex2exp)


# Get data ----------------------------------------------------------------
d <- applyFunctionToResultsDirectories(readStemAttached,"/Users/millerc2/Documents/Chaste/Results/DifferentSpringLengths/3d/")
d <- rbindlist(d)


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
calculateFitLine <- function(fit_i,time)
{
  #time <- max(0:d$time)
  fit <- (1-fit_i$alpha)*exp(-fit_i$lambda*time) + fit_i$alpha
  # fit <- exp(-fit_i$fit*time)
  return( data.frame(time,fit) )
}
fitted_data <- by(fits,fits$id,calculateFitLine,time=0:max(d$time))
fitted_data <- rbindlist(fitted_data,idcol="id")
fitted_data <- cbind(fitted_data,extractParametersFromID(fitted_data$id))
ggplot() +
  geom_point(aes(x=time,y=Freq/max(d$Freq),colour=seed),data=d) +
  geom_line(aes(x=time,y=fit), data=fitted_data) +
  facet_grid(LogSpringLength~AdhesionMultiplier) + guides(colour=F) +
  scale_y_continuous(limits=c(0,1.0))


# Plot rates --------------------------------------------------------------
p1 <- ggplot(fits) + 
  geom_point(aes(x=10^(-1.0*LogSpringLength),y=lambda,colour=factor(AdhesionMultiplier)),size=5,pch=15) + 
  geom_line(aes(x=10^(-1.0*LogSpringLength),y=lambda,colour=factor(AdhesionMultiplier)),size=2,linetype="dashed") + 
  scale_x_log10(labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  labs(x=TeX("$s_d$ \\[cell diameters\\]"),y=TeX("$\\lambda$ \\[per day\\]"),colour=TeX("$\\frac{\\alpha^*}{500}\\;\\left[\\mu N\\right]$"))
print(p1)

setwd('/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figures/graphs/')
outputPaperPlot(p1,"loss_rate_base",pheight=600,pwidth=1000)



# Plot representative examples --------------------------------------------
spring_length = 3

d_subset <- subset(d,LogSpringLength==spring_length)
fitted_data_subset <- subset(fitted_data,LogSpringLength==spring_length)
p2 <- ggplot() +
  geom_line(aes(x=time,y=Freq/100,colour=factor(AdhesionMultiplier),group=interaction(seed,AdhesionMultiplier)),alpha=0.4,size=1,data=d_subset) +
  geom_line(aes(x=time,y=fit,colour=factor(AdhesionMultiplier)),size=2,data=fitted_data_subset) +
  annotate("text", x=4,y=0.05,label=(TeX("$s_d=10^{-3}$")), size=15 ) +
  labs(x="Time [days]",y="Proportion SC\nremaining", colour=TeX("$\\frac{\\alpha^*}{500}\\;\\left[\\mu N\\right]$"))
print(p2)

setwd('/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figures/graphs/')
outputPaperPlot(p2,"rep_examples_loss",pheight=600,pwidth=1000,plot.title = element_text(hjust = 0.5))
