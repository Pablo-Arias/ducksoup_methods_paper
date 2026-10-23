cat("\f")
rm(list=ls())

# Init
graphics.off()
library(lmerTest);
library(emmeans);

if (rstudioapi::isAvailable()) setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#Import data
# Smile episodes per recording (first 250 s; eyes : py-feat AU06, mouth : MediaPipe smile),
# written by face_analysis/smile_aligned_decomposition.ipynb
file_name = "../data/face_data/smile_episodes_v3.csv"

#read data
data = read.table(file_name, header=TRUE,sep=',')
head(data)

#defining predictors (categorical)
data$participant_condition   <- relevel(as.factor(data$participant_condition), "U")
data$other_condition         <- relevel(as.factor(data$other_condition), "U")
data$participant_nb          <- as.factor(data$user_id)
data$interacting_partner     <- as.factor(data$other_id)

## -------------------------------------- ##
## GLMM Analysis ------------------------ ##
## -------------------------------------- ##

# time_smiling : % of the time spent smiling; rate : smile episodes per minute;
# gap : median time between two smiles (s); peak : mean maximum of the episodes
for (signal_name in c("mouth", "eyes")) {
  for (measure_name in c("time_smiling", "rate", "gap", "peak")) {
    cat("\n\n==================== ", signal_name, measure_name, " ====================\n")
    clean_data = data[data$signal == signal_name, ]
    clean_data$measure <- as.numeric(clean_data[[measure_name]])
    clean_data = clean_data[!is.na(clean_data$measure), ]
    cat(nrow(clean_data), "recordings\n")

    nul<- lmer( measure ~ 1            	     	                       + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
    v0 <- lmer( measure ~ participant_condition                        + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
    v1 <- lmer( measure ~ other_condition                              + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
    v2 <- lmer( measure ~ other_condition + participant_condition      + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
    v3 <- lmer( measure ~ other_condition * participant_condition      + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )

    # Main effect of participant condition
    print(anova(nul,v0))
    # Main effect of other condition
    print(anova(nul,v1))
    # Interaction (1 df): additive model vs full model
    print(anova(v2,v3))

    # Model-estimated means of each cell, and SS vs each other cell with SE and 95% CI
    # (cells named participant/other, e.g. "S U" = participant S, other U)
    em <- emmeans::emmeans(v3, ~ participant_condition * other_condition)
    print(summary(em))
    print(summary(contrast(em, list("SS-SU" = c(0, -1, 0, 1), "SS-US" = c(0, 0, -1, 1), "SS-UU" = c(-1, 0, 0, 1))), infer = TRUE))
  }
}
