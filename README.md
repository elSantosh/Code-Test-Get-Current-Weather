# Code-Test-Get-Current-Weather

Project Name: Code Test – Get Current Weather
Repository URL :https://github.com/elSantosh/Code-Test-Get-Current-Weather

This project will allow user to select three cities in Australia and return the its current weather in five fields of data. All the obtained data is from https://openweathermap.org/api. The units which I’ve used to show the result is in metrics. 

Coding Flow:

UI in HTML on WKWebView with custom web configuration (UIWebView is depreciated) 
Network Request and UI Update with JavaScript. 
Core Data DB Usage.
Managed Internet Connection when there is no internet.
Unit Testing.
UI Automation Unit Testing via UI flow record functionality in Xcode.

Networking:

Get city name from the HTML select tag value with wkwebview evaluateJavascriptFromString method. And and used a method from config class to construct URL to avoid ambiguity.

URLSession has been used to call the API and result obtained was in JSON format. Using swift’s own JSONSerialization, I have parsed the result with help of debugging method.

Dispatch Queues Usage: 

Safely handled UI updates with dispatch threads. And updated operation of UI on main queue.

DataBase:

CoreData was used to store the weather information of the cities and retired it when there is no internet connection.

Entity Structure:
{City {name, updatedTime, weather, temperature and wind}}

Systems Used:

Macbook pro, User name: Santosh Guruju
2.  iMac , User Name: apple

Execution:   

Open .xcodeproj file from the folder “Code Test - Get Current Weather”
Change bundle Id to any of you own bundle id generated for this project.
Change apple developer account to your account. 
Changes device to any of your iOS device.
Press “command+shift+U” to run unit tests and check the test result.
Press “command+R” to execute the project. 

Note: Hopefully everything works smoothly!
