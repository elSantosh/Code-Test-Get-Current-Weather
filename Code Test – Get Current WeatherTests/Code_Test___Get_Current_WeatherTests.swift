//___FILEHEADER___

import XCTest
//Renamed from default module name "Code Test - Get Current Weather " to "CodeTest" in Build Settings at Product Build Name for testable imporst convenience 
@testable import CodeTest

class ___FILEBASENAMEASIDENTIFIER___: XCTestCase {
    
    //create our "system unit test" variable
    var sut: ViewController!
    override func setUp() {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //load HTML
        sut.viewDidLoad()
        
        //Initialize JavaScript
        let webview = sut.webView
        sut.insertCSSString(into: webview)
    }

    override func tearDown() {
       
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        //Test API call with one city name
        sut.callWeatherAPI(cityname: "Sydney")

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            sut.callWeatherAPI(cityname: "Sydney")
        }
    }

}
