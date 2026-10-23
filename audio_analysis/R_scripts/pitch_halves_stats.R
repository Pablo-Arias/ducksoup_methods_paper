cat("\f")
rm(list=ls())

# Init
graphics.off()
library(lmerTest);
library(emmeans);

if (rstudioapi::isAvailable()) setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#Import data
# Pitch measures of the first (0-125 s) and second (125-250 s) half of each recording,
# written by pitch_std_decomposition.ipynb (halves with at least 2.5 s of voiced speech)
file_name = "../../data/audio_data/pitch_halves_v3.csv"

#read data
data = read.table(file_name, header=TRUE,sep=',')
head(data)
cat("recordings per half:", table(data$half), "\n")

#defining predictors (categorical)
data$participant_condition   <- relevel(as.factor(data$participant_condition), "U")
data$other_condition         <- relevel(as.factor(data$other_condition), "U")
data$participant_nb          <- as.factor(data$user_id)
data$interacting_partner     <- as.factor(data$other_id)
data$recording               <- as.factor(data$file)
data$half                    <- as.factor(data$half)

## -------------------------------------- ##
## GLMM Analysis ------------------------ ##
## -------------------------------------- ##

# f0_std : pitch SD (Hz); high_pct : % of voiced speech above the speaker's p90; p90 : semitones re. the speaker's median
for (measure_name in c("f0_std", "high_pct", "p90")) {
  cat("\n\n==================== ", measure_name, " ====================\n")
  data$measure <- as.numeric(data[[measure_name]])

  # Same models as audio_stats.R, in each half
  for (h in c("first", "second")) {
    cat("\n----- ", h, " half -----\n")
    clean_data = data[data$half == h, ]

    nul<- lmer( measure ~ 1            	     	                       + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
    v0 <- lmer( measure ~ participant_condition                        + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
    v2 <- lmer( measure ~ other_condition + participant_condition      + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
    v3 <- lmer( measure ~ other_condition * participant_condition      + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )

    # Main effect of participant condition
    print(anova(nul,v0))
    # Interaction (1 df): additive model vs full model
    print(anova(v2,v3))

    # Model-estimated means of each cell, and SS vs each other cell with SE and 95% CI
    # (cells named participant/other, e.g. "S U" = participant S, other U)
    em <- emmeans::emmeans(v3, ~ participant_condition * other_condition)
    print(summary(em))
    print(summary(contrast(em, list("SS-SU" = c(0, -1, 0, 1), "SS-US" = c(0, 0, -1, 1), "SS-UU" = c(-1, 0, 0, 1))), infer = TRUE))
  }

  # Does the interaction differ between halves? Both halves in one model, with a random intercept per recording
  # (the two halves of a recording are not independent); the reduced model has no half x participant x other term
  m2 <- lmer( measure ~ other_condition * participant_condition * half - other_condition:participant_condition:half + (1 | participant_nb) + (1 | interacting_partner) + (1 | recording), data= data, REML = FALSE )
  m3 <- lmer( measure ~ other_condition * participant_condition * half + (1 | participant_nb) + (1 | interacting_partner) + (1 | recording), data= data, REML = FALSE )
  cat("\nhalf x participant x other condition :\n")
  print(anova(m2,m3))
}
