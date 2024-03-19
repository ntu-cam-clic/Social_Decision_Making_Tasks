# -*- coding: utf-8 -*-
"""
This script is for updating the URL links for all the images of the decision-making tasks (stored on Github) in the header window of the Qualtrics form.

To edit the header of a Qualtrics project: 
    Click the "Survey" tab of that project 
    --> "Look and feel" 
    --> "General" 
    --> click "edit" under "Header"
    --> click the "source" icon between the underline icon and "Less...", and you will see the header code.
You can copy all the code into a newly created file named "QualtricsHeader.js".
Here, the script reads in each line of the file "QualtricsHeader.js", changes the lines with URL links to the desired format, 
and writes them into a new file "QualtricsHeaderUpdated.js". 
Note that in the URL of the updated file, a "+" sign was added, otherwise the links can't be saved in Qualtrics header. 
An example of the link is like this: 
URL_TGb_mainImg_round2=
"https:"+"//raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/Images/Trust%20Game%20(as%20Player%20B)/TGb_mainImg_round2.png";
Then you can copy the code in the updated file and replace the code in the header window of Qualtrics. 

Note that the links to the images on GitHub have a very regular format, making them easy to update.
If you host your images on your Qualtrics account, you may need to copy and paste the link for each image seperately. 

Created on Thu Mar 14 11:10:04 2024
@author: Shengchung Feng
"""
#import modules
import os,re
#set directory to the js script containing all the URLs to images.
os.chdir("D:\pathToFiles");
#The rootpath of images on GitHub
#In the URL, we need to add a "+" sign, otherwise can't be saved in Qualtrics header. 
imagesRootPath1="https:"; 
imagesRootPath2="//raw.githubusercontent.com/ntu-cam-clic/Social_Decision_Making_Tasks/main/Images/";
with open('QualtricsHeader.js','r') as file:
    lines = file.readlines(); # read in all lines

with open('QualtricsHeaderUpdated.js','w') as file:
    for line in lines:
        URLorNot=re.search('URL_',line);  # search if there is a URL link for each line
        equalSign=re.search('="',line);
        if (URLorNot and equalSign):
           index1=URLorNot.span()[1];
           index2=equalSign.span()[0]; 
           # here deal with different tasks, as images for different task are stored in different subfolders
           if (re.search('_AA_',line)):
              subfolderName='Ambiguity%20Aversion/';
           elif (re.search('_BS_',line)):
              subfolderName='Battle%20of%20Sexes/';
           elif (re.search('_PD_',line)):
              subfolderName='Prisoner\'s%20Dilemma/';
           elif (re.search('_RPm_',line)):
              subfolderName='Risk%20Preference%20(Mixed)/';
           elif (re.search('_RPn_',line)):
              subfolderName='Risk%20Preference%20(Negative%20Domain)/';
           elif (re.search('_RPp_',line)):
              subfolderName='Risk%20Preference%20(Positive%20Domain)/';
           elif (re.search('_RD_',line)):
              subfolderName='Risky%20Dictator/';
           elif (re.search('_SVO_',line)):
              subfolderName='Social%20Value%20Orientation/';
           elif (re.search('_SH_',line)):
              subfolderName='Stag%20Hunt/';
           elif (re.search('_TGb_',line)):
              subfolderName='Trust%20Game%20(as%20Player%20B)/';
           elif (re.search('_TG_',line)):
              subfolderName='Trust%20Game%20(with%20history)/';
           elif (re.search('_TGnh_',line)):
              subfolderName='Trust%20Game%20(with%20no%20history)/';             
           else:
              subfolderName='';  # for images not in a subfolder
           
           imageName=line[index1:index2]; # name of an image
           # some images have a different format, here deal with them individually
           if (imageName == "AA_Figure4" or imageName =="RPp_Figure3" or imageName =="RPn_Figure3" or imageName =="RPm_Figure3" or imageName =="RD_Figure5"):
              endString='.gif";\n';
           else:
              endString='.png";\n';
           outputLine=''.join(['URL_',imageName,'="',imagesRootPath1,'"+"',imagesRootPath2,subfolderName,imageName,endString]); # update the line
           print(outputLine); # optional; checking the names in console.
        else:
           outputLine=line;
        file.write(outputLine)  # write the new lines into the updated file
