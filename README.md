# Implementation of Decision-Making Tasks on Qualtrics

Scripts and images for implementing the following 12 decision-making tasks on Qualtrics.
We also share scripts for preprocessing the raw data from these task (e.g., calculating scores for each task and each participant).


## Social decision-making tasks
* Risk preference task (positive domain; **PRp**)
* Risk preference task (negative domain; **RPn**)
* Risk preference task (mixed domain; **RPm**)
* Ambiguity aversion task (**AA**)
* Social value orientation task (**SVO**)
* Risky dictator game (**RD**)
* Trust game (with choice history; **TG**)
* Trust game (with no choice history; **TGnh**)
* Trust game (as Player B; **TGb**)
* Prisoner’s dilemma game (**PD**)
* Stag hunt game (**SH**)
* Battle of the sexes game (**BS**)
  
You can try to play the tasks here: https://ntusingapore.qualtrics.com/jfe/form/SV_afMiUPTlQtwZ8SW

## Files in this GitHub repository 
* **Images** folder. This folder stores images used in the socialDMtasks.qsf. You can download the images and use them in your own GitHub or Qualtrics account.
* **example_Code_Data_Preprocessing** folder. This folder contains an example raw dataset from Qualtrics and scripts for preprocessing the raw data.
* **socialDMtasks.pdf**. This file shows each screen that a participant may see on when performing these tasks on Qualtrics.
* **socialDMtasks.qsf**. This is a “Qualtrics Survey Format” file, which contains the survey questions, Javascript, survey header, CSS, embedded data for the decision-making tasks and can be transferred to another Qualtrics account. Please note that if you import a .qsf file into your own account, the images in the original account will not be transferred. If the images in the original account are deleted, you will lose access to them. The images used in this socialDMtasks.qsf file are stored in the above "Images" folder. You can save these images to your own GitHub account and change the URL links in the header of the survey using the "updatingImageURLs.py" script below.
* **updatingImageURLs.py**. If you copy the images to your own GitHub account, this script can be used to update the URL links to all the images.


## Key components of a Qualtrics project
To implement the above-mentioned tasks on Qualtrics, having a basic knowledge of the following Qualtrics components is a pre-requisite:
1.	Survey questions, which offer the basic functionality to build an interface of a question or a task trial (https://www.qualtrics.com/support/survey-platform/survey-module/editing-questions/formatting-questions/).<br><br>
   A survey question can be shown in "HTML view" or "normal view". You can directly edit the question in either view.
   <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/HTML&JSwindow.png" alt="alt text" width="800">
   
2.	JavaScript, which enables more flexible coding, such as adding if-else condition and controlling timing of stimuli presentation (https://www.qualtrics.com/support/survey-platform/survey-module/question-options/add-javascript/).<br><br>
   In the above figure, you can open the JavaScript window by clicking the symbol "</>".
  	
3.	Survey header, which allows importing JavaScript libraries and setting code that will run for each page of the survey (https://www.qualtrics.com/support/survey-platform/survey-module/look-feel/general-look-feel-settings/#AddFooterHeader).<br><br>
   To view and edit the header of a Qualtrics project:<br>
   Click the "Survey" tab of that project<br>
   --> "Look and feel"<br> 
   --> "General"<br> 
   --> click "edit" under "Header"<br>
   --> click the "source" icon between the underline icon and "Less...", and you will see the header code.<br>
   <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/headerImage.png" alt="alt text" width="800">
   
4.	CSS, which can help you to customize the appearance of your survey questions or tasks (https://www.qualtrics.com/support/survey-platform/survey-module/look-feel/look-feel-overview/).<br><br>
   For example, CSS can be used to set the positions and colors of custom buttons and texts. 
   <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/CSSwindow.png" alt="alt text" width="800">
    
5.	Embedded data, which can be used to record extra information such as responses, accuracy, and timing of feedback in task trials (https://www.qualtrics.com/support/survey-platform/survey-module/survey-flow/standard-elements/embedded-data/).<br><br>
   In the following figure, four variables (in the red rectangle) have been created as embedded data. Values of these variables will be recorded in the data file of Qualtrics (See the section "Preprocessing data from Qualtrics" below).
   <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/EmbeddedData.png" alt="alt text" width="800">
    
6.	Library, which stores graphics and other file types that can be used for your surveys or tasks (https://www.qualtrics.com/support/survey-platform/account-library/library-overview/).<br><br>
   The following figure shows the library of Qualtrics. You can view the image and copy its URL link by clicking on "Copy link" in the red rectangle. 
   <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/Library.png" alt="alt text" width="800">
    
## Importing the QSF file into Qualtrics
Here are a few steps for transferring these tasks into your Qualtrics account (You need to have access to a Qualtrics account with full license, which allows for custom JavaScript.):
1.	Download the **socialDMtasks_ScientificData.qsf** file to your local computer.
2.	Import the .qsf file to your Qualtrics account.
<img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/ImportQSF.png" alt="alt text" width="500">

3.	Now you are ready to publish this project and run data collection.
## Tailoring the tasks on Qualtrics to suit your own study
You can use a subset of the tasks and tailor them to your own needs. You can also create your own tasks from scratch by using our tasks as a template.

* **Changing task images**
  
  After you have imported the .qsf file to your Qualtrics account and created a project, you can view the header.
  Since Quialtrics' header window is not suitable for code editing, you can copy and paste the code into a code editor of your chocie. After editing, you can paste into the header window and save.
  For example, you can use Notepad++:
  
  <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/URLlinks.png" alt="alt text" width="500">
  
  The images used in these tasks are stored in this Github repo, and their URL links are pasted into the header. The above screenshot shows some of the links. If you copy the images to your own GitHub account, the script “updatingImageURLs.py” can be used to update the URL links in the header.
  Alternatively, you can store the images in the library of your Qualtrics account and replace the URLs in the header.

* **Changing feedback**

  In the header, you can also set how the feedback of the risky options will be shown to participants.
  For example, in the risk preference task (positive domain), participants make nine rounds of choices between a sure gain of 10 points and a risky option with two possible outcomes (8 points or 15 points). For the risky option, the probability for winning 15 points increase from 10% to 90% across the nine rounds (e.g., In the 1st round, choosing the risky option entails an 10% chance of gaining 15 points and a 90% chance of gaining 8 points). Which outcome in each round will be shown to participants can be controlled here.
  There are three ways:<br><br>
      1. A single set of pseudo-randomized outcomes (e.g., we can use 0 to represent that the 8 points are shown, and 1 to represent that 15 points are shown. This vector [0,0,0,1,0,1,0,1,1] can be used for all participants to hardcode the feedback. Choosing the risky option in a certain round will always give the same outcome),<br><br>
      2. Multiple sets of pseudo-randomized outcomes (e.g., we can have multiple vectors and one of them will be chosen for a particular participant), and<br><br>
      3. Fully randomized outcomes (i.e., on each round and separately for each participant, the script will calculate the outcome based on a given probability).<br><br>
      
  These three ways are also denoted in the following figure. You can choose which way to use by changing the value of the variable RPp_pseudo_rand. Here we only discussed about risk preference task (positive domain), you can also choose values for this parameter in other tasks, including risk preference tasks (negative domain and mixed domain), ambiguity aversion, risky dicator, and trust game (with history). <br>
  
  <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/changingFeedback.png" alt="alt text" width="1000">


* **Changing payoffs of participants' reponses**

  If you want to change the payoffs/points gained by the participants, you can modify the related lines in the JavaScript code of the task round/question. For example, the code in the following figure shows that in the prisoner's dilemma game, when the participant presses the button "BLUE" and the opponent chooses "RED", the payoff for the participant is 6 and the payoff for the opponent is -6 (see the two lines of code in the upper red rectangle); when the opponent also chooses "BLUE", both players get the payoff of -3 (see code in the lower red rectangle).


  <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/Outcomes.png" alt="alt text" width="500">




## Preprocessing data from Qualtrics
After you have collected some data, you can export them into your local drive and use the scripts in the folder “example_Code_Data_Preprocessing” to do preprocessing and generate more readable data.
Please select “Use numeric values” when you download the data file from Qualtrics:

<img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/downloadDatatable.png" alt="alt text" width="800">
