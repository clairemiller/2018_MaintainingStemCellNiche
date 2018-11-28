# Code to generate the remaining population plot in Figure 7 for the rotational setups


# Functions ---------------------------------------------------------------
source("functions.R")
labelling_fn <- function(string) {
  TeX(paste("$\\alpha^* = ", string, "\\; \\left[ \\mu N \\right] $")) 
}

# Get data ----------------------------------------------------------------
d <- applyFunctionToResultsDirectories(readStemAttached,
          maindir = paste0(results_directory,"RotationalForce/3d") )
d <- rbindlist(d)
  
d_norot0 <- applyFunctionToResultsDirectories(readStemAttached, pattern = "AdhesionMultiplier00",
                maindir = paste0(results_directory,"DifferentSpringLengths/3d/"))
d_norot1 <- applyFunctionToResultsDirectories(readStemAttached, pattern = "AdhesionMultiplier01",
                maindir = paste0(results_directory,"DifferentSpringLengths/3d/"))
d_norot <- rbindlist(c(d_norot0,d_norot1))
d_norot$id <- paste(d_norot$id,"RotationalSpringConstant0000e-2",sep="_")
d_norot$RotationalSpringConstant <- 0.0
  
d <- rbind(d,d_norot)

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


# Plot the fits on a facet ----------------------------------------------
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
labelling_fn_fits <- function(input) {
  vals <- as.numeric(input)
  if (max(vals)>10) {
    vals <- vals*10
    labels <- TeX(paste("$k_{\\phi} = ",vals, " \\;  \\[ \\mu N \\] $",sep=""))
    return(labels)
  }
  else {
    labels <- TeX(paste("$s_d = 10^{-", vals, "}$",sep=""))
    return(labels)
  }
}
p_check <- ggplot() + 
  geom_line(aes(x=time,y=Freq/max(d$Freq),colour=factor(AdhesionMultiplier*500),group=interaction(seed,AdhesionMultiplier)),alpha=0.1,data=d) +
  geom_line(aes(x=time,y=fit,colour=factor(AdhesionMultiplier*500)), data=fitted_data) + 
  facet_grid(LogSpringLength~RotationalSpringConstant, labeller = as_labeller(labelling_fn_fits, default = label_parsed)) +
  scale_y_continuous(limits=c(0,1.0)) +
  labs(x="Time [days]", y="Proportion SC remaining", colour=TeX("$\\alpha^* \\[ \\mu N \\] $") )
p_out <- outputPaperPlot(p_check,"fits_rotational",pwidth=2000,pheight=1700,legend.position=c(0.95,0.07))

# Output the fits
print(fits)

# Plot rates --------------------------------------------------------------
fits$adhesion = fits$AdhesionMultiplier*500
fits$RotationalSpringConstant = fits$RotationalSpringConstant*10
max_y = max(fits$lambda[fits$lambda!=max(fits$lambda)])
p_rates <- ggplot(fits) + 
  geom_point(aes(x=10^(-1.0*LogSpringLength),y=lambda,colour=factor(RotationalSpringConstant)),size=5,pch=15) + 
  geom_line(aes(x=10^(-1.0*LogSpringLength),y=lambda,colour=factor(RotationalSpringConstant)),size=2,linetype="dashed") + 
  facet_wrap(~adhesion, labeller = as_labeller(labelling_fn, default = label_parsed)) + #, scales="free_y") +
  scale_x_log10(labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  ylim(0,0.5) +
  labs(x=TeX("$s_d$ \\[CD\\]"),y=TeX("$\\lambda$ \\[per day\\]"),colour=TeX("$k_{\\phi} \\; \\left[ \\mu N \\right]"))
#print(p_rates)
#p_out <- outputPaperPlot(p_rates,"loss_rate_rotational",pwidth=1400,legend.position=c(0.92,0.7))


# Plot remaining population -----------------------------------------------
p_beta <- ggplot(fits) +
  geom_point(aes(x=10^(-1.0*LogSpringLength),y=alpha,colour=factor(RotationalSpringConstant)),size=5,pch=15) +
  geom_line(aes(x=10^(-1.0*LogSpringLength),y=alpha,colour=factor(RotationalSpringConstant)),size=2,linetype="dashed") +
  facet_wrap(~adhesion, labeller = as_labeller(labelling_fn, default = label_parsed)) +
  scale_x_log10(labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  ylim(0,1.0) +
  labs(x=TeX("$s_d$ \\[CD\\]"),y=TeX("$\\beta$"),colour=TeX("$k_{\\phi} \\; \\left[ \\mu N \\right]"))
#print(p_beta)
p_out <- outputPaperPlot(p_beta,"remaining_rotational",pheight=600,pwidth=1000)

