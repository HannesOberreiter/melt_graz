# 1. Loading Libs ####
library("tidyverse")
library("qpcR")
library("boot")
library("vegan")

# 2. Read Data ####
D.RAW   <- read_csv2("data/raw.csv",   trim_ws = TRUE)
D.TAXON <- read_csv2("data/taxon.csv", trim_ws = TRUE)

# 3. Definitions ####
V.SAVE <- c("~/lokal/output/") # Save Path for Outputs
V.WINDOW <- c(75,85) # Define a melting window, it should include all our melting curves
D.RAW <- D.RAW[D.RAW$temp >= V.WINDOW[1] & D.RAW$temp <= V.WINDOW[2],]
V.TAXON <- unique(D.TAXON$taxon)

# 4. Plot RFU ####
D.LONG <- pivot_longer(D.RAW, -temp, names_to = c("id"))
D.LONG$rescaled <- qpcR:::rescale(D.LONG$value, 0, 1)
D.LONG <- left_join(D.LONG, D.TAXON, by = c("id"))

# all samples
P.RFU <- ggplot(D.LONG, aes(x = temp, y = rescaled, color = taxon, shape = id)) + 
  geom_line() + 
  ggtitle("") + ylab("RFU") + xlab("Temperature [°C]") + 
  theme_classic()+
  guides(colour = guide_legend(
    title = "Taxon:", 
    label.theme = element_text(
      face = "italic"  
    ))
  )
P.RFU
ggsave(paste(V.SAVE, "RFU_Melt.pdf", sep = ""))

# mean of taxon + sd
D.SUM <- D.LONG %>% group_by(taxon, temp) %>% summarize(
  n = n(),
  m = mean(rescaled),
  uppersd = mean(rescaled)+sd(rescaled),
  lowersd = mean(rescaled)-sd(rescaled)
)

D.SUM$uppersd[D.SUM$uppersd > 1] <- 1
D.SUM$lowersd[D.SUM$lowersd < 0] <- 0

P.RFUSD <- ggplot(D.SUM, aes(x = temp, y = m, color = taxon)) + 
  geom_ribbon(
    aes(ymin=uppersd, ymax=lowersd, fill = taxon, colour = NA), 
    alpha = 0.3, show.legend = FALSE
    )+
  geom_line(size=2) + 
  scale_fill_manual("",values=c("grey12", "grey12")) +
  ggtitle("") + ylab("RFU") + xlab("Temperature [°C]") + 
  theme_classic()+
  guides(colour = guide_legend(
    title = "Taxon:", 
    label.theme = element_text(
      face = "italic"  
    ))
  )

P.RFUSD
ggsave(paste(V.SAVE, "RFU_Melt_SD.pdf", sep = ""))

# 5. Melting Curve Analysis with qpcR ####
D.RAW.FRAME <- data.frame(D.RAW)
V.TEMP      <- rep(1, ncol(D.RAW.FRAME)-1)
V.SAMPLES   <- c(2:ncol(D.RAW))

# Calc and Visualize
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

# 5.1. Tm values ####
# Extract Tm values
V.TM <- sapply(L.MELT, function(x){
  c("Tm" = x$Tm[1])
})
# combine with data frame
D.TAXON <- cbind(D.TAXON, tm = V.TM)

# Use two.sided welch-test
V.WELCH <- t.test(tm ~ taxon, data = D.TAXON, alterantive = "two.sided")
print("#####################")
V.WELCH

# QQ Plots
qqnorm(D.TAXON$tm[D.TAXON$taxon == "C. luteus"], main = "C. luteus QQ-Plot")
qqline(D.TAXON$tm[D.TAXON$taxon == "C. luteus"])
dev.off()
qqnorm(D.TAXON$tm[D.TAXON$taxon == "C. variegatus"], main = "C. variegatus QQ-Plot")
qqline(D.TAXON$tm[D.TAXON$taxon == "C. variegatus"])
dev.off()

# Test for norm. distribution
#shapiro.test(D.TAXON$tm[D.TAXON$taxon == "C. variegatus"])
#shapiro.test(D.TAXON$tm[D.TAXON$taxon == "C. luteus"])

# Extract Sample Size
D.SAMPLEN <- D.TAXON %>% group_by(taxon) %>% summarize(n = n())

# Boostrap Mean and 95% CI
L.BOOT = list()
for(t in V.TAXON){
  L.BOOT[[t]] = boot(D.TAXON$tm[D.TAXON$taxon == t],
                    function(x,i) mean(x[i]),
                    R=10000)
  L.BOOT[[t]] = boot.ci(L.BOOT[[t]],
          conf = 0.95,
          type = c("norm", "basic" ,"perc", "bca")
  )
  print("#####")
  print(t)
  print(paste("Mean:", L.BOOT[[t]]$t0))
  print(L.BOOT[[t]])
  print("#######")
}
rm(t)

# Insert all values into a tibble for easier access
D.TM <- tibble(
  taxon = V.TAXON,
  sample = D.SAMPLEN,
  mean = x <- unlist(use.names = FALSE, lapply(L.BOOT, function(x){
    return(x$t0)
  })),
  upper = x <- unlist(use.names = FALSE, lapply(L.BOOT, function(x){
    return(x[["bca"]][5])
  })),
  lower = x <- unlist(use.names = FALSE, lapply(L.BOOT, function(x){
    return(x[["bca"]][4])
  }))
)

P.TM <- ggplot(D.TAXON, 
        aes(x = taxon, y = tm, color = taxon)) + 
  geom_errorbar(
    data = D.TM, 
    aes(x = taxon, y = mean, ymin = lower, ymax = upper),
    width = 0.5, color = "black", show.legend = NA
    ) + 
  geom_point(
    data = D.TM, 
    aes(x = taxon, y = mean),
    size = 5, color = "black", show.legend = NA
  ) +
  geom_point(show.legend=NA) +
  geom_text(
    data = D.TM, 
    aes(x = taxon, y = min(D.TAXON$tm), label = paste("n =", D.SAMPLEN$n)),
    color="black", show.legend=NA) +
  xlab("") + ylab("Identified melting points (Tm) [C°]") + 
  theme_classic() +
  theme(axis.text.x = element_text(face = "italic"), legend.position = "none")
P.TM
ggsave(paste(V.SAVE, "TM_melt.pdf", sep = ""))

# 5.2 Plot dF/dT ####

# Transform lists into DF for plotting
D.FT = tibble()
V.COUNTER <- 1
for (x in L.MELT) {
  x$taxon <- D.TAXON$taxon[V.COUNTER]
  x$id <- D.TAXON$id[V.COUNTER]
  D.FT <- bind_rows(D.FT, x)
  V.COUNTER = V.COUNTER + 1
}

P.DFDT <- ggplot(data = D.FT, aes(x = Temp, y = df.dT, color = taxon, shape = id)) + 
  geom_line() + 
  ggtitle("") + ylab("-dF/dT") + xlab("Temperature [°C]") + 
  theme_classic() + 
  guides(colour = guide_legend(
    title = "Taxon:", 
    label.theme = element_text(
      face = "italic"  
    ))
  )
P.DFDT 
ggsave(paste(V.SAVE, "DFDT_Melt.pdf", sep = ""))

# 6. Euclidean Distance ####
# Transform for adonis function
D.TEMP <- D.FT[,c(1,3,9:10)]
D.WIDE <- pivot_wider(
    D.TEMP, id_cols = c("id", "taxon"), names_from=Temp, values_from=df.dT
  )
V.WIDE_SPECIES <- as.factor(D.WIDE$taxon)
D.VALS <- D.WIDE[,-c(1:2)]
V.PERM <- adonis(D.VALS ~ V.WIDE_SPECIES, method="euclidean", permutations=10000)
V.PERM