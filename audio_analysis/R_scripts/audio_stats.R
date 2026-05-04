cat("\f")
rm(list=ls())

# Init
graphics.off()
library("MASS")
library(afex)
library(phia)
library(doBy)
library(effsize)
library(lmerTest);
library(dplyr);
library("sjPlot")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#Import data
file_name = "../data/audio_data/collapsed_pitch_from_server.csv"

#read data
data = read.table(file_name, header=TRUE,sep=',')
head(data)

#defining outcomes
#measure			          <-as.numeric(data$f0_mean)
measure			          <-as.numeric(data$f0_std)


#defining predictors (categorical)
participant_condition 	<- as.factor(data$participant_condition)
participant_condition   <- relevel(participant_condition, "U")
other_condition 		    <- as.factor(data$other_condition)
other_condition         <- relevel(other_condition, "U")
participant_nb			    <- as.factor(data$user_id)
interacting_partner			<- as.factor(data$other_id)

#create new dataframe
clean_data=data.frame( measure, participant_condition , interacting_partner, other_condition, participant_nb )

## -------------------------------------- ##
## -------------------------------------- ##
## GLMM Analysis ------------------------ ##
## -------------------------------------- ##
## -------------------------------------- ##

# Choose the question you want to anlayse


## ---- With both participant_nb and interacting_partner as random factors
nul<- lmer( measure ~ 1            	     	                       + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
v0 <- lmer( measure ~ participant_condition                        + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
v1 <- lmer( measure ~ other_condition                              + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
v2 <- lmer( measure ~ other_condition + participant_condition      + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
v3 <- lmer( measure ~ other_condition * participant_condition      + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )

aov.out = anova(nul,v0)
aov.out
aov.out = anova(nul,v1)
aov.out
aov.out = anova(nul,v2)
aov.out
aov.out = anova(nul,v3)
aov.out

#Interaction
aov.out = anova(v0,v3)
aov.out


#summary
summary(v0)
summary(v3)

#plot

plot_model( v3, type = "pred", terms = c("participant_condition", "other_condition") )

predict_gam(v3)

