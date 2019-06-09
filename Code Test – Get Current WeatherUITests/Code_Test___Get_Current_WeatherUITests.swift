//___FILEHEADER___

import XCTest

class ___FILEBASENAMEASIDENTIFIER___: XCTestCase {
var app: XCUIApplication!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
        super.tearDown()
        
    }

    func testAPIExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        app = XCUIApplication()
        app.webViews.otherElements["Sydney"].tap()
        app/*@START_MENU_TOKEN@*/.pickerWheels["Sydney"]/*[[".pickers.pickerWheels[\"Sydney\"]",".pickerWheels[\"Sydney\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.toolbars["Toolbar"].buttons["Done"].tap()
        
        
    }

}
