source("functions.R")

# Read in the stem cell count data
d <- applyFunctionToResultsDirectories(readStemAttached, 
        maindir = paste0(results_directory,"/DifferentSpringLengths/3d/LogSpringLength30e-1_AdhesionMultiplier01"))
d <- rbindlist(d)
d$proportion <- d$Freq/max(d$Freq)

# Calculate the means
mean_count <- as.data.frame(summarise(group_by(d,time),freq=mean(Freq)))
mean_count$proportion <- mean_count$freq/max(mean_count$freq)

# Plot and output
p <- ggplot(d) + 
  geom_line(aes(x=time,y=proportion,group=seed, colour="Individual\nrealisations"), alpha=0.6, size=1) +
  geom_line(aes(x=time,y=proportion,colour="Mean"),size=2,data=mean_count) +
  labs(x="Time [days]",y="Proportion SC remaining",colour=NULL) +
  scale_colour_manual(values=c(brewer_colours[2],"black")) +
  scale_y_continuous(limits=c(0,1.0))
# print(p)

p_out <- outputPaperPlot(p,"basesetup_cellloss",manual_colour=T,pheight=700,legend.position=c(0.75,0.8))


