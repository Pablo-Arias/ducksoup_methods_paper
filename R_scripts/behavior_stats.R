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
file_name = "../data/behavior/all_data_df.csv"

#read data
data = read.table(file_name, header=TRUE,sep=',')
head(data)

#defining outcomes
measure			          <-as.numeric(data$measure)

#defining predictors (categorical)
participant_condition 	<- as.factor(data$participant_condition)
participant_condition   <- relevel(participant_condition, "S")
other_condition 		    <- as.factor(data$other_condition)
other_condition         <- relevel(other_condition, "S")
participant_nb			    <- as.factor(data$user_id)
interacting_partner			<- as.factor(data$other_id)
question_content		    <- as.factor(data$question_content)

#create new dataframe
all_data=data.frame( measure, participant_condition , interacting_partner, other_condition, participant_nb, question_content )

## -------------------------------------- ##
## -------------------------------------- ##
## GLMM Analysis ------------------------ ##
## -------------------------------------- ##
## -------------------------------------- ##

# Choose the question you want to anlayse
#question = "conversation_quality"
#question = "liked"
#question = "other_liked"
#question = "video_conf_quality"

clean_data <- all_data[all_data$question_content == question,]

head(clean_data)



## ---- With both participant_nb and interacting_partner as random factors
nul<- lmer( measure ~ 1            	     	                         + (1 | participant_nb) + (1 | interacting_partner), data= clean_data, REML = FALSE )
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
aov.out = anova(nul,v3)
aov.out

#summary
summary(v3)

#plot
plot_model( v3, type = "pred", terms = c("participant_condition", "other_condition") )

predict_gam(v3)

