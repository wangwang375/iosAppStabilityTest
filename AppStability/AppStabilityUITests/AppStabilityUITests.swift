//
//  AppStabilityUITests.swift
//  AppStabilityUITests
//
//  Created by wang_wang164@163.com on 2022/2/17.
//

import XCTest

final class AppStabilityUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testStability() throws {
        // Create an instance of StabilityTestRunner
        let st = StabilityTestRunner(bundleIdentifier: "com.Apple.ExampleApp") // Modify the value of the parameter bundleIdentifier to the bundle id of the app to be tested.
        
        // Customize all UI operations that need to be executed, and the test program will randomly execute only one of them at each step.
        let actions: [String: (XCUIElement) -> ()] = ["tap": { element in element.tap() },
                                                      "double tap": {element in element.doubleTap()}]
        
        // Customize the types of all UI element objects that need to be operated on. Each step of the test will randomly select one UI element from the specified type
        let type:[XCUIElement.ElementType] = [.button, .switch, .cell]
        
        // To start the test, you can modify the value of the duration parameter to define the test execution time in seconds. You can also modify the value of the stepInterval parameter to define the time interval between each UI operation, which is also in seconds.
        // Note: The value of stepInterval is recommended to be greater than or equal to 0.5, otherwise unpredictable errors may result and affect the test process.
        st.startTesting(duration: 30, elementType: type, actions: actions)
        
        // To add the log files to the test results file, you can view it on your Mac. The test results file path: /User/Library/Developer/Xcode/DerivedData/AppStability-*/Logs.
        let zipFile = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/Logs.zip"
        let attachment = XCTAttachment(contentsOfFile: URL(fileURLWithPath: zipFile))
        attachment.name = "Logs"
        attachment.lifetime = .keepAlways
        // Add the "Logs.zip" file to the end of test result file.
        add(attachment)
        Utils.log("The logs for test steps has been added to the end of test result file at /User/Library/Developer/Xcode/DerivedData/AppStability-*/Logs")
    }
    
}
