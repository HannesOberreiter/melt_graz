# Please see data folder for sample files
SCRIPT.DIR <- dirname( rstudioapi::getActiveDocumentContext()$path )
setwd( SCRIPT.DIR )

# We use renv for version controlling (https://rstudio.github.io/renv/articles/renv.html)
#### DOCKER FIRST RUN ####
renv::restore()

# Check if renv is ready and activated
renv::status()

# 1. Loading Libs ####
library("tidyverse")
library("qpcR")

# 2. Read Data ####
D.RAW   <- read_csv2("data/raw.csv", trim_ws = TRUE)
D.TAXON <- read_csv2("data/taxon.csv", trim_ws = TRUE)

# Define a melting window, it should include all our melting curves
V.WINDOW <- c(75,85)

D.RAW <- D.RAW[D.RAW$temp >= V.WINDOW[1] & D.RAW$temp <= V.WINDOW[2],]

# 3. Melting Curve Analysis with qpcR ####
D.RAW.FRAME <- data.frame(D.RAW)
V.TEMP      <- rep(1, ncol(D.RAW.FRAME)-1)
V.SAMPLES   <- c(2:ncol(D.RAW))

L.MELT <- meltcurve(
  D.RAW.FRAME, 
  cut.Area = c(0.2),
  window = V.WINDOW,
  temps = c(V.TEMP), 
  fluos = c(V.SAMPLES), norm = TRUE, calc.Area = TRUE)
dev.off()
# check if all peaks have good quality, otherweise we need to play with the cut.Area
print("#####################")
print("QUALITY of peaks with given cut.Area")
sapply(L.MELT, function(x){
  attr(x, "quality")}
  )
# Extract Tm values
V.TM <- sapply(L.MELT, function(x){
  c("Tm" = x$Tm[1])
})
# combine with data frame
D.TAXON <- cbind(D.TAXON, tm = V.TM)
# Use two.sided welch-test
V.WELCH <- t.test(tm ~ taxon, data = D.TAXON, alterantive = "two.sided")

V.WELCH
V.WILCOX <- wilcox.test(tm ~ taxon, data = D.TAXON, alterantive = "two.sided", conf.int = TRUE)
V.WILCOX

print("#####################")
V.WELCH

qqnorm(D.TAXON$tm[D.TAXON$taxon == "C. luteus"], main = "C. luteus QQ-Plot")
qqline(D.TAXON$tm[D.TAXON$taxon == "C. luteus"])
dev.off()
qqnorm(D.TAXON$tm[D.TAXON$taxon == "C. variegatus"], main = "C. variegatus QQ-Plot")
qqline(D.TAXON$tm[D.TAXON$taxon == "C. variegatus"])
dev.off()
shapiro.test(D.TAXON$tm[D.TAXON$taxon == "C. variegatus"])
shapiro.test(D.TAXON$tm[D.TAXON$taxon == "C. luteus"])

qqnorm(D.TAXON$tm[D.TAXON$taxon == "C. luteus"])

D.SAMPLEN <- D.TAXON %>% group_by(taxon) %>% summarize(n = n())

ggplot(D.TAXON, aes(x = taxon, y = tm, label = )) + 
  geom_boxplot() + geom_point() +
  #geom_text(aes(label = D.SAMPLEN$n)) +
  theme_classic() +
  xlab("Taxon") + ylab("Identified melting points (Tm) [C°]")

# 3. Transform Tables ####
D.LONG <- pivot_longer(D.RAW, -temp, names_to = c("id"))
D.LONG$rescaled <- qpcR:::rescale(D.LONG$value, 0, 1)
D.LONG <- left_join(D.LONG, D.TAXON, by = c("id"))

# 4. Plot RFU ####
ggplot(D.LONG, aes(x = temp, y = rescaled, color = taxon, shape = id)) + 
  geom_line() + 
  ggtitle("Raw Fluoresenz all Sample") + ylab("RFU") + xlab("Temperature [°C]") + 
  theme_classic() 

D.RFU <- D.LONG %>% group_by(taxon, temp) %>%
  summarise(
    m = mean(value),
    s = sd(value)
  )
d = tibble()
V.COUNTER <- 1
for (x in L.MELT) {
  x$taxon <- D.TAXON$taxon[V.COUNTER]
  x$id <- D.TAXON$id[V.COUNTER]
  d <- bind_rows(d, x)
  V.COUNTER = V.COUNTER + 1
}


ggplot(d, aes(x = Temp, y = df.dT, color = taxon, shape = id)) + 
  geom_line() + 
  ggtitle("First derivetive") + ylab("-dF/dT") + xlab("Temperature [°C]") + 
  theme_classic() 
