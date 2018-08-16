library(claires)
library(latex2exp)
source("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figure_generation/graphs/functions.R")

# Adhesion
da <- data.frame(s = seq(0.0,1.2,0.01))
da$f = -1.0*calculatePalssonAdhesionForce(da$s,alpha=1.0)
da$t = "Adhesion"

# Exponential repulsion
dr <- data.frame(s = seq(-0.25,0.0,0.01))
dr$f <- log(1+dr$s)
dr$t <- "Repulsion"

# Combine
d <- rbind(da,dr)


p <- ggplot(d) + 
  geom_line(aes(x=s,y=f,colour=t),size=2) + 
  coord_cartesian(ylim=c(-0.03,0.03)) +
  labs(x=TeX("$s_{ij}$ [cell units]"),y=TeX("$F_{ij}$ normalised"), colour="Force" )
print(p)

pa <- ggplot(da) + geom_line(aes(x=s,y=f)) + labs(x=TeX("$s_{ij}$ [cell units]"),y=TeX("$\\frac{ F_{ij} }{ \\alpha }$")) +
  coord_cartesian(xlim=c(0.0,1.2),ylim=c(0.0,0.03),expand=F) 

pr <- ggplot(dr) + geom_line(aes(x=s,y=f)) + labs(x=TeX("$s$ (cell units)"),y=TeX("$\\frac{ F_{ij} }{ k }$")) +
  coord_cartesian(xlim=c(-0.5,0.0),ylim=c(-0.7,0.0),expand=F) 

setwd("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figures/graphs")
outputPaperPlot(p,"force",pheight=600,legend.position=c(0.8,0.8))
outputPaperPlot(pa,"adhesion",pheight=600)
# outputPaperPlot(pr,"repulsion",pwidth=400,pheight=600,axis.title.y=element_text(angle=0,vjust=0.5),plot.margin=unit(c(5,5,0,0),"mm"))
