# Stata-Python-Twitter-API
This project utilises the Twitter API to import twitter data directly into Stata. There is also an accompanying dialog box for those who prefer to use Stata's menu boxes to run commands.  

To use this command, place all four files into your PERSONAL ado directory. If you do not know where this is located, run the command **adopath** in Stata and it will list where your PERSONAL directory is located.  

To use the dialog box, run the command **db twitterlw** in Stata. Alternatively, you can add the dialog box to your Stata menus by putting the following commands in your personal *profile.do*:  
**window menu append item "stUserData" "Stata Twitter Download" "db twitterlw"**  
**window menu refresh**  
  
    
The **premiumapi.py** python file is used by this Stata command to access Twitter's API. This file is by Github user lucahammer and the original can be found here: https://gist.github.com/lucahammer/7631896c3023266c16934326a74b594b
