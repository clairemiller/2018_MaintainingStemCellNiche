source("functions.R")

# Adhesion
da <- data.frame(s = seq(0.0,1.2,0.01))
alpha = 1.0
lambda = 7.0 
c1 = sqrt(0.5/lambda)
c2 = c1*exp(-lambda*c1*c1)
s = da$s/0.5;
da$f <- -alpha*( (s+c1)*exp(-lambda*(s+c1)^2) - c2*exp(-lambda*s*s) )
da$t = "Adhesion"

# Exponential repulsion
dr <- data.frame(s = seq(-0.25,0.0,0.01))
dr$f <- log(1+dr$s)
dr$t <- "Repulsion"

# Combine
d <- rbind(da,dr)

# Plot and output
p <- ggplot(d) + 
  geom_line(aes(x=s,y=f,colour=t),size=2) + 
  coord_cartesian(ylim=c(-0.03,0.03)) +
  labs(x=TeX("$s_{ij}$ [cell units]"),y=TeX("$F_{ij}$ normalised"), colour="Force" )
#print(p)

p_out <- outputPaperPlot(p,"force",pheight=600,legend.position=c(0.8,0.8))
