# Please see data folder for sample files
# We use renv for version controlling (https://rstudio.github.io/renv/articles/renv.html)

# Check if renv is ready and activated
renv::status()
SCRIPT.DIR <- dirname( rstudioapi::getActiveDocumentContext()$path )
setwd( SCRIPT.DIR )
# 1. Loading Libs ####
library("tidyverse")
library("qpcR")
# 2. Read Data ####
D.RAW   <- read_csv2("data/raw.csv", trim_ws = TRUE)
D.TAXON <- read_csv2("data/taxon.csv", trim_ws = TRUE)

# Define a melting window, it should include all our melting curves
V.WINDOW <- c(75,85)

# 3. Melting Curve Analysis with qpcR ####
D.RAW.FRAME <- data.frame(D.RAW)
V.TEMP      <- rep(1, ncol(D.RAW.FRAME)-1)
V.SAMPLES   <- c(2:ncol(D.RAW))

L.MELT <- meltcurve(
  D.RAW.FRAME, 
  cut.Area = c(0.2),
  window = c(75, 85),
  temps = c(V.TEMP), 
  fluos = c(V.SAMPLES), norm = TRUE, calc.Area = TRUE)

# check if all peaks have good quality, otherweise we need to play with the cut.Area
sapply(L.MELT, function(x){attr(x, "quality")})

L.MELT[[1]]$Tm


sapply(L.MELT, function(x){attr(x, "quality")})



# 3. Transform Tables ####
D.LONG <- pivot_longer(D.RAW, -temp, names_to = c("id"))
D.LONG <- left_join(D.LONG, D.TAXON, by = c("id"))


# 4. Plot RFU ####
ggplot(D.LONG, aes(x = temp, y = value, color = taxon, shape = id)) + 
  geom_line() + 
  ggtitle("mean -dF/dT Plot") + ylab("-dF/dt") + theme_classic()

D.RFU <- D.LONG %>% group_by(taxon, temp) %>%
  summarise(
    m = mean(value),
    s = sd(value)
  )

m1 <- pcrfit(reps, 1, 2, l4) 


pcrfit()

f<-res1[[18]][["Area"]]
attr(res1[[2]], "quality")

res1[[2]]

ggplot(D.RFU, aes(x = temp, y = m, color = taxon)) + geom_line() + 
  ggtitle("mean -dF/dT Plot") + ylab("-dF/dt") + theme_classic()