# Social-Decision-Making-Tasks
Scripts and images for implementing decision-making tasks on Qualtrics.
We also share a dataset of responses from 292 participants in 12 decision-making tasks, inlcuding:
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
* Battle of sexes game (**BS**) 



## Key components of a Qualtrics project:
To implement the above-mentioned tasks on Qualtrics, having a basic knowledge of the following Qualtrics components is a pre-requisite:
1.	Survey questions, which offer the basic functionality to build an interface of a question or a task trial (https://www.qualtrics.com/support/survey-platform/survey-module/editing-questions/formatting-questions/).<br>
   A survey question can be shown in "HTML view" or "normal view". You can directly edit the question in either view.
   <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/HTML&JSwindow.png" alt="alt text" width="800">
   
2.	JavaScript, which enables more flexible coding, such as adding if-else condition and controlling timing of stimuli presentation (https://www.qualtrics.com/support/survey-platform/survey-module/question-options/add-javascript/).<br>
   In the above figure, you can open the JavaScript window by clicking the symbol "</>".
  	
3.	Survey header, which allows importing JavaScript libraries and setting code that will run for each page of the survey (https://www.qualtrics.com/support/survey-platform/survey-module/look-feel/general-look-feel-settings/#AddFooterHeader).<br>
   To view and edit the header of a Qualtrics project:<br>
   Click the "Survey" tab of that project<br>
   --> "Look and feel"<br> 
   --> "General"<br> 
   --> click "edit" under "Header"<br>
   --> click the "source" icon between the underline icon and "Less...", and you will see the header code.<br>
   <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/headerImage.png" alt="alt text" width="800">
   
4.	CSS, which can help you to customize the appearance of your survey questions or tasks (https://www.qualtrics.com/support/survey-platform/survey-module/look-feel/look-feel-overview/).

    
8.	Embedded data, which can be used to record extra information such as responses, accuracy, and timing of feedback in task trials (https://www.qualtrics.com/support/survey-platform/survey-module/survey-flow/standard-elements/embedded-data/).  
9.	Library, which stores graphics and other file types that can be used for your surveys or tasks (https://www.qualtrics.com/support/survey-platform/account-library/library-overview/). 

## Files in this GitHub repository: 
* “**socialDMtasks_ScientificData.qsf**” is a “Qualtrics Survey Format” file, which contains the survey questions, Javascript, survey header, CSS, embedded data for the decision-making tasks and can be transferred to another Qualtrics account. Please note that if you import the .qsf file into your own account, the files (including images) in the library are not transferred. If the images in the original account are deleted, you will lose access to them.
* To solve the issue mentioned above, we uploaded all the images of the decision-making tasks to the “**Images**” folder. You can download the images and use them in your own GitHub or Qualtrics account.
* If you copy the images to your own GitHub account, the script “**updatingImageURLs.py**” can be used to update the URL links to all the images.
* In the “**data&codebook**” folder, there are 12 csv files each containing responses from 392 participants in one decision-making task, along with a file with detailed demographics (“**demographics.csv**”) and a codebook (“**codebook.csv**”).
* The folder “**example_Code_Data_Preprocessing**” contains an example raw dataset from Qualtrics and a script for preprocessing the raw data. The reader can collect their own data using the   

## Importing QSF file into Qualtrics
Here are a few steps for transferring these tasks into your Qualtrics account (You need to have access to a Qualtrics account with full license, which allows for customary JavaScript.):
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

  In the header, you can also change the feedback the risky options. The risky options have two possible outcomes with certain probabilities. Which outcome will be shown to participants can be controlled here.
  There are three ways:\
      1. The outcomes are hardcoded (i.e., for instance a choice will always give $8),\
      2. The outcomes are pseudo-randomized (i.e., the outcome is chosen from a set of possible outcomes), and\
      3. the outcomes are fully randomized (i.e., on each round and separately for each participant, the script will calculate the outcome based on a given probability).
  
  <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/changingFeedback.png" alt="alt text" width="500">


* **Changing payoffs of participants' reponses**

  If you want to change the payoffs/points gained by the participants, you can modify the related lines in the JavaScript code of the task round/question.


  <img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/Outcomes.png" alt="alt text" width="500">




## Preprocessing data from Qualtrics
After you have collected some data, you can export them into your local drive and use the scripts in the folder “example_Code_Data_Preprocessing” to do preprocessing and generate more readable data.
Please select “Use numeric values” when you download the data file from Qualtrics:

<img src="https://raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/README%20Figures/downloadDatatable.png" alt="alt text" width="400">
