
source("/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figure_generation/graphs/functions.R")

getDivisionHeights <- function(filepath) {
  d <- readCellData(filepath,"HeightAtDivision",dimensions=3)
  d <- dplyr::filter(d,HeightAtDivision<=1.0)
  d <- unique(d,by=id)
  return(d)
}

setwd("/Users/millerc2/Documents/Chaste/Results/DifferentSpringLengths/3d/")
# LogSpringLength10e-1

d <- applyFunctionToResultsDirectories(getDivisionHeights,pattern="AdhesionMultiplier01")
d <- rbindlist(d,idcol="folder")
tmp <- tstrsplit(d$folder,"Seed")
d$folder <- tmp[1]
d$seed <- tmp[2]
d <- cbind(d,extractParametersFromID(d$folder))
rownames(d) <- c()

labelling_fn <- function(string) { 
  TeX(paste("$s_d = 10^{-", string, "} $")) }
p <- ggplot(d) + 
  geom_histogram(aes(x=HeightAtDivision, fill=factor(LogSpringLength)), colour="white",binwidth = 0.1) + 
  facet_wrap(~LogSpringLength, labeller = as_labeller(labelling_fn, default = label_parsed)) +
  scale_y_continuous(labels=function(x) format(x/length(unique(d$seed)),scientific=T)) +
  guides(colour=F,fill=F) +
  labs(x="Height of differentiated daughter\n[cell diameters]", y="Cell count")
print(p)

outputPaperPlot(p,"heightatdivision",pwidth=1000,pheight=600)

