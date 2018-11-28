# Code to calculate the fits and generate remaining population plot in Figure 5

source("functions.R")

# Get data ----------------------------------------------------------------
d <- applyFunctionToResultsDirectories(readStemAttached, 
            maindir = paste0(results_directory,"DifferentSpringLengths/3d") )
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
print(dplyr::filter(fits,LogSpringLength==3))


# Calculate the fit curves -----------------------------------------------
calculateFitLine <- function(fit_i,time)
{
  fit <- (1-fit_i$alpha)*exp(-fit_i$lambda*time) + fit_i$alpha
  return( data.frame(time,fit) )
}
fitted_data <- by(fits,fits$id,calculateFitLine,time=0:max(d$time))
fitted_data <- rbindlist(fitted_data,idcol="id")
fitted_data <- cbind(fitted_data,extractParametersFromID(fitted_data$id))


# Plot rates --------------------------------------------------------------
p_lambda <- ggplot(fits) + 
  geom_point(aes(x=10^(-1.0*LogSpringLength),y=lambda,colour=factor(AdhesionMultiplier)),size=5,pch=15) + 
  geom_line(aes(x=10^(-1.0*LogSpringLength),y=lambda,colour=factor(AdhesionMultiplier)),size=2,linetype="dashed") + 
  scale_x_log10(labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  labs(x=TeX("$s_d$ \\[CD\\]"),y=TeX("$\\lambda$ \\[per day\\]"),colour=TeX("$\\frac{\\alpha^*}{500}\\;\\left[\\mu N\\right]$"))
#print(p_lambda)
#p_out <- outputPaperPlot(p_lambda,"loss_rate_base",pheight=600,pwidth=1000)


# Plot remaining population -----------------------------------------------
p_beta <- ggplot(fits) +
  geom_point(aes(x=10^(-1.0*LogSpringLength),y=alpha,colour=factor(AdhesionMultiplier)),size=5,pch=15) +
  geom_line(aes(x=10^(-1.0*LogSpringLength),y=alpha,colour=factor(AdhesionMultiplier)),size=2,linetype="dashed") +
  scale_x_log10(labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  ylim(0,1.0) +
  labs(x=TeX("$s_d$ \\[CD\\]"),y=TeX("$\\beta$"),colour=TeX("$\\frac{\\alpha^*}{500}\\;\\left[\\mu N\\right]$"))
#print(p_beta)
p_out <- outputPaperPlot(p_beta,"remaining_base",pheight=600,pwidth=1000)


# Plot representative examples --------------------------------------------
spring_length = 3
d_subset <- subset(d,LogSpringLength==spring_length)
fitted_data_subset <- subset(fitted_data,LogSpringLength==spring_length)
p_eg <- ggplot() +
  geom_line(aes(x=time,y=Freq/100,colour=factor(AdhesionMultiplier),group=interaction(seed,AdhesionMultiplier)),alpha=0.1,size=1,data=d_subset) +
  geom_line(aes(x=time,y=fit,colour=factor(AdhesionMultiplier)),size=2,data=fitted_data_subset) +
  annotate("text", x=4,y=0.05,label=(TeX("$s_d=10^{-3}$")), size=15 ) +
  labs(x="Time [days]",y="Proportion SC\nremaining", colour=TeX("$\\frac{\\alpha^*}{500}\\;\\left[\\mu N\\right]$"))
#print(p_eg)
p_out <- outputPaperPlot(p_eg,"rep_examples_loss",pheight=600,pwidth=1000,plot.title = element_text(hjust = 0.5))
