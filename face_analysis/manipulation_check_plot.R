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
library(srm);
library(ggplot2)
library(TripleR)
library(Rmisc)
library(tidyverse)
library(truncnorm)
library(scales)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

file_name = "../data/face_data/mediapipe_results/manipulation_check.csv"

data = read.table(file_name, header=TRUE,sep=',')

head(data)

smile                           <-as.numeric(data$smile)
manipulated                     <- as.factor(data$manipulated)
participant_nb                  <- as.factor(data$user_id)
interacting_partner             <- as.factor(data$other_id)
participant_condition           <- as.factor(data$participant_condition)
other_condition                 <- as.factor(data$other_condition)


clean_data <- data.frame(smile, manipulated, participant_nb, interacting_partner, participant_condition, other_condition)

head(clean_data)



##--------------------------------------------------------
##--------------------------------------------------------
## --------------- Plot for Paper ------------------------
##--------------------------------------------------------
##--------------------------------------------------------

## Box plot
# Create the box plot
# Rename the levels of "participant_condition" variable
reduced_df = clean_data %>%
  group_by(participant_nb, participant_condition, manipulated) %>%
  summarise_at(c("smile"), mean, na.rm = TRUE)

#rename variables
reduced_df$participant_condition <- factor(reduced_df$participant_condition, levels = c("S", "U"), labels = c("increase", "decrease"))

# Create a new variable to store the box colors based on conditions
reduced_df$box_color <- with(reduced_df, ifelse(interaction(manipulated, participant_condition) == "true.decrease", "red",
                                                ifelse(interaction(manipulated, participant_condition) == "true.increase", "blue", "black")))

# Convert the box_color variable to a factor with appropriate levels
reduced_df$box_color <- factor(reduced_df$box_color, levels = c("black", "red", "blue"))

ggplot(reduced_df, aes(x = participant_condition, y = smile, fill = box_color)) +
  geom_boxplot(outlier.shape = NA, position = position_dodge(width = 0.8), color = "darkgray", alpha = 0.8) +
  geom_jitter(aes(color = box_color), alpha = 0.7, position = position_jitterdodge()) +
  facet_grid(. ~ participant_condition*manipulated, scales = "free_x", space = "free_x") +
  labs(x = "Participant Manipulation", y = "Smiling Activity (a.u.)", fill = "",
       color = "") +  # Remove fill and color labels
  scale_fill_manual(values = c("black","#3399FF", "#FF3333")) + # Deeper red and blue shades for boxes
  scale_color_manual(values = c("black", "#336699", "#993333")) + # Darker shades for dots
  theme_minimal() +
  theme(
    text = element_text(size = 15, color = "black"),
    axis.text.x = element_text(size = 12, color="black"),
    axis.text.y = element_text(size = 12, color="black"),
    legend.position = "none",
  ) + 
  ylim(0, 2.2)

ggsave("plots/manipulation_check.pdf", width = 14, height = 10, units = "cm")


# Perform paired t-tests for increase and decrease smile conditions
# Subset data for the 'increase' condition
increase_data <- subset(reduced_df, participant_condition == "increase")
decrease_data <- subset(reduced_df, participant_condition == "decrease")

# Paired t-test for the 'increase' condition
increase_ttest <- t.test(
  smile ~ manipulated,
  data = increase_data,
  paired = TRUE
)

# Calculate Cohen's d for 'increase' condition
increase_cohen_d <- cohen.d(
  increase_data$smile[increase_data$manipulated == "true"],
  increase_data$smile[increase_data$manipulated == "false"],
  paired = TRUE
)

# Paired t-test for the 'decrease' condition
decrease_ttest <- t.test(
  smile ~ manipulated,
  data = decrease_data,
  paired = TRUE
)

# Calculate Cohen's d for 'decrease' condition
decrease_cohen_d <- cohen.d(
  decrease_data$smile[decrease_data$manipulated == "true"],
  decrease_data$smile[decrease_data$manipulated == "false"],
  paired = TRUE
)

# Print the results
cat("Results of paired t-test for 'increase' condition:\n")
print(increase_ttest)
cat("Cohen's d for 'increase' condition:\n")
print(increase_cohen_d)

cat("\nResults of paired t-test for 'decrease' condition:\n")
print(decrease_ttest)
cat("Cohen's d for 'decrease' condition:\n")
print(decrease_cohen_d)
