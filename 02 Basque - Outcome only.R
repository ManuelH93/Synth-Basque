#######################################################################
# Preparation
#######################################################################

#Clean director
#######################################################################
rm(list=ls())

# Install packages
#######################################################################

#install.packages(c(
# "Synth",
# "xlsx" ))

# Load packages
#######################################################################

library("Synth")
library("xlsx")

# Import data
#######################################################################

data("basque")
#write.xlsx(basque, "/Users/manuelheller/Documents/Projects/Synth Basque/Raw Data/basque.xlsx")

# Explore data
#######################################################################

basque[85:89, 1:4]

# Prepare data
#######################################################################

dataprep.out <- dataprep(
  foo = basque,
  time.predictors.prior = 1960:1969,
  special.predictors = list(
    list("gdpcap", 1960 , "mean"),
    list("gdpcap", 1961 , "mean"),
    list("gdpcap", 1962 , "mean"),
    list("gdpcap", 1963 , "mean"),
    list("gdpcap", 1964 , "mean"),
    list("gdpcap", 1965 , "mean"),
    list("gdpcap", 1966 , "mean"),
    list("gdpcap", 1967 , "mean"),
    list("gdpcap", 1968 , "mean"),
    list("gdpcap", 1969 , "mean")),
  dependent = "gdpcap",
  unit.variable = "regionno",
  unit.names.variable = "regionname",
  time.variable = "year",
  treatment.identifier = 17,
  controls.identifier = c(2:16, 18),
  time.optimize.ssr = 1960:1969,
  time.plot = 1955:1997)

# View data
#######################################################################

dataprep.out$X1
dataprep.out$X0
dataprep.out$Z0
dataprep.out$Z1

#######################################################################
# Synthetic control analysis
#######################################################################

synth.out <- synth(data.prep.obj = dataprep.out, method = "BFGS",
                   custom.v = c(1,1,1,1,1,1,1,1,1,1))
gaps <- dataprep.out$Y1plot - (dataprep.out$Y0plot %*% synth.out$solution.w)
gaps[1:3, 1]

synth.tables <- synth.tab(dataprep.res = dataprep.out,
                          synth.res = synth.out)
names(synth.tables)
synth.tables$tab.pred[1:5, ]

synth.tables$tab.w[8:14, ]

#######################################################################
# Graphs
#######################################################################

path.plot(synth.res = synth.out, dataprep.res = dataprep.out,
          Ylab = "real per-capita GDP (1986 USD, thousand)", Xlab = "year",
          Ylim = c(0, 12), Legend = c("Basque country",
                                      "synthetic Basque country"), Legend.position = "bottomright")

gaps.plot(synth.res = synth.out, dataprep.res = dataprep.out,
          Ylab = "gap in real per-capita GDP (1986 USD, thousand)", Xlab = "year",
          Ylim = c(-1.5, 1.5), Main = NA)
