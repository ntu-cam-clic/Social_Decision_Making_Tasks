# This script accompanies the .qsf file for decision-making tasks and serves as an example script to process 
# raw data exported from Qualtrics. You can find a small raw data file named rawDataFromQualtrics.csv in the same folder as this script. 
# You can test the script on this dataset, which contains fake data from 4 participants.
# If you run your own data, ensure that when you download data from Qualtrics, you choose the 'csv' file format and select 'Use numeric values'.
# This script is modified from a more general script for preprocessing both conventional Qualtrics questionnaires and JavaScript tasks. 
# Hence, tasks are sometimes referred to as 'questionnaires'.
# In general, if we extract the information of a variable through Qualtrics' QIDs, we tend to call it a questionnaire item/question, 
# such as the items in the social value orientation (SVO) task and the quiz questions in the prisoner's dilemma(PD) task.
# If we extract the information of a variable through embedded data, we tend to call it a task round, such as the practice and formal 
# rounds of the PD task. You can also check the comments on the variable "Responses_questionnaireQIDList" below for more information.
# If you want to calculate transitivity for the SVO task, you need to have MATLAB and the Bioinformatics toolbox installed. 
# Additionally, you need to add the function file transitivity_check_ranking.m into the MATLAB path.
# If you don't want to run transitivity calculation, you can modify the code.


# by Shengchuang Feng, Mar, 2024

rm(list = ls())
list.of.packages <- c(
 "matlabr",
 "psych",
 "matrixStats",
 "stringr",
  "tidyr",
  "MASS",
  "stringr",
  "logistf")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(matlabr)  # to use R to run MATLAB
library(Rcpp)
library(stringr)
library(matrixStats)
library(tidyr)
library(MASS)
library(psych)
library(logistf)

## values allocated to self and other for each option of the SVO task
SVO_self=list(c(85,85,85,85,85,85,85,85,85),
              c(85,87,89,91,93,94,96,98,100),
              c(50,54,59,63,68,72,76,81,85),
              c(50,54,59,63,68,72,76,81,85),
              c(100,94,88,81,75,69,63,56,50),
              c(100,98,96,94,93,91,89,87,85));
SVO_other=list(c(85,76,68,59,50,41,33,24,15),
               c(15,19,24,28,33,37,41,46,50),
               c(100,98,96,94,93,91,89,87,85),
               c(100,89,79,68,58,47,36,26,15),
               c(50,56,63,69,75,81,88,94,100),
               c(50,54,59,63,68,72,76,81,85));


## full names of questionnaires/tasks
questionnaireFullNames=c('Social Value Orientation (SVO)',
                                  'Prisoner\'s Dilemma-PD',
                                  'Stag Hunt-SH',
                                  'Battle of Sexes-BS',
                                  'Risk Preference (positive domain)-RPp',
                                  'Risk Preference (negative domain)-RPn',
                                  'Risk Preference (mixed domain)-RPm',
                                  'Ambiguity Aversion-AA',
                                  'Risky Dictator-RD',
                                  'Trust Game (with history)-TG',
                                  'Trust Game (no history)-TGnh',
                                  'Trust Game (as Player B)-TGb'
);
## Acronyms of questionnaires/tasks  
questionnaireNames=list(c('SVO'),
                        c('PD'), 
                        c('SH'),
                        c('BS'),
                        c('RPp'),
                        c('RPn'),
                        c('RPm'),
                        c('AA'),
                        c('RD'),
                        c('TG'),
                        c('TGnh'),
                        c('TGb')
);


## QIDs for responses from Qualtrics and customary names for task rounds.
## We use QIDs and customary names to identify each variable.
## Here we list the QIDs for all the questions (including quizzes from some tasks)we want to include in our preprocessed data.
## For the task practice and formal rounds (except SVO), we use customary names in our embedded data to identify them, 
## so here we list sth like ('Prc','1','2','3','4','5'), the acronyms representing specific tasks will be added before the numbers in the following code.
## If you directly import our .qsf file, the following QIDs are still correct. 
## If you create your own project, you need to check if the QIDs are changed for each question.
## For example, the QID for the 1st round of SVO task is "QID290".
Responses_questionnaireQIDList       =list(c(290,292,294,296,298,300), #SVO
                                             list(c('328#1_1','328#1_2','797#1_1','797#1_2','799#1_1','799#1_2',  #these are QIDs of quizzes
                                                    '332#1_1','332#1_2','801#1_1','801#1_2','803#1_1','803#1_2',
                                                    '336#1_1','336#1_2','805#1_1','805#1_2','807#1_1','807#1_2',
                                                    '340#1_1','340#1_2','809#1_1','809#1_2','811#1_1','811#1_2'),
                                                  c('Prc','1','2','3','4','5')),#PD   these are not QIDs, but customary names in the embedded data
                                             list(c('378#1_1','378#1_2','813#1_1','813#1_2','815#1_1','815#1_2',  #these are QIDs of quizzes
                                                    '382#1_1','382#1_2','817#1_1','817#1_2','819#1_1','819#1_2',
                                                    '386#1_1','386#1_2','821#1_1','821#1_2','823#1_1','823#1_2',
                                                    '390#1_1','390#1_2','825#1_1','825#1_2','827#1_1','827#1_2'),
                                                  c('Prc','1','2','3','4','5')),#SH   these are not QIDs, but customary names in the embedded data
                                             list(c('636#1_1','636#1_2','865#1_1','865#1_2','867#1_1','867#1_2',
                                                    '640#1_1','640#1_2','869#1_1','869#1_2','871#1_1','871#1_2',
                                                    '644#1_1','644#1_2','873#1_1','873#1_2','875#1_1','875#1_2',
                                                    '648#1_1','648#1_2','877#1_1','877#1_2','879#1_1','879#1_2'),
                                                  c('Prc','1','2','3','4','5')),#BS   these are not QIDs, but customary names in the embedded data
                                             c('Prc1','Prc2','1','2','3','4','5','6','7','8','9'),#RPp
                                             c('Prc1','Prc2','1','2','3','4','5','6','7','8','9'),#RPn
                                             c('Prc1','Prc2','1','2','3','4','5','6','7','8','9'),#RPm
                                             c('Prc1','Prc2','1','2','3','4','5','6','7','8','9'),#AA
                                             list(c('492#1_1','492#1_2','829#1_1','829#1_2','831#1_1','831#1_2', #these are QIDs of quizzes
                                                    '496#1_1','496#1_2','833#1_1','833#1_2','835#1_1','835#1_2',
                                                    '500#1_1','500#1_2','837#1_1','837#1_2','839#1_1','839#1_2'),
                                                  c('Prc','1','2','3','4','5','6','7','8','9','10')),#RD   customary names in the embedded data
                                             list(c('571#1_1','571#1_2','853#1_1','853#1_2','855#1_1','855#1_2', #these are QIDs of quizzes
                                                    '575#1_1','575#1_2','857#1_1','857#1_2','859#1_1','859#1_2',
                                                    '579#1_1','579#1_2','861#1_1','861#1_2','863#1_1','863#1_2'),
                                                  c('Prc','1','2','3','4','5','6','7','8','9','10')),#TG    customary names in the embedded data
                                             list(c('532#1_1','532#1_2','841#1_1','841#1_2','843#1_1','843#1_2', #these are QIDs of quizzes
                                                    '537#1_1','537#1_2','845#1_1','845#1_2','847#1_1','847#1_2',
                                                    '541#1_1','541#1_2','849#1_1','849#1_2','851#1_1','851#1_2'),
                                                  c('Prc','1','2','3','4','5')),#TGnh   customary names in the embedded data
                                             c('1','3','4','5','6')#TGb   customary names in the embedded data
                                             
); 
## Names assigned to responses; these names are corresponding to the above QIDs and customary names.
Responses_roundLableList         =list(paste0('SVO_Q',sprintf("%03d", c(1:6))),
                                       list(c('PD_QUIZ_Q001_TRY1_1','PD_QUIZ_Q001_TRY1_2','PD_QUIZ_Q001_TRY2_1','PD_QUIZ_Q001_TRY2_2','PD_QUIZ_Q001_TRY3_1','PD_QUIZ_Q001_TRY3_2',
                                              'PD_QUIZ_Q002_TRY1_1','PD_QUIZ_Q002_TRY1_2','PD_QUIZ_Q002_TRY2_1','PD_QUIZ_Q002_TRY2_2','PD_QUIZ_Q002_TRY3_1','PD_QUIZ_Q002_TRY3_2',
                                              'PD_QUIZ_Q003_TRY1_1','PD_QUIZ_Q003_TRY1_2','PD_QUIZ_Q003_TRY2_1','PD_QUIZ_Q003_TRY2_2','PD_QUIZ_Q003_TRY3_1','PD_QUIZ_Q003_TRY3_2',
                                              'PD_QUIZ_Q004_TRY1_1','PD_QUIZ_Q004_TRY1_2','PD_QUIZ_Q004_TRY2_1','PD_QUIZ_Q004_TRY2_2','PD_QUIZ_Q004_TRY3_1','PD_QUIZ_Q004_TRY3_2'),
                                            c('PD_prac','PD_1','PD_2','PD_3','PD_4','PD_5')),
                                       list(c('SH_QUIZ_Q001_TRY1_1','SH_QUIZ_Q001_TRY1_2','SH_QUIZ_Q001_TRY2_1','SH_QUIZ_Q001_TRY2_2','SH_QUIZ_Q001_TRY3_1','SH_QUIZ_Q001_TRY3_2',
                                              'SH_QUIZ_Q002_TRY1_1','SH_QUIZ_Q002_TRY1_2','SH_QUIZ_Q002_TRY2_1','SH_QUIZ_Q002_TRY2_2','SH_QUIZ_Q002_TRY3_1','SH_QUIZ_Q002_TRY3_2',
                                              'SH_QUIZ_Q003_TRY1_1','SH_QUIZ_Q003_TRY1_2','SH_QUIZ_Q003_TRY2_1','SH_QUIZ_Q003_TRY2_2','SH_QUIZ_Q003_TRY3_1','SH_QUIZ_Q003_TRY3_2',
                                              'SH_QUIZ_Q004_TRY1_1','SH_QUIZ_Q004_TRY1_2','SH_QUIZ_Q004_TRY2_1','SH_QUIZ_Q004_TRY2_2','SH_QUIZ_Q004_TRY3_1','SH_QUIZ_Q004_TRY3_2'),
                                            c('SH_prac','SH_1','SH_2','SH_3','SH_4','SH_5')),
                                       list(c('BS_QUIZ_Q001_TRY1_1','BS_QUIZ_Q001_TRY1_2','BS_QUIZ_Q001_TRY2_1','BS_QUIZ_Q001_TRY2_2','BS_QUIZ_Q001_TRY3_1','BS_QUIZ_Q001_TRY3_2',
                                              'BS_QUIZ_Q002_TRY1_1','BS_QUIZ_Q002_TRY1_2','BS_QUIZ_Q002_TRY2_1','BS_QUIZ_Q002_TRY2_2','BS_QUIZ_Q002_TRY3_1','BS_QUIZ_Q002_TRY3_2',
                                              'BS_QUIZ_Q003_TRY1_1','BS_QUIZ_Q003_TRY1_2','BS_QUIZ_Q003_TRY2_1','BS_QUIZ_Q003_TRY2_2','BS_QUIZ_Q003_TRY3_1','BS_QUIZ_Q003_TRY3_2',
                                              'BS_QUIZ_Q004_TRY1_1','BS_QUIZ_Q004_TRY1_2','BS_QUIZ_Q004_TRY2_1','BS_QUIZ_Q004_TRY2_2','BS_QUIZ_Q004_TRY3_1','BS_QUIZ_Q004_TRY3_2'),
                                            c('BS_prac','BS_1','BS_2','BS_3','BS_4','BS_5')),
                                       c('RPp_Prc1','RPp_Prc2','RPp_1','RPp_2','RPp_3','RPp_4','RPp_5','RPp_6','RPp_7','RPp_8','RPp_9'),
                                       c('RPn_Prc1','RPn_Prc2','RPn_1','RPn_2','RPn_3','RPn_4','RPn_5','RPn_6','RPn_7','RPn_8','RPn_9'),
                                       c('RPm_Prc1','RPm_Prc2','RPm_1','RPm_2','RPm_3','RPm_4','RPm_5','RPm_6','RPm_7','RPm_8','RPm_9'),
                                       c('AA_Prc1','AA_Prc2','AA_1','AA_2','AA_3','AA_4','AA_5','AA_6','AA_7','AA_8','AA_9'),
                                       list(c('RD_QUIZ_Q001_TRY1_1','RD_QUIZ_Q001_TRY1_2','RD_QUIZ_Q001_TRY2_1','RD_QUIZ_Q001_TRY2_2','RD_QUIZ_Q001_TRY3_1','RD_QUIZ_Q001_TRY3_2',
                                              'RD_QUIZ_Q002_TRY1_1','RD_QUIZ_Q002_TRY1_2','RD_QUIZ_Q002_TRY2_1','RD_QUIZ_Q002_TRY2_2','RD_QUIZ_Q002_TRY3_1','RD_QUIZ_Q002_TRY3_2',
                                              'RD_QUIZ_Q003_TRY1_1','RD_QUIZ_Q003_TRY1_2','RD_QUIZ_Q003_TRY2_1','RD_QUIZ_Q003_TRY2_2','RD_QUIZ_Q003_TRY3_1','RD_QUIZ_Q003_TRY3_2'),
                                            c('RD_Prc','RD_1','RD_2','RD_3','RD_4','RD_5','RD_6','RD_7','RD_8','RD_9','RD_10')),
                                       list(c('TG_QUIZ_Q001_TRY1_1','TG_QUIZ_Q001_TRY1_2','TG_QUIZ_Q001_TRY2_1','TG_QUIZ_Q001_TRY2_2','TG_QUIZ_Q001_TRY3_1','TG_QUIZ_Q001_TRY3_2',
                                              'TG_QUIZ_Q002_TRY1_1','TG_QUIZ_Q002_TRY1_2','TG_QUIZ_Q002_TRY2_1','TG_QUIZ_Q002_TRY2_2','TG_QUIZ_Q002_TRY3_1','TG_QUIZ_Q002_TRY3_2',
                                              'TG_QUIZ_Q003_TRY1_1','TG_QUIZ_Q003_TRY1_2','TG_QUIZ_Q003_TRY2_1','TG_QUIZ_Q003_TRY2_2','TG_QUIZ_Q003_TRY3_1','TG_QUIZ_Q003_TRY3_2'),
                                            c('TG_Prc','TG_1','TG_2','TG_3','TG_4','TG_5','TG_6','TG_7','TG_8','TG_9','TG_10')),
                                       list(c('TGnh_QUIZ_Q001_TRY1_1','TGnh_QUIZ_Q001_TRY1_2','TGnh_QUIZ_Q001_TRY2_1','TGnh_QUIZ_Q001_TRY2_2','TGnh_QUIZ_Q001_TRY3_1','TGnh_QUIZ_Q001_TRY3_2',
                                              'TGnh_QUIZ_Q002_TRY1_1','TGnh_QUIZ_Q002_TRY1_2','TGnh_QUIZ_Q002_TRY2_1','TGnh_QUIZ_Q002_TRY2_2','TGnh_QUIZ_Q002_TRY3_1','TGnh_QUIZ_Q002_TRY3_2',
                                              'TGnh_QUIZ_Q003_TRY1_1','TGnh_QUIZ_Q003_TRY1_2','TGnh_QUIZ_Q003_TRY2_1','TGnh_QUIZ_Q003_TRY2_2','TGnh_QUIZ_Q003_TRY3_1','TGnh_QUIZ_Q003_TRY3_2'),
                                            c('TGnh_Prc','TGnh_1','TGnh_2','TGnh_3','TGnh_4','TGnh_5')),
                                       c('TGb_1','TGb_3','TGb_4','TGb_5','TGb_6')
);

## QIDs for trial-level timing and count of clicks from Qualtrics; customary names (e.g. ('Prc','1','2','3','4','5')) are listed below for task rounds.
## On Qualtrics, you can add a timing question to your original question, 
## which can record timing info such as when the first and last clicks occur 
## and how many times a participant clicks on that question page, e.g., the QID for the 1st round of SVO task is "QID290"; 
## the QID for the timing info of this question is "QID291_First Click","QID291_Last Click","QID291_Page Submit",and "QID291_Click Count".
TimingClick_questionnaireQIDList        =list(c(291,293,295,297,299,301), #SVO
                                               list(c(329,798,800,   #QIDs of timing questions for quizzes
                                                      333,802,804,
                                                      337,806,808,
                                                      341,810,812),
                                                    c('Prc','1','2','3','4','5')), #PD   these are not QIDs, but customary names in the embedded data
                                               list(c(379,814,816,
                                                      383,818,820,
                                                      387,822,824,
                                                      391,826,828),
                                                    c('Prc','1','2','3','4','5')), #SH
                                               list(c(637,866,868,
                                                      641,870,872,
                                                      645,874,876,
                                                      649,878,880),
                                                    c('Prc','1','2','3','4','5')), #BS
                                               c('Prc1','Prc2','1','2','3','4','5','6','7','8','9'), #RPp
                                               c('Prc1','Prc2','1','2','3','4','5','6','7','8','9'), #RPn
                                               c('Prc1','Prc2','1','2','3','4','5','6','7','8','9'), #RPm
                                               c('Prc1','Prc2','1','2','3','4','5','6','7','8','9'), #AA
                                               list(c(493,830,832,
                                                      497,834,836,
                                                      501,838,840),
                                                    c('Prc','1','2','3','4','5','6','7','8','9','10')), #RD
                                               list(c(572,854,856,
                                                      576,858,860,
                                                      580,862,864),
                                                    c('Prc','1','2','3','4','5','6','7','8','9','10')), #TG
                                               list(c(535,842,844,
                                                      538,846,848,
                                                      542,850,852),
                                                    c('Prc','1','2','3','4','5')), #TGnh
                                               c('1','3','4','5','6') #TGb
);

## Names assigned to timing and count of clicks; these names are corresponding to the above timing QIDs and customary names.
TimingClick_roundLableList    =list(list(c(paste0('SVO_T1_Q',sprintf("%03d", c(1:6)))),
                                              c(paste0('SVO_T2_Q',sprintf("%03d", c(1:6)))),
                                              c(paste0('SVO_T3_Q',sprintf("%03d", c(1:6)))),
                                              c(paste0('SVO_T4_Q',sprintf("%03d", c(1:6))))), #SVO
                                         list(c(paste0('PD_T1_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('PD_T1_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('PD_T1_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('PD_T1_QUIZ_Q004_TRY',c(1:3))),
                                              c(paste0('PD_T2_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('PD_T2_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('PD_T2_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('PD_T2_QUIZ_Q004_TRY',c(1:3))),
                                              c(paste0('PD_T3_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('PD_T3_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('PD_T3_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('PD_T3_QUIZ_Q004_TRY',c(1:3))),
                                              c(paste0('PD_T4_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('PD_T4_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('PD_T4_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('PD_T4_QUIZ_Q004_TRY',c(1:3))),
                                              c('PD_prac','PD_1','PD_2','PD_3','PD_4','PD_5')), #PD
                                         list(c(paste0('SH_T1_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('SH_T1_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('SH_T1_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('SH_T1_QUIZ_Q004_TRY',c(1:3))),
                                              c(paste0('SH_T2_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('SH_T2_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('SH_T2_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('SH_T2_QUIZ_Q004_TRY',c(1:3))),
                                              c(paste0('SH_T3_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('SH_T3_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('SH_T3_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('SH_T3_QUIZ_Q004_TRY',c(1:3))),
                                              c(paste0('SH_T4_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('SH_T4_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('SH_T4_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('SH_T4_QUIZ_Q004_TRY',c(1:3))),
                                              c('SH_prac','SH_1','SH_2','SH_3','SH_4','SH_5')), #SH
                                         list(c(paste0('BS_T1_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('BS_T1_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('BS_T1_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('BS_T1_QUIZ_Q004_TRY',c(1:3))),
                                              c(paste0('BS_T2_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('BS_T2_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('BS_T2_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('BS_T2_QUIZ_Q004_TRY',c(1:3))),
                                              c(paste0('BS_T3_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('BS_T3_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('BS_T3_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('BS_T3_QUIZ_Q004_TRY',c(1:3))),
                                              c(paste0('BS_T4_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('BS_T4_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('BS_T4_QUIZ_Q003_TRY',c(1:3)),
                                                paste0('BS_T4_QUIZ_Q004_TRY',c(1:3))),
                                              c('BS_prac','BS_1','BS_2','BS_3','BS_4','BS_5')), #BS
                                         c('RPp_Prc1','RPp_Prc2','RPp_1','RPp_2','RPp_3','RPp_4','RPp_5','RPp_6','RPp_7','RPp_8','RPp_9'), #RPp
                                         c('RPn_Prc1','RPn_Prc2','RPn_1','RPn_2','RPn_3','RPn_4','RPn_5','RPn_6','RPn_7','RPn_8','RPn_9'), #RPn
                                         c('RPm_Prc1','RPm_Prc2','RPm_1','RPm_2','RPm_3','RPm_4','RPm_5','RPm_6','RPm_7','RPm_8','RPm_9'), #RPm
                                         c('AA_Prc1','AA_Prc2','AA_1','AA_2','AA_3','AA_4','AA_5','AA_6','AA_7','AA_8','AA_9'), #AA
                                         list(c(paste0('RD_T1_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('RD_T1_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('RD_T1_QUIZ_Q003_TRY',c(1:3))),
                                              c(paste0('RD_T2_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('RD_T2_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('RD_T2_QUIZ_Q003_TRY',c(1:3))),
                                              c(paste0('RD_T3_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('RD_T3_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('RD_T3_QUIZ_Q003_TRY',c(1:3))),
                                              c(paste0('RD_T4_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('RD_T4_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('RD_T4_QUIZ_Q003_TRY',c(1:3))),
                                              c('RD_Prc','RD_1','RD_2','RD_3','RD_4','RD_5','RD_6','RD_7','RD_8','RD_9','RD_10')), #RD
                                         list(c(paste0('TG_T1_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('TG_T1_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('TG_T1_QUIZ_Q003_TRY',c(1:3))),
                                              c(paste0('TG_T2_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('TG_T2_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('TG_T2_QUIZ_Q003_TRY',c(1:3))),
                                              c(paste0('TG_T3_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('TG_T3_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('TG_T3_QUIZ_Q003_TRY',c(1:3))),
                                              c(paste0('TG_T4_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('TG_T4_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('TG_T4_QUIZ_Q003_TRY',c(1:3))),
                                              c('TG_Prc','TG_1','TG_2','TG_3','TG_4','TG_5','TG_6','TG_7','TG_8','TG_9','TG_10')), #TG
                                         list(c(paste0('TGnh_T1_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('TGnh_T1_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('TGnh_T1_QUIZ_Q003_TRY',c(1:3))),
                                              c(paste0('TGnh_T2_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('TGnh_T2_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('TGnh_T2_QUIZ_Q003_TRY',c(1:3))),
                                              c(paste0('TGnh_T3_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('TGnh_T3_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('TGnh_T3_QUIZ_Q003_TRY',c(1:3))),
                                              c(paste0('TGnh_T4_QUIZ_Q001_TRY',c(1:3)),
                                                paste0('TGnh_T4_QUIZ_Q002_TRY',c(1:3)),
                                                paste0('TGnh_T4_QUIZ_Q003_TRY',c(1:3))),
                                              c('TGnh_Prc','TGnh_1','TGnh_2','TGnh_3','TGnh_4','TGnh_5')), #TGnh
                                         c('TGb_1','TGb_3','TGb_4','TGb_5','TGb_6') #TGb
);

## questionnaire-level variables that will be saved in the preprocessed data files 
questionnaireLevelVariables         =list(c('SVO_SCORE','SVO_transitivity','SVO_MISS'),
                                          c('PD_SCORE','PD_MISS'),
                                          c('SH_SCORE','SH_MISS'),
                                          c('BS_SCORE','BS_MISS'),
                                          c('RPp_SCORE','RPp_MISS'),
                                          c('RPn_SCORE','RPn_MISS'),
                                          c('RPm_SCORE','RPm_MISS'),
                                          c('AA_SCORE','AA_MISS'),
                                          c('RD_SCORE','RD_MISS'),
                                          c('TG_SCORE','TG_MISS'),
                                          c('TGnh_SCORE','TGnh_MISS'),
                                          c('TGb_SCORE','TGb_MISS')
);

## 0= a task with no Javascript;
## 1= a task with only Javascript round code; 
## 2= a task with both QID and Javascript round code; 
questionnaireTaskList         =list(c(0), #SVO
                                    c(2), #PD
                                    c(2), #SH
                                    c(2), #BS
                                    c(1), #RPp
                                    c(1), #RPn
                                    c(1), #RPm
                                    c(1), #AA
                                    c(2), #RD
                                    c(2), #TG
                                    c(2), #TGnh
                                    c(1)  #TGb
);

## You can modify the directory in this script or manually create/arrange the folders so that
## data are in folder "preprocessedData"; scripts are in folder "scripts"
## Please also put the MATLAB function: transitivity_check_ranking.m in the Scripts folder. 
## This function can be found here (http://ryanomurphy.com/resources/SVO_Slider.m)

myPath='D:/example_Code_Data_Preprocessing/';
rawDataPath = 'rawData/';
preprocessedDataPath = 'preprocessedData/';
matlabPath="C:/Program\ Files/MATLAB/R2017b/bin"; # The path to MATLAB application; Please make sure the Bioinformatics toolbox is installed.
                                                  # We'll use MATLAB to calculate the transitivity for social value orientation (http://ryanomurphy.com/styled-2/styled-4/index.html); 

setwd(paste0(myPath,rawDataPath));  # set the working directory
rawdata = read.csv('rawDataFromQualtrics.csv',check.names=FALSE);  # load the data from one Qualtrics account,check.names=FALSE to keep space in names
alldata=rbind(rawdata[-c(1,2), ])  # delete the extra column that we don't need


IDtoExclude=c(000); #We can specify the participants we want to exclude, keep 0 here if no participants to exclude
for (m in c(1:length(IDtoExclude))){
  alldata=alldata[alldata$PID!=IDtoExclude[m],]
}

lengthData=dim(alldata)[1];
PID=as.integer(alldata$QID277); #You need to check if the QID is changed for each question.
numsub=length(PID); # number of participants
subLable=paste('sub',PID); #label of subjects

#####################################################################################################################
############################################ loop through questionnaires/tasks ############################################
##################################################################################################################### 

loopStart=1;
loopEnd=length(questionnaireNames);
for (t in c(loopStart:loopEnd)) {  # t is for the order of a questionnaire.
  print(paste("####################################",t,questionnaireFullNames[t],"#################################################"))
  # For each questionnaire(here referred to SVO and some quiz questions). First construct matrices for trial-level responses, timing info and click counts
  Responses_oneQuestionnaire_allSub=c(); # matrix of responses for one questionnaire and all participants
  FirstClick_oneQuestionnaire_allSub=c(); # matrix of first click timing for one questionnaire and all participants
  LastClick_oneQuestionnaire_allSub=c(); # matrix of last click timing for one questionnaire and all participants
  PageSubmit_oneQuestionnaire_allSub=c(); # matrix of page submit timing for one questionnaire and all participants
  CountClick_oneQuestionnaire_allSub=c(); # matrix of count of clicks for one questionnaire and all participants
  
  # For each task. First construct matrices for trial-level responses and timing info
  Responses_oneTask_allSub=c(); # matrix of responses for one questionnaire and all participants
  OutcomeSelf_oneTask_allSub=c(); # matrix of outcome for self for one task and all participants
  OutcomeOther_oneTask_allSub=c(); # matrix of outcome for other for one task and all participants
  RT_oneTask_allSub=c(); # matrix of response time for one task and all participants
  
  ############################ for tasks with QIDs (see comments about "Responses_questionnaireQIDList" above)
  if (unlist(questionnaireTaskList[t])[1]==0 || unlist(questionnaireTaskList[t])[1]==2 ) {  # if this task has QIDs (see "Responses_questionnaireQIDList" above)
    
          for  (QID_suffix in c('','_First Click','_Last Click','_Page Submit','_Click Count')) { 
            
            if (QID_suffix=='') {  questionnaireQIDList=Responses_questionnaireQIDList; roundLableList=Responses_roundLableList;# QID for responses
            }else {  questionnaireQIDList=TimingClick_questionnaireQIDList;  roundLableList=TimingClick_roundLableList;         # QID for timing and click count
            } 
            
            
            roundLable=unlist(roundLableList[t]);
            if (unlist(questionnaireTaskList[t])[1]==2) {
              questionnaireRoundQID=unlist(unlist(questionnaireQIDList[t],recursive=F)[1]); # if this is a task with both QID and Javascript round codes
            }else {    questionnaireRoundQID=unlist(questionnaireQIDList[t],recursive=F);
            }
            
            
            if (length(roundLable)==0){next}  # skip the set of variables with no clicks
            
            ################################# extract content for each round ########################
            questionnaire_roundInfo_mat=c();
            
            for (i in c(1:length(questionnaireRoundQID))) {    # i is for rounds
              roundInfo=eval(parse(text=paste0('alldata$\'QID',questionnaireRoundQID[i],QID_suffix,'\'[1:lengthData]')));   # answers/timing from all participants of one question;conversion of string to expression
              roundInfo[roundInfo==""]=NA;
              roundInfo=as.numeric(roundInfo);
              questionnaire_roundInfo_mat=cbind(questionnaire_roundInfo_mat,roundInfo);
            } #end of round loop
            if (QID_suffix=='') {  Responses_oneQuestionnaire_allSub=questionnaire_roundInfo_mat;
            }else if (QID_suffix=='_First Click') {  FirstClick_oneQuestionnaire_allSub=questionnaire_roundInfo_mat;
            }else if (QID_suffix=='_Last Click') {   LastClick_oneQuestionnaire_allSub=questionnaire_roundInfo_mat;
            }else if (QID_suffix=='_Page Submit') {   PageSubmit_oneQuestionnaire_allSub=questionnaire_roundInfo_mat;
            }else if (QID_suffix=='_Click Count') {   CountClick_oneQuestionnaire_allSub=questionnaire_roundInfo_mat;}
            
          } # end of different measures: choices, response time, and count of clicks
          
          ###########################################################
          ###   Checking very short RT for Qualtrics questions ######
          ###########################################################
          ## This part checks if the RTs are too short for some questions with Qualtrics timing (SVO rounds and quizzes).
          ## If the RT is too fast for a page, we will set the response(s) on this page as NAs, and they are treated as missing.
          ## In the preprocessed CSV files, we still show the original responses, but the 20% missing filter may indicate that more than
          ## 20% data (formal rounds) are missing for this task. 
          nameStrings=unlist(questionnaireLevelVariables[t]); # strings of variable names
      
          DurationMeasure=LastClick_oneQuestionnaire_allSub
          Responses_oneQuestionnaire_allSub_raw=Responses_oneQuestionnaire_allSub; # Here keep the original raw scores using a different variable
          
          BadcaseIdx=rep(0,each=numsub);
          for (numRT in c(1:dim(DurationMeasure)[2])){
              log_RT=log(DurationMeasure[,numRT]);
              #convert -inf into 0
              for (i in c(1:length(log_RT))){log_RT[is.infinite(log_RT[i])]=0}
              negaSD=mean(log_RT,na.rm=TRUE)-2.5*sd(log_RT,na.rm=TRUE)
              if (dim(DurationMeasure)[2]==1){                        # If multiple rounds/items on one page
                Responses_oneQuestionnaire_allSub[log_RT<negaSD,]=NA; # assign NAs to rounds on this page
              }else {Responses_oneQuestionnaire_allSub[log_RT<negaSD,numRT]=NA; # assign NAs to the round on this page
              }
              myIdx=log_RT<negaSD;  # Index showing which log(RT)s are too low
              myIdx[is.na(myIdx)]=0; # NAs converted to 0
              
              BadcaseIdx=BadcaseIdx+(myIdx);  # the index is to indicate any fast response in any trial
            }
            Badcase_dura=rep(0,each=numsub);    # this filter for all tasks except SVO will be replaced by the same variable that appears later.
            Badcase_dura[BadcaseIdx>=1]=1;      # Participant with very short RT in any round/question will be printed in the console
            print('Participants with short RT (only for SVO rounds and quizzes of other tasks):');
            print(PID[BadcaseIdx>=1]);
          ###############################################################
    
  }  # end of if this task has QIDs
  
  ############################ for tasks with JavaScript (see comments about "Responses_questionnaireQIDList" above)
  if (unlist(questionnaireTaskList[t])[1]==1 || unlist(questionnaireTaskList[t])[1]==2) {  # if this is a task with JavaScript
       
          for  (roundStr in c('buttonClick','OutcomeSelf','OutcomeOther','buttonTime')) {   # loop through different measures: choices, response time, and outcomes
            
            if (roundStr=='buttonClick' || roundStr=='OutcomeSelf' || roundStr=='OutcomeOther') {  questionnaireQIDList=Responses_questionnaireQIDList; roundLableList=Responses_roundLableList;# QID for responses
            }else {  questionnaireQIDList=TimingClick_questionnaireQIDList;  roundLableList=TimingClick_roundLableList;         # QID for timing and click count
            } 
            
            roundLable=unlist(roundLableList[t]);
            if (unlist(questionnaireTaskList[t])[1]==2) {questionnaireRoundJS=unlist(unlist(questionnaireQIDList[t],recursive=F)[2]);# if this is a task with both QID and Javascript round codes
            }else {questionnaireRoundJS=unlist(questionnaireQIDList[t]); # if this is a task with only Javascript round codes
            }
            
            game_roundInfo_mat=c();
            for (m in 1:numsub) {   #number of subjects
              
              #######names and values of tasks
              gameVarNames=alldata$all_variableNames[m];  # all_variableNames and all_variableValues are embedded data from Qualtrics
              gameVarValues=alldata$all_variableValues[m]; 
              
              newVarNamesStr=substring(gameVarNames, 2); #delete the 1st character which is empty
              newVarValuesStr=substring(gameVarValues, 2); #delete the 1st character
              
              newVarNames=unlist(strsplit(newVarNamesStr, split=","))
              newVarValues=unlist(strsplit(newVarValuesStr, split=","))
              newVarValues=as.numeric(newVarValues)
              ################################# reading round information from JavaScriot ###############################
              
              roundInfo_mat=c();
              for (i in c(1:length(questionnaireRoundJS))) {    # i is for rounds
                roundInfo=unique(newVarValues[str_detect(newVarNames,paste0(questionnaireNames[t],'_',roundStr,'_round',questionnaireRoundJS[i]))]); 
                roundInfo[roundInfo==""]=NA;
                roundInfo=as.numeric(roundInfo); 
                
                if (roundStr=='buttonTime') {  # if need to calculate response time
                  pageloadTime=unique(newVarValues[str_detect(newVarNames,paste0(questionnaireNames[t],'_','PageLoad','_round',questionnaireRoundJS[i]))]);
                  roundInfo=(roundInfo-pageloadTime)/1000;
                }
                
                roundInfo_mat=cbind(roundInfo_mat,roundInfo[order(roundInfo,na.last=TRUE)][1]);  # if participants click "Cancel" when not finishing all questions, round info will be NA
                # here sort to extract the non_NA info
              } #end of round loop
              
              game_roundInfo_mat=rbind(game_roundInfo_mat,roundInfo_mat);
            } # end of sub loop
            
            if (roundStr=='buttonClick')       { Responses_oneTask_allSub=abs(game_roundInfo_mat-2);
            }else if (roundStr=='OutcomeSelf') { OutcomeSelf_oneTask_allSub=game_roundInfo_mat;
            }else if (roundStr=='OutcomeOther') { OutcomeOther_oneTask_allSub=game_roundInfo_mat;
            }else if (roundStr=='buttonTime') {RT_oneTask_allSub=game_roundInfo_mat;}
          } # end of for loop

          ###########################################################
          ###   Checking very short RTs for JavaScript questions ######
          ###########################################################
          ## This part checks if the RTs are too short for some questions coded with JavaScript (formal rounds of tasks except SVO).
          ## If the RT is too fast for a page, we will set the response(s) on this page as NAs, and they are treated as missing.
          ## In the preprocessed CSV files, we still show the original responses, but the 20% missing filter may indicate that more than
          ## 20% data (formal rounds) are missing for this task. 
          nameStrings=unlist(questionnaireLevelVariables[t]); # strings of variable names
                    
          Responses_oneTask_allSub_raw=Responses_oneTask_allSub; # Here keep the original raw scores using a different variable
          # We will use this raw scores variable to construct the preprocessed data file. 
   
          # for tasks with multiple rounds on one page, use the timing for the last click on that page
          if (sum(str_detect(nameStrings,'RPp_')) 
              || sum(str_detect(nameStrings,'RPn_')) 
              || sum(str_detect(nameStrings,'RPm_')) 
              || sum(str_detect(nameStrings,'AA_'))
              || sum(str_detect(nameStrings,'TGnh_')) 
              || sum(str_detect(nameStrings,'TG_'))
              || sum(str_detect(nameStrings,'RD_')) ){
            DurationMeasure=as.matrix(RT_oneTask_allSub[,dim(RT_oneTask_allSub)[2]]);
          } else if (sum(str_detect(nameStrings,'PD_')) 
                     || sum(str_detect(nameStrings,'SH_')) 
                     || sum(str_detect(nameStrings,'BS_')) 
                     || sum(str_detect(nameStrings,'TGnh_'))){
            DurationMeasure=RT_oneTask_allSub[,c(2:6)];
          }else{
            DurationMeasure=RT_oneTask_allSub;
          }
          
          BadcaseIdx=rep(0,each=numsub);
          for (numRT in c(1:dim(DurationMeasure)[2])){
            log_RT=log(DurationMeasure[,numRT]); # logarithm of response time
            for (i in c(1:length(log_RT))){log_RT[is.infinite(log_RT[i])]=0};#It is possible to have log(0), convert any -inf into 0
            negaSD=mean(log_RT,na.rm=TRUE)-2.5*sd(log_RT,na.rm=TRUE); # lower threshold for the filter
            if (dim(DurationMeasure)[2]==1){                        # If multiple rounds/items on one page
              Responses_oneTask_allSub[log_RT<negaSD,]=NA; # assign NAs to rounds on this page, so they will be ignored in the calculation of sum/average scores
            }else {Responses_oneTask_allSub[log_RT<negaSD,numRT]=NA; # assign NAs to the round on this page
            }
            myIdx=log_RT<negaSD;  # Index showing which log(RT)s are too low
            myIdx[is.na(myIdx)]=0; # NAs converted to 0
            
            BadcaseIdx=BadcaseIdx+(myIdx);  # the index is to indicate any fast response in any trial
          }
          Badcase_dura=rep(0,each=numsub);    # this filter for all tasks except SVO will be replaced by the same variable that appears later.
          Badcase_dura[BadcaseIdx>=1]=1;      # Participant with very short RT in any round/question will be printed in the console
          print('Participants with short RT (In formal rounds of tasks except SVO):');
          print(PID[BadcaseIdx>=1]);
          ###############################################################
  } # end of if this is a task with JavaScript
  
  
  #Now you have matrices for each task (subjects by rounds); you can do whatever tests/calculations you want
  ###%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  # Here loop through subjects to calculate scores for the task
  Responses_oneQuestionnaire_scoresTASK_allSub=c(); # scores for decision making tasks
  for (sub in c(1:numsub)) { 
    Responses_oneQuestionnaire_oneSub=Responses_oneQuestionnaire_allSub[sub,];
    
    if (unlist(questionnaireNames[t])[1]=="SVO"){
      OutcomesSelf= c(unlist(SVO_self[1])[Responses_oneQuestionnaire_oneSub[1]],
                      unlist(SVO_self[2])[Responses_oneQuestionnaire_oneSub[2]],
                      unlist(SVO_self[3])[Responses_oneQuestionnaire_oneSub[3]],
                      unlist(SVO_self[4])[Responses_oneQuestionnaire_oneSub[4]],
                      unlist(SVO_self[5])[Responses_oneQuestionnaire_oneSub[5]],
                      unlist(SVO_self[6])[Responses_oneQuestionnaire_oneSub[6]]);
      OutcomesOther= c(unlist(SVO_other[1])[Responses_oneQuestionnaire_oneSub[1]],
                       unlist(SVO_other[2])[Responses_oneQuestionnaire_oneSub[2]],
                       unlist(SVO_other[3])[Responses_oneQuestionnaire_oneSub[3]],
                       unlist(SVO_other[4])[Responses_oneQuestionnaire_oneSub[4]],
                       unlist(SVO_other[5])[Responses_oneQuestionnaire_oneSub[5]],
                       unlist(SVO_other[6])[Responses_oneQuestionnaire_oneSub[6]])
      
      meanOther=mean(OutcomesOther);
      meanSelf= mean(OutcomesSelf);
      
      SVO=atan((meanOther-50)/(meanSelf-50));    # transitivity is tested using MATLAB in the following section
      Responses_oneQuestionnaire_scoresTASK_allSub=rbind(Responses_oneQuestionnaire_scoresTASK_allSub,SVO);  # score for all subjects
      
    }else if(unlist(questionnaireNames[t])[1]=="RPp" || unlist(questionnaireNames[t])[1]=="RPn" || unlist(questionnaireNames[t])[1]=="RPm"   || unlist(questionnaireNames[t])[1]=="AA"){ 
      if (unlist(questionnaireNames[t])[1]=="RPm") {temp_regDV=Responses_oneTask_allSub[sub,c(11:3)];} #  reverse the order to make the RPm consistent to RPp and RPn
      }else {temp_regDV=Responses_oneTask_allSub[sub,c(3:11)]; }  # formal rounds (10% to 90% for the risky option)
      regDV=na.omit(temp_regDV);  ## Left is better initially (left=1, right =0) 
      if (length(regDV) <9){switchPoint=NA;  #remove this participant if there is missing value
      }else {
        regIV=sequence(length(regDV));
        regData=data.frame(IV=regIV,DV=regDV);
        model = logistf(DV ~ IV,data=regData)   #use logit regression to estimate the switching point.
        # summary(model)
        slope=as.numeric(model$coefficients[2]);
        intercept=as.numeric(model$coefficients[1]);
        if (slope<0) {                                 # slope should be negative since left is better initially
          switchPoint= (0.5-intercept)/slope;
          # multiple switching may make the estimated value out of the actual range of rounds, here bound the values
          if (switchPoint>=8 & switchPoint<=20) {
            switchPoint=8;
          }else if (switchPoint>=-10 & switchPoint<=1) {
            switchPoint=1;
          }else if (switchPoint>20 | switchPoint< -10){ # estimated values out of this range may suggest symmetric choice patterns, like this [1 1 0 0 0 0 0 1 1]
            print(paste0(toString(subID[sub]),": switchPoint=",toString(switchPoint)));
            print(regData$DV);
            switchPoint=NA;
          } #end of bounding switching point values 
        } else {switchPoint=NA;
        } #end of checking slope
      } #end of checking number of rounds
      #in the next line convert to integer to represent the switching point.
      Responses_oneQuestionnaire_scoresTASK_allSub=rbind(Responses_oneQuestionnaire_scoresTASK_allSub,round(switchPoint));
    }else if(unlist(questionnaireNames[t])[1]=="RD" || unlist(questionnaireNames[t])[1]=="TG" ){  
      temp_regDV=Responses_oneTask_allSub[sub,c(2:11)];   ##formal rounds (the last round is for sanity check, where both options are safe)
      
      regDV=na.omit(temp_regDV);  ## Left is better initially (left=1, right =0) 
      if (length(regDV) <10 | regDV[10]==1){switchPoint=NA; #removed this participant if there is missing value or they chose the worse option in the last round
      }else {
        regIV=sequence(length(regDV[1:9])); # to make the estimated values comparable with other games with 9 rounds
        regData=data.frame(IV=regIV,DV=regDV[1:9]);
        model = logistf(DV ~ IV,data=regData)   #use logit regression to estimate the switching point.
        # summary(model)
        slope=as.numeric(model$coefficients[2]);
        intercept=as.numeric(model$coefficients[1]);
        if (slope<0) {                                 # slope should be negative since left is better initially
          switchPoint= (0.5-intercept)/slope;
          # multiple switching may make the estimated value out of the actual range of rounds, here bound the values
          if (switchPoint>=8 & switchPoint<=20) {
            switchPoint=8;
          }else if (switchPoint>=-10 & switchPoint<=1) {
            switchPoint=1;
          }else if (switchPoint>20 | switchPoint< -10){ # estimated values out of this range may suggest symmetric choice patterns, like this [1 1 0 0 0 0 0 1 1]
            print(paste0(toString(subID[sub]),": switchPoint=",toString(switchPoint)));
            print(regData$DV);
            switchPoint=NA;
          } #end of bounding switching point values 
        } else {switchPoint=NA;
        } #end of checking slope
      } #end of checking number of rounds
      #in the next line convert to integer to represent the switching point.
      Responses_oneQuestionnaire_scoresTASK_allSub=rbind(Responses_oneQuestionnaire_scoresTASK_allSub,round(switchPoint));
    } # end of different tasks
  } # end of subjects for loop
    
  ###%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  # set a filter for 20% missing data by task for the participant. Note that rounds removed due to fast RT also count as missing.
  nameStrings=unlist(questionnaireLevelVariables[t]); # strings of variable names
  if (sum(str_detect(nameStrings,'PD_')) || sum(str_detect(nameStrings,'SH_')) || sum(str_detect(nameStrings,'BS_')) || sum(str_detect(nameStrings,'TGnh_')) ){
    oneQuestionnaire_MISS=((rowSums(is.na(Responses_oneTask_allSub[,c(2:6)]))/5)> 0.2)*1;
  } else if (sum(str_detect(nameStrings,'RPp_')) || sum(str_detect(nameStrings,'RPn_')) || sum(str_detect(nameStrings,'RPm_')) || sum(str_detect(nameStrings,'AA_')) ){
    oneQuestionnaire_MISS=((rowSums(is.na(Responses_oneTask_allSub[,c(3:11)]))/9)> 0.2)*1;
  } else if (sum(str_detect(nameStrings,'RD_')) || sum(str_detect(nameStrings,'TG_')) ){
    oneQuestionnaire_MISS=((rowSums(is.na(Responses_oneTask_allSub[,c(2:11)]))/10)> 0.2)*1;
  } else if (sum(str_detect(nameStrings,'TGb_')) ){
    oneQuestionnaire_MISS=((rowSums(is.na(Responses_oneTask_allSub))/5)> 0.2)*1;
  } else {oneQuestionnaire_MISS=((rowSums(is.na(Responses_oneQuestionnaire_allSub))/dim(Responses_oneQuestionnaire_allSub)[2])> 0.2)*1;}
  
  ###################################################################################################################
  ##Here deal with different questionnaires/tasks accordingly
  if (sum(str_detect(nameStrings,'PD_')) || sum(str_detect(nameStrings,'SH_')) || sum(str_detect(nameStrings,'BS_')) || 
      sum(str_detect(nameStrings,'TGnh_'))  ){
    tempResponse=Responses_oneTask_allSub[,c(2:6)];
    oneQuestionnaire_scores=rowMeans(tempResponse,na.rm=T);
    
    response_mat=cbind(Responses_oneTask_allSub_raw,
                       RT_oneTask_allSub,
                       OutcomeSelf_oneTask_allSub,
                       OutcomeOther_oneTask_allSub,
                       Responses_oneQuestionnaire_allSub_raw);
    response_mat_names=c(paste0(unlist(unlist(Responses_roundLableList[t],recursive=F)[2],recursive=F),''),
                         paste0(unlist(unlist(TimingClick_roundLableList[t],recursive=F)[5],recursive=F),'_RT'),  # response time
                         paste0(unlist(unlist(TimingClick_roundLableList[t],recursive=F)[5],recursive=F),'_SelfOutcome'),  # outcome for self
                         paste0(unlist(unlist(TimingClick_roundLableList[t],recursive=F)[5],recursive=F),'_OtherOutcome'),  # Outcome for other
                         paste0(unlist(unlist(Responses_roundLableList[t],recursive=F)[1],recursive=F),''));  # responses in quizzes
    
  }else if (sum(str_detect(nameStrings,'RPp_')) || sum(str_detect(nameStrings,'RPn_')) || sum(str_detect(nameStrings,'RPm_')) || sum(str_detect(nameStrings,'AA_'))  ){
    oneQuestionnaire_scores=Responses_oneQuestionnaire_scoresTASK_allSub;
    
    response_mat=cbind(Responses_oneTask_allSub_raw,
                       RT_oneTask_allSub,
                       OutcomeSelf_oneTask_allSub);
    response_mat_names=c(paste0(unlist(Responses_roundLableList[t]),''),
                         paste0(unlist(TimingClick_roundLableList[t]),'_RT'),  # response time
                         paste0(unlist(TimingClick_roundLableList[t]),'_SelfOutcome')); 
  }else if (sum(str_detect(nameStrings,'TGb_')) ){
    oneQuestionnaire_scores=rowMeans(Responses_oneTask_allSub,na.rm=T);
    
    response_mat=cbind(Responses_oneTask_allSub_raw,
                       RT_oneTask_allSub,
                       OutcomeSelf_oneTask_allSub, # since participant is in the role of Player B, this "OutcomeSelf" is actually for the opponent.
                       OutcomeOther_oneTask_allSub);
    response_mat_names=c(paste0(unlist(Responses_roundLableList[t]),''),
                         paste0(unlist(TimingClick_roundLableList[t]),'_RT'),  # response time
                         paste0(unlist(TimingClick_roundLableList[t]),'_OtherOutcome'), # outcome for other 
                         paste0(unlist(TimingClick_roundLableList[t]),'_SelfOutcome'));  # outcome for self
    
  } else if (sum(str_detect(nameStrings,'RD_')) || sum(str_detect(nameStrings,'TG_'))){
    oneQuestionnaire_scores=Responses_oneQuestionnaire_scoresTASK_allSub;
    
    response_mat=cbind(Responses_oneTask_allSub_raw,
                       RT_oneTask_allSub,
                       OutcomeSelf_oneTask_allSub,
                       OutcomeOther_oneTask_allSub,
                       Responses_oneQuestionnaire_allSub_raw);
    response_mat_names=c(paste0(unlist(unlist(Responses_roundLableList[t],recursive=F)[2],recursive=F),''),
                         paste0(unlist(unlist(TimingClick_roundLableList[t],recursive=F)[5],recursive=F),'_RT'),  # response time
                         paste0(unlist(unlist(TimingClick_roundLableList[t],recursive=F)[5],recursive=F),'_SelfOutcome'),  # response time
                         paste0(unlist(unlist(TimingClick_roundLableList[t],recursive=F)[5],recursive=F),'_OtherOutcome'),  # response time
                         paste0(unlist(unlist(Responses_roundLableList[t],recursive=F)[1],recursive=F),''));  # responses in quizes
  } else if (sum(str_detect(nameStrings,'SVO_'))){
    Responses_oneQuestionnaire_allSub[is.na(Responses_oneQuestionnaire_allSub)]=NaN;
    
    ## call MATLAB to calculate transitivity for SVO choices (transitive = 1; intransitive = 0) for all participants
    if (1) {  # set this to 1 if transitivity hasn't been calculated and the file tempSVO.txt hasn't been updated
      options(matlab.path =matlabPath); # where MATLAB application is
      have_matlab()
      matlabcode = c(paste0("cd('",myPath,"Scripts');"),  # the directory for the matlab function: transitivity_check_ranking.m (http://ryanomurphy.com/styled-2/styled-4/index.html)
                     paste0('SVO_self=',rmat_to_matlab_mat(t(matrix(unlist(SVO_self), nrow = 9)), matname = NULL, transpose = FALSE)),
                     paste0('SVO_other=',rmat_to_matlab_mat(t(matrix(unlist(SVO_other), nrow = 9)), matname = NULL, transpose = FALSE)),
                     paste0('response_data=',rmat_to_matlab_mat(Responses_oneQuestionnaire_allSub, matname = NULL, transpose = FALSE)),
                     'alltransitivity=[]; % transitivity for all participants',
                     'for i=1:size(response_data,1)',
                     'mySVO=response_data(i,:);',
                     'if sum(isnan(mySVO)) >0;',
                     'transitivity=NaN;',
                     'else',
                     'mySVOdata=[SVO_self(1,mySVO(1)),SVO_other(1,mySVO(1));',
                     'SVO_self(2,mySVO(2)),SVO_other(2,mySVO(2));',
                     'SVO_self(3,mySVO(3)),SVO_other(3,mySVO(3));',
                     'SVO_self(4,mySVO(4)),SVO_other(4,mySVO(4));',
                     'SVO_self(5,mySVO(5)),SVO_other(5,mySVO(5));',
                     'SVO_self(6,mySVO(6)),SVO_other(6,mySVO(6))]',
                     '[transitivity, ranking_out]= transitivity_check_ranking(mySVOdata);',
                     'end',
                     'alltransitivity=[alltransitivity;transitivity];',
                     'end',
                     paste0("cd('",myPath,preprocessedDataPath,"');"),                  
                     "save('tempSVO.txt', 'alltransitivity', '-ascii');"
      );  # this is equivalent to a matlab script
      run_matlab_code(matlabcode, desktop = F, splash = F, display = T);
    } #end of if
    SVO_transitivity_allSub=  read.table(paste0(myPath,"/preprocessedData/tempSVO.txt")); # This is transitivity indices for all participants; 1 means transitivity; generated by the above matlab script
    oneQuestionnaire_scores=cbind(Responses_oneQuestionnaire_scoresTASK_allSub, SVO_transitivity_allSub);
    
    response_mat=Responses_oneQuestionnaire_allSub_raw;
    response_mat_names=unlist(Responses_roundLableList[t]);
  } #end of if for different tasks
  
  ################# This section reverses the direction of some variables to make them measure cooperation or risk preference ######################
  if (sum(str_detect(nameStrings,'TG_')) | sum(str_detect(nameStrings,'RD_'))){
    oneQuestionnaire_scores=9-oneQuestionnaire_scores;  # trust preference for TG; risk preference for RD
  } else if (sum(str_detect(nameStrings,'TGnh_')) | sum(str_detect(nameStrings,'BS_'))){
    oneQuestionnaire_scores=1-oneQuestionnaire_scores;   # trusting choices for TGnh; Cooperative choices for BS
  } else if (sum(str_detect(nameStrings,'RPp_')) | sum(str_detect(nameStrings,'RPn_')) | sum(str_detect(nameStrings,'RPm_'))){
    oneQuestionnaire_scores=9-oneQuestionnaire_scores;   # risk preference
  }
  
  
  #######################################
  
  ## combine participant IDs, calculated scores, filters and raw scores of responses, timing, and count of clicks
  Mat=cbind(PID,
            oneQuestionnaire_scores,
            Badcase_dura,      #very fast responses, log(RT)<2.5SD
            oneQuestionnaire_MISS,
            response_mat, # these are raw scores
            FirstClick_oneQuestionnaire_allSub,
            LastClick_oneQuestionnaire_allSub,
            PageSubmit_oneQuestionnaire_allSub,
            CountClick_oneQuestionnaire_allSub); 
  ## assign names to these variables
  
  
  myMatNames         = c('PID',
                         head(nameStrings,-1), # delete the last column (Now it has the score and transitivity(SVO) for this task.)See "questionnaireLevelVariables".
                         paste0('Badcase_dura_',questionnaireNames[t]),
                         nameStrings[str_detect(nameStrings,'_MISS')],
                         response_mat_names,
                         paste0(unlist(unlist(TimingClick_roundLableList[t],recursive=F)[1],recursive=F),'_FirstClick'),
                         paste0(unlist(unlist(TimingClick_roundLableList[t],recursive=F)[2],recursive=F),'_LastClick'),
                         paste0(unlist(unlist(TimingClick_roundLableList[t],recursive=F)[3],recursive=F),'_PageSubmit'),
                         paste0(unlist(unlist(TimingClick_roundLableList[t],recursive=F)[4],recursive=F),'_CountClick'));
  colnames(Mat) = myMatNames[1:dim(Mat)[2]]; 
  #Generate preprocessed files for each questionnaire
  write.matrix(format(Mat, scientific=FALSE), 
               file = paste0(myPath,preprocessedDataPath,questionnaireNames[t],".csv"), sep=",");
  
} # end of questionnaires/tasks


