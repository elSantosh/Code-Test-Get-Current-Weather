//
//  ViewController.swift
//  Code Test – Get Current Weather
//
//  Created by apple on 05/06/2019.
//  Copyright © 2019 workstreak. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler{

	//declaring webview
	@objc var webView = WKWebView()
	
	var webConfig:WKWebViewConfiguration {
		get {
			
			// Create WKWebViewConfiguration instance
			let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
			
			// Setup WKUserContentController instance for injecting user script
			let userController:WKUserContentController = WKUserContentController()
			
			// Add a script message handler for receiving  "buttonClicked" event notifications posted from the JS document using window.webkit.messageHandlers.buttonClicked.postMessage script message
			userController.add(self, name: "callbackHandler") // was originally "ButtonClicked"

			
			// Get script that's to be injected into the document
			let js:String = buttonClickEventTriggeredScriptToAddToDocument()
			
			// Specify when and where and what user script needs to be injected into the web document
			let userScript:WKUserScript =  WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
			
			// Add the user script to the WKUserContentController instance
			userController.addUserScript(userScript)
			
			// Configure the WKWebViewConfiguration instance with the WKUserContentController
			webCfg.userContentController = userController;
			
			return webCfg;
		}
	}
	func buttonClickEventTriggeredScriptToAddToDocument() ->String{
		let script:String = "webkit.messageHandlers.callbackHandler.postMessage('Sydney');"
		return script;
		
	}
	override func loadView() {
		self.view = webView
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		webView = WKWebView(frame: self.view.frame, configuration: webConfig)
		webView.navigationDelegate = self
		webView.translatesAutoresizingMaskIntoConstraints = false
		webView.sizeToFit()
		view = webView
		
		NSLayoutConstraint.activate([webView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),webView.leftAnchor.constraint(equalTo: view.leftAnchor),webView.rightAnchor.constraint(equalTo: view.rightAnchor),webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
		
		//creating HTML list view
		let htmlString = """
		
		<select onchange="test(this)" id ="Select City">
		<option value="Sydney">Sydney</option>
		<option value="Melbourne">Melbourne</option>
		<option value="Wollongong">Wollongong</option>
		</select>

		<style>
		table {
		width:30%;
		}
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
		
		<table>
		<tr>
		<td>City</td>
		<td>Melbourne</td>
		</tr>
		<tr>
		<td>Updated Time</td>
		<td>Thursday 11:00 AM</td>
		</tr>
		<tr>
		<td>Weather</td>
		<td>Mostly Cloudy</td>
		</tr>
		<tr>
		<td>Temperature</td>
		<td>9°C</td>
		</tr>
		<tr>
		<td>Wind</td>
		<td>30km/h</td>
		</tr>
		</table>
				
		
		"""
		webView.loadHTMLString(htmlString, baseURL: nil)
	}
	
	//WKScriptMessageHandler stub
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		if(message.name == "callbackHandler") {
			let recievedMsg = message.body as! String
			
			 if(recievedMsg == "Melbourne"){
				print("Melbourne Selected")
				print(message.body )
				self.callWeatherAPI(cityname: message.body as! String)
				
				
			}
			else if(recievedMsg == "Wollongong"){
				print("Wollongong Selected")
				print(message.body )
				self.callWeatherAPI(cityname: message.body as! String)
			}
			else {
				print("Sydney Selected")
				print(message.body )
				self.callWeatherAPI(cityname: message.body as! String)
			}
			
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
//		let jsString = "var list = document.getElementById('Select City'); var flag = true ;list.onchange = function () { if(flag){ webkit.messageHandlers.callbackHandler.postMessage('Does it works?'); flag = false;}else{document.bgColor = 'green';flag = true;}}"
		
//		let jstring = "const person = { firstName: 'John', lastName: 'Doe', age: 50, eyeColor: 'blue', }; function postMessage(message, callBack) { message.callBack = callBack.toString(); window.webkit.messageHandlers.callbackHandler.postMessage(message); } document.getElementById('Select City').onchange = function () { postMessage(person, function (args) { console.log('call back is invoked' ); console.log(args); }); };"
		
		let jscript = "function test(a) { var x = (a.value || a.options[a.selectedIndex].value); window.webkit.messageHandlers.callbackHandler.postMessage(x); }"
		webView.evaluateJavaScript(jscript, completionHandler: nil)
	}
	
	// Helper
	func showAlertWithMessage(message:String) {
		print(message)
	}
	
	//MARK: Calling Weather API
	func callWeatherAPI(cityname:String){

		let request = NSMutableURLRequest(url: NSURL(string: "https://samples.openweathermap.org/data/2.5/weather?q=London,uk&appid=b6907d289e10d714a6e88b30761fae22")! as URL,
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
					
					DispatchQueue.global(qos: .userInitiated).async { [weak self] in
						guard let self = self else {
							return
						}
						
						// 2
						DispatchQueue.main.async { [weak self] in
							// 3
							let tableString = """
							
							<!DOCTYPE html>
							<html>
							<head>
							<style>
							table {
							width:50%;
							}
							table, th, td {
							border: 1px solid black;
							border-collapse: collapse;
							}
							th, td {
							padding: 5px;
							text-align: left;
							}
							table#t01 tr:nth-child(even) {
							background-color: #5e5e5e;
							}
							table#t01 tr:nth-child(odd) {
							background-color: #fff;
							}
							table#t01 th {
							background-color: black;
							color: white;
							}
							</style>
							
							
							</head>
							<body>
							
							<h2>Styling Tables</h2>
							
							<table>
							<tr>
							<th>Firstname</th>
							<th>Lastname</th>
							<th>Age</th>
							</tr>
							<tr>
							<td>Jill</td>
							<td>Smith</td>
							<td>50</td>
							</tr>
							<tr>
							<td>Eve</td>
							<td>Jackson</td>
							<td>94</td>
							</tr>
							<tr>
							<td>John</td>
							<td>Doe</td>
							<td>80</td>
							</tr>
							</table>
							<br>
							</body>
							</html>
							
							"""
//							let webview2 = WKWebView(frame: CGRect(x: 30, y: 30, width: 200, height: 100), configuration: WKWebViewConfiguration())
//							webview2.loadHTMLString(tableString, baseURL: nil)
//							self?.webView.addSubview(webview2)
							
							
							let injectSrc = "var i = document.createElement('div'); i.innerHTML = '<!DOCTYPE html> <html> <head> <style> table { width:50%; } table, th, td { border: 1px solid black; border-collapse: collapse; } th, td { padding: 5px; text-align: left; } table#t01 tr:nth-child(even) { background-color: #5e5e5e; } table#t01 tr:nth-child(odd) { background-color: #fff; } table#t01 th { background-color: black; color: white; } </style> </head> <body> <h2>Styling Tables</h2> <table> <tr> <th>Firstname</th> <th>Lastname</th> <th>Age</th> </tr> <tr> <td>Jill</td> <td>Smith</td> <td>50</td> </tr> <tr> <td>Eve</td> <td>Jackson</td> <td>94</td> </tr> <tr> <td>John</td> <td>Doe</td> <td>80</td> </tr> </table> <br> </body> </html>';document.documentElement.appendChild(i);"
//							self?.webView.evaluateJavaScript(injectSrc, completionHandler: nil)

						}
					}
					
					
					//do your stuff
					
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
