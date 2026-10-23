
# Introduction

In this repository you will find the analyses scripts of the article "Covert control over the real-time dynamics of human interactions with DuckSoup", by Pablo Arias-Sarah (1,2,3,+), Guillaume Denis (4), Philippe G. Schyns (2), Rachael E. Jack (2), Petter Johansson (1), Lars Hall (1) and Jean-Julien Aucouturier (5)

1 Lund University Cognitive Science, Lund University, Lund, Sweden
2 School of Neuroscience and Psychology, University of Glasgow, Glasgow, UK
3 Univ. Grenoble Alpes, Univ. Savoie Mont Blanc, CNRS, LPNC, Grenoble, France
4 Independent Researcher, Marseille, France
5 Université Marie et Louis Pasteur, SUPMICROTECH, CNRS, institut FEMTO-ST, Besançon, France
+Corresponding author


In this article we show that aligning the smiles of meet up participants with smile transformation filters causally increases liking, and that these transformations propagate to participants' facial, vocal and verbal behavior. In this repository you will find the python and R scripts to replicate all the analyses in both the main paper and the Supplementary Information. 

## Importing data
To use these scripts please download the raw data online here : https://archive.org/details/data_20260901

    Put the downloaded data in a folder called "data/" in the root of this project. Then execute the scripts.

## Analyses
These analyses include:
- Manipulation Check
- Behavior analyses (ratings and Social Relation Models)
- Facial mimicry analyses (MediaPipe smile, py-feat AU06, AU15 and happiness)
- Expressive synchrony analyses
- Voice analyses (mean pitch, pitch standard deviation and pitch distributions)
- Semantic analysis (LLM ratings of the transcripts)

Please refer to the paper's method sections and Supplementary Information for a precise description of the methods implemented in these analyses.

## Running the analyses
The python notebooks process the data and write the tables used for the statistics. The statistics are done in R. Execute the scripts in this order:

1. behaviour/Behavior.ipynb : exclusions and behavioral data (writes data/behavior/all_data_df.csv)
2. R_scripts/Social_relation_model.R : Social Relation Models, once for each question (liked, other_liked, conversation_quality, video_conf_quality)
3. behaviour/Behavior.ipynb again : merges the Social Relation Models (writes data/behavior/srm/all_srm.csv)
4. The analysis notebooks :
    - face_analysis/Facial expression analysis_mp.ipynb : smile (MediaPipe)
    - face_analysis/Facial expression analysis_PF.ipynb : AU06, AU15, happiness and expressive synchrony (py-feat)
    - face_analysis/smile_aligned_decomposition.ipynb : smile distributions, smile episodes and time course (Supplementary Information)
    - audio_analysis/audio_analysis.ipynb : mean pitch and pitch standard deviation
    - audio_analysis/pitch_std_decomposition.ipynb : pitch distributions, first and second half (Supplementary Information)
    - semantic_analysis/GPT analysis.ipynb : LLM ratings (don't execute the cell calling the Azure OpenAI API, the predictions are already in semantic_analysis/data/predictions)
5. The R scripts :
    - R_scripts/behavior_stats.R and R_scripts/behavior_stats_srm.R : ratings
    - R_scripts/mimicry.R : smile, AU06, AU15 and happiness (one block per measure)
    - R_scripts/smile_episodes_stats.R : smile episodes
    - audio_analysis/R_scripts/audio_stats.R : mean pitch and pitch standard deviation
    - audio_analysis/R_scripts/pitch_halves_stats.R : first and second half
    - semantic_analysis/GPT_glmm_stats.R : LLM ratings
    - face_analysis/manipulation_check_plot.R : manipulation check

In behavior_stats.R, behavior_stats_srm.R, Social_relation_model.R and GPT_glmm_stats.R, the question is chosen in the line question = "..." at the top of the script.

## Software
We used python 3.10 (pandas 2.3, polars 1.42, seaborn 0.13, statsmodels 0.14, pingouin 0.6, mne 1.12, scipy 1.15, numpy 2.2) and R 4.5 (lme4 1.1, lmerTest 3.1, emmeans 1.11, TripleR 1.5).


## Other repositories
Relevantrepositores, with all the code for the platform, experiment code, data collection, data preprocessing, HPC (High performance computing) feature extraction, and analysis replications,  can be found in the links below:

- DuckSoup : https://github.com/ducksouplab/ducksoup

- Mediapipe plugins : https://github.com/ducksouplab/mp_plugins; 

- Mastok platform : https://github.com/ducksouplab/mastok; 

- Experiment code templates : https://github.com/ducksouplab/experiment_templates; 

- Raw data preprocessing scripts: https://github.com/ducksouplab/prepro

- Face reenactment plugin : https://github.com/ducksouplab/liveportrait_gst

- Mozza plugin : https://github.com/ducksouplab/mozza

- Video analysis repository : https://github.com/Pablo-Arias/video_analysis

- Repository for multimodal analyses in an HPC: https://github.com/Pablo-Arias/hpc_analyses

- Reproduction of case study analyses : https://github.com/Pablo-Arias/ducksoup_methods_paper

