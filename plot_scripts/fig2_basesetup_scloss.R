source("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figure_generation/graphs/functions.R")

setwd("/Users/millerc2/Documents/Chaste/Results/DifferentSpringLengths/3d/LogSpringLength30e-1_AdhesionMultiplier01")

dataread <- function(filepath){
  type <- readChasteResultsFile("results.vizcelltypes",filepath)
  mut <- readChasteResultsFile("results.vizmutationstates",filepath)
  i_sc_att <- which(type$v==0 & mut$v==4)
  time <- as.factor(type$time)[i_sc_att]
  counts <- table(time)
  counts <- as.data.frame(counts)
  counts$seed <- strsplit(filepath,"Seed|/results")[[1]][2]
  return(counts)
}

d1 <- applyFunctionToResultsDirectories(dataread)
d1 <- rbindlist(d1)
d1$time <- as.numeric(levels(d1$time))[d1$time]
d1$time <- (d1$time-min(d1$time))/24
d1$proportion <- d1$Freq/max(d1$Freq)

mean_count1 <- as.data.frame(summarise(group_by(d1,time),freq=mean(Freq)))
mean_count1$proportion <- mean_count1$freq/max(mean_count1$freq)

p1 <- ggplot(d1) + 
  geom_line(aes(x=time,y=proportion,group=seed, colour="Individual\nrealisations"), alpha=0.6, size=1) +
  geom_line(aes(x=time,y=proportion,colour="Mean"),size=2,data=mean_count1) +
  labs(x="Time [days]",y="Proportion SC remaining",colour=NULL) +
  scale_colour_manual(values=c(brewer_colours[2],"black")) +
  scale_y_continuous(limits=c(0,1.0))
print(p1)
outputPaperPlot(p1,"basesetup_cellloss",manual_colour=T,pheight=700,legend.position=c(0.75,0.8))


