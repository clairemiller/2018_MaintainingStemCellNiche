library(claires)
library(plyr)
library(dplyr)
library(survival)
library(exponentialsurvival)
library(latex2exp)
library(RColorBrewer)


blue_hex <- "#29ACFF"
red_hex <- "#F90201"
brewer_palette <- "Set1"
brewer_colours <- brewer.pal(8,brewer_palette)

extractParametersFromID <- function(id)
{
  tmp <- tstrsplit(id,"_")
  parameter_names <- sapply(tmp,"[",1)
  parameter_names <- gsub("([0-9]+).*","",parameter_names)
  tmp <- lapply(seq_along(tmp),function(i) {
          as.data.frame(as.numeric(gsub(parameter_names[i],"",tmp[[i]])))
  })
  tmp <- do.call(cbind,tmp)
  colnames(tmp) <- parameter_names
  return(tmp)
}

findExpSurvFit <- function(time,count,seed,id)
{
  # Setup data for the expsurv.fit function
  setupData <- function(data) {
    time <- data$time
    count <- data$count
    if (length(time)<2) {
      stop("findExpSurvFit Error 1: Incomplete data.")
    } else if (min(count)==max(count)) {
      # No stem cell loss
      input <- data.frame(time=rep(max(time),length(time)),status=0)
      return(input)
    } else if (length(time)!=length(count)) {
      stop("findExpSurvFit Error 2: Time and count vectors need to be of equal length.")
    }

    # Re-configure data
    # Ensure day ordering
    i <- order(time)
    d_ss <- data.frame(t=time[i],count=count[i])
    tmp <- with(d_ss,data.frame(SC_Lost=-1*diff(count),time=time[-1]))
    tmp <- tmp[tmp$SC_Lost!=0,]
    i_gained = which(tmp$SC_Lost < 0)
    while (length(i_gained) > 0) {
      for (i in i_gained)
      {
        i_lost <- which(tmp$SC_Lost[1:i]>0)
        i_lost <- i_lost[length(i_lost)]
        tmp$SC_Lost[i_lost] = tmp$SC_Lost[i_lost]+tmp$SC_Lost[i]
      }
      tmp = tmp[-i_gained,]
      tmp <- subset(tmp,SC_Lost!=0)
      i_gained = which(tmp$SC_Lost < 0)
    }
    tmp <- rep(tmp$time,tmp$SC_Lost)
    if ( length(tmp)==0 )
    {
      # No stem cell loss
      input <- data.frame(time=rep(max(time),length(time)),status=0)
      return(input)
    }
    input <- data.frame(time=tmp,status=1)

    # Add in cells remaining
    n_rem <- count[length(count)]
    if (n_rem > 0) 
    {
      input <- rbind(input,data.frame(time=rep(max(time),n_rem),status=0))
    }
    return(input)
  }
  
  input <- by(data.frame(time,count),seed,setupData)
  input <- rbindlist(input)
  
  if (nrow(input)==0)
  {
    rate = 0
  } else {
    # Exponential - no surviving population
    # sf <- survreg(Surv(time, status)~1, dist="exponential", data = input)
    # rate <- as.numeric(exp(-sf$coefficients))
    # Exponential - with surviving population
    rate <- expsurv.fit(as.matrix(input))
  }
  return(list(rate,as.matrix(input)))
}

outputPaperPlot <- function(p,filepath,pwidth=800,pheight=800,manual_colour=F,...)
{
  setwd('/Users/millerc2/Documents/Research_Docs/JournalPapers/ModellingCellDivision/figures/graphs/')
  # Change the theme
  p <- p + theme_classic()
  p <- p + theme(
                 panel.background = element_rect(colour = "black",fill=NA),
                 legend.key.size = unit(30,"pt"),
                 legend.text=element_text(size=rel(3), margin = margin(t=10, r=0, b = 10, l=0), hjust=0),
                 #legend.title = element_text(face="bold"),
                 legend.margin=margin(t=10,l=10,r=10,b=10),
                 legend.background = element_rect(colour="black",fill=NA),
                 plot.margin = unit(c(30,30,10,10),"pt"),
                 title=element_text(size=rel(3)),
                 axis.text=element_text(size=rel(3)),
                 strip.text=element_text(size=rel(4)),
                 strip.background = element_rect(colour=NA),
                 panel.spacing = unit(30,"pt"),
                 axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0),size=rel(1.5)),
                 axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0),size=rel(1.5)),
                 ...)
  if (!manual_colour)
  {
    p <- p + scale_color_brewer(palette=brewer_palette)
  }
  png(paste(filepath,"png",sep="."),width=pwidth,height=pheight)
  tryCatch(
    {
      print(p)
      dev.off()
    },
    error=function(e) {
      dev.off()
      #print(e)
    }
  )
  return(p)
}



# Collect and pre-process cell data to get the counts of attached----------
readStemAttached <- function(filepath){
  type <- readChasteResultsFile("results.vizcelltypes",filepath)
  mut <- readChasteResultsFile("results.vizmutationstates",filepath)
  i_sc_att <- which(type$v==0 & mut$v==4)
  time <- as.factor(type$time)[i_sc_att]
  counts <- table(time)
  counts <- as.data.frame(counts)
  counts$seed <- strsplit(filepath,"Seed|/results")[[1]][2]
  setup <- strsplit(filepath,"Mini//|3d//|/Seed")[[1]][2]
  counts$id <- setup
  counts$time <- with(counts,as.numeric(levels(time)[as.numeric(time)]))
  counts$time <- with(counts, (time-min(time))/24)
  counts <- cbind(counts,extractParametersFromID(setup))
  return(counts)
}







