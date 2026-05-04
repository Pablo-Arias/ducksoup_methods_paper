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


#AU6
measure <- "AU06"
file_name = "../data/pyf_results/au06.csv"

#SMILE
#file_name = "../data/mediapipe_results/smile.csv"
#measure <- "smile"

#Happiness
#file_name = "../data/pyf_results/happiness.csv"
#measure <- "happiness"


#read data
data = read.table(file_name, header=TRUE,sep=',')
head(data)

#defining outcomes
measure			          <-as.numeric(data[[measure]])

#defining predictors (categorical)
participant_condition 	<- as.factor(data$participant_condition)
participant_condition   <- relevel(participant_condition, "S")
other_condition 		    <- as.factor(data$other_condition)
other_condition         <- relevel(other_condition, "S")
participant_nb			    <- as.factor(data$user_id)
interacting_partner			<- as.factor(data$other_id)
manipulated			        <- as.factor(data$manipulated)

#create new dataframe
clean_data=data.frame( participant_nb, interacting_partner, manipulated, participant_condition , other_condition, measure)

clean_data = clean_data %>%
  group_by(participant_nb, participant_condition, other_condition, interacting_partner, manipulated) %>%
  summarise_at(c("measure"), mean, na.rm = TRUE) # change to smile/hapiness, mean/SD depending on facial mimicry or SD analysis

clean_data <- clean_data[clean_data$manipulated == "False",]


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
#summary(v1)


aov.out = anova(nul,v2)
aov.out
aov.out = anova(nul,v3)
aov.out


aov.out = anova(v1,v3)
aov.out
summary(v3)

#Interaction
#aov.out = anova(v2,v3)
#aov.out

g <- plot_model(v3, type = "int", terms = c("participant_condition", "other_condition"))
print(g)

