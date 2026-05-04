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
group_id		            <- as.factor(data$sid)

#create new dataframe
all_data=data.frame( measure, participant_condition , interacting_partner, other_condition, participant_nb, question_content, group_id )

## -------------------------------------- ##
## -------------------------------------- ##
## GLMM Analysis ------------------------ ##
## -------------------------------------- ##
## -------------------------------------- ##

# Choose the question you want to anlayse
question = "conversation_quality"
#question = "liked"
#question = "other_liked"
#question = "video_conf_quality"

clean_data <- all_data[all_data$question_content == question,]
head(clean_data)


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

result_file = paste("data/behavior/srm/",question,".csv", sep="")
write.csv(RR1$effectsRel, result_file) #Relationships

df = data(likingLong)


str(likingLong)
