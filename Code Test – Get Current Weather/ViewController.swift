//
//  ViewController.swift
//  Code Test – Get Current Weather
//
//  Created by apple on 05/06/2019.
//  Copyright © 2019 workstreak. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate,UIScrollViewDelegate, WKUIDelegate, WKScriptMessageHandler{
    
    //declaring webview
    @objc var webView = WKWebView()

    var webConfig:WKWebViewConfiguration {
        get {
            
            // Create WKWebViewConfiguration instance
            let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
            
            // Setup WKUserContentController instance for injecting user script
            let userController:WKUserContentController = WKUserContentController()
            
            // Add a script message handler for receiving  onchange event notifications posted from the JS document using window.webkit.messageHandlers.buttonClicked.postMessage script message
            userController.add(self, name: "callbackHandler")
            
            
            // Get script that's to be injected into the document
            let js:String = buttonClickEventTriggeredScriptToAddToDocument()
            
            // Specify when and where and what user script needs to be injected into the web document
            let userScript:WKUserScript =  WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
            
            // Add the user script to the WKUserContentController instance
            userController.addUserScript(userScript)
            
            
            
            // Configure the WKWebViewConfiguration instance with the WKUserContentController
            webCfg.userContentController = userController;
            
            return webCfg;
        }
    }
    func buttonClickEventTriggeredScriptToAddToDocument() ->String{
        let script:String = ""
        return script;
        
    }
    override func loadView() {
        self.view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(statusManager),
                         name: .flagsChanged,
                         object: nil)
        updateUserInterface()
        
        
        //confugure wkwebview with above writter web config
        webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.navigationDelegate = self
//        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.setZoomScale(75.0, animated: true)
        view = webView
        
        
//        NSLayoutConstraint.activate([webView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),webView.leftAnchor.constraint(equalTo: view.leftAnchor),webView.rightAnchor.constraint(equalTo: view.rightAnchor),webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        //creating HTML list view and Table View
        let htmlString = """
		<select onchange="test(this)" id ="Select City">
		<option value="Sydney">Sydney</option>
		<option value="Melbourne">Melbourne</option>
		<option value="Wollongong">Wollongong</option>
		</select>

		<style>
		table {
		width:300;height:100
		}select {width:100;height:20}
		table, th, td {
		border: 1px solid black;
		border-collapse: collapse;
		}
		th, td {
		padding: 1px;
		text-align: left;
		}
		tr:nth-child(even) {
		background-color: #d3d3d3;
		}
		tr:nth-child(odd) {
		background-color: #fff;
		}
		table#t01 th {
		background-color: black;
		color: white;
		}
		</style>
		
		<h1></h1>

		<table id="data-table">
		<tr>
		<td>City</td>
		<td id="City">Melbourne</td>
		</tr>
		<tr>
		<td>Updated Time</td>
		<td id="Updated Time">Thursday 11:00 AM</td>
		</tr>
		<tr>
		<td>Weather</td>
		<td id="Weather">Mostly Cloudy</td>
		</tr>
		<tr>
		<td>Temperature</td>
		<td id="Temperature">9°C</td>
		</tr>
		<tr>
		<td>Wind</td>
		<td id="Wind">30km/h</td>
		</tr>
		</table>
		"""
        
        //NOTE: Sample Data on HTML is used only for convenience
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    
    func updateUserInterface() {
        switch Network.reachability.status {
            
            
        case .unreachable:
            DispatchQueue.main.async {
                
                self.webView.backgroundColor = .red
                self.view = self.webView
            }
        case .wwan:
            DispatchQueue.main.async {
                
                self.webView.backgroundColor = .yellow
                self.view = self.webView
            }
        case .wifi:
            DispatchQueue.main.async {
                
                self.webView.backgroundColor = .green
                self.view.backgroundColor = .blue
            }
        }
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    //WKScriptMessageHandler stub
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            
            print(message.body)
            self.callWeatherAPI(cityname: message.body as! String )
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.insertCSSString(into: webView)
    }
    
    private func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        NSLog("%s. With Error %@", #function, error)
        showAlertWithMessage(message: "Failed to load file with error \(error.localizedDescription)!")
    }
    
    func insertCSSString(into webView: WKWebView) {
        let jsString = "var list = document.getElementById('Select City'); webkit.messageHandlers.callbackHandler.postMessage(list.options[list.selectedIndex].value); list.onchange = function () { var city =list.options[list.selectedIndex].value;  webkit.messageHandlers.callbackHandler.postMessage(city); }"
        webView.evaluateJavaScript(jsString, completionHandler: nil)
    }
    
    // Helper
    func showAlertWithMessage(message:String) {
        print(message)
    }
    
    //MARK: Calling Weather API
    func callWeatherAPI(cityname:String){
        
        let appId = "ec1f81d7376043d463b1a7d4f50b87fa"
        
        
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(cityname)&units=metric&appid=\(appId)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if error == nil && data != nil {
                do {
                    // Convert NSData to Dictionary where keys are of type String, and values are of any type
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                    print(json)
                    var cityName = ""
                    var updateTime = ""
                    var weather = ""
                    var temparature = ""
                    var wind = ""
                    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                        guard let self = self else {
                            return
                        }
                        // 2
                        DispatchQueue.main.async { [weak self] in
                            // 3
                            
                            if let response = json as NSDictionary?
                            {
                                if let City:String = response.value(forKey: "name") as? String{
                                    
                                    cityName = City
                                    
                                }
                                if let UpdateTime = response.value(forKey: "dt") as? TimeInterval{
                                    
                                    let date = Date(timeIntervalSince1970: UpdateTime)
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.timeZone = .autoupdatingCurrent
                                    dateFormatter.locale = NSLocale.current
                                    dateFormatter.dateFormat = "EEEE, HH:mm a"
                                    updateTime = dateFormatter.string(from: date)
                                }
                                if let WeatherAry = response.value(forKey: "weather") as! NSArray?
                                {
                                    if let weatherDict: NSDictionary = WeatherAry.object(at: 0) as? NSDictionary
                                    {
                                        weather = (weatherDict["description"] as! String?)!
                                    }
                                }
                                
                                if let TemparatureDict = response.value(forKey: "main") as! NSDictionary?{
                                    
                                    
                                    if let TempDouble: Double = TemparatureDict["temp"] as? Double {
                                        temparature = NSString(format: "%.f℃", TempDouble) as String}
                                    
                                    
                                }
                                if let Wind = response.value(forKey: "wind") as! NSDictionary?
                                {
                                    
                                    if let WindDict = Wind as NSDictionary?
                                    {
                                        if let windDouble:Double = WindDict["speed"] as? Double
                                        {
                                            let KmPerHr: Double = (18 * ( windDouble))/5 as Double? ?? 0
                                            
                                            wind = NSString(format: "%.1f km/h", KmPerHr as CVarArg) as String
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                                
                            }
                            
                            let jscript = "document.getElementById('City').innerHTML = '\(cityName)'; document.getElementById('Updated Time').innerHTML = '\(updateTime)'; document.getElementById('Weather').innerHTML = '\(weather)'; document.getElementById('Temperature').innerHTML = '\(temparature)';document.getElementById('Wind').innerHTML = '\(wind)';"
                            
                            self?.webView.evaluateJavaScript(jscript, completionHandler: nil)
                            
                        }
                    }
                    
                    
                    //  completionHandler(true)
                    
                } catch {
                    // completionHandler(false)
                }
            }
            else if error != nil
            {
                //completionHandler(false)
            }
        }).resume()
        

    }
    
    
    
}

