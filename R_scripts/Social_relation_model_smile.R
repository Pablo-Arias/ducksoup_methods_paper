cat("\f")
rm(list=ls())

# Init
graphics.off()
library("MASS")
library(ez)
library(afex)
library(phia)
library(doBy)
library(effsize)
library(lmerTest);
library(dplyr);
library(srm);
library(ggplot2)
library(TripleR)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


#Import data
file_name = "../data/mediapipe_results/smile.csv"

#read data
data = read.table(file_name, header=TRUE,sep=',')
head(data)

#defining outcomes
measure			          <-as.numeric(data$smile)

#defining predictors (categorical)
participant_condition 	<- as.factor(data$participant_condition)
participant_condition   <- relevel(participant_condition, "S")
other_condition 		    <- as.factor(data$other_condition)
other_condition         <- relevel(other_condition, "S")
participant_nb			    <- as.factor(data$user_id)
interacting_partner			<- as.factor(data$other_id)
group_id		            <- as.factor(data$sid)
manipulated		          <- as.factor(data$manipulated)

#create new dataframe
clean_data=data.frame( measure, participant_condition , interacting_partner, other_condition, participant_nb, group_id, manipulated)
head(clean_data)

## -------------------------------------- ##
## -------------------------------------- ##
## GLMM Analysis ------------------------ ##
## -------------------------------------- ##
## -------------------------------------- ##

#Remove all non manipulated trials
clean_data <- clean_data[clean_data$manipulated == "False",]


#Social relation Model
RR.style("perception")

#Round Robin
RR1 <- RR(measure ~ participant_nb * interacting_partner | group_id, data = clean_data, na.rm = TRUE)
RR1


#Missing values
plot_missings(measure ~ participant_nb * interacting_partner | group_id, data = clean_data, show.ids = FALSE)

#Variance covariance
plot(RR1)


RR1$effects #measure perceiver and target
RR1$effectsRel

result_file = paste("data/mediapipe_results/srm_smile.csv", sep="")
write.csv(RR1$effectsRel, result_file) #Relationships

df = data(likingLong)


str(likingLong)
