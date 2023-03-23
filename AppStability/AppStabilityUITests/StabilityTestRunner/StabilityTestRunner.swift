//
//  StabilityTestRunner.swift
//  AppStabilityUITests
//
//  Created by wang_wang164@163.com on 2022/2/17.
//

import XCTest

public class StabilityTestRunner{
    
    
    // The app instance.
    private var app: XCUIApplication = XCUIApplication()
    
    // The bundle identifier of the app.
    private var bundleIdentifier: String
    
    // The duration of the test.
    private var testDuration: TimeInterval = 0
    
    // The test steps of the test.
    private var currentStep: Int = 0
    
    // Current test time.
    private var currentTime: TimeInterval = 0
    
    // Test end flag.
    private var isTestingComplete: Bool = false
    
    // Countdown timer.
    private var countdownTimer: Timer?
    
    // Screenshot data.
    private var screenshotData:[Int: Data] = Dictionary()
    
    // Screenshot data for page elements.
    private var screenshotOfElementData:[Int: Data] = Dictionary()
    
    // Initialization.
    init(bundleIdentifier: String) {
        self.bundleIdentifier = bundleIdentifier
        self.app = XCUIApplication.init(bundleIdentifier: bundleIdentifier)
    }
    
    /**
     Start executing test.
     - parameter duration: Test duration in seconds.
     - parameter elementType: Array objects containing different element types, refer to XCUIElement.ElementType.
     - parameter actions: Dictionary objects containing different UI operations.
     - parameter stepInterval: The time interval between each UI operation, the default value is 0.5.
     - example：
         let st = StabilityTestRunner(bundleIdentifier: "xxx.com.stability")
         let actions: [String: (XCUIElement) -> ()] = ["tap": { element in element.tap() }]
         let type:[XCUIElement.ElementType] = [.button, .switch, .cell]
         st.startTesting(duration: 200, elementType: type, actions: actions)
     */
    public func startTesting(duration: TimeInterval, elementType: [XCUIElement.ElementType], actions: [String: (XCUIElement) -> ()], stepInterval: TimeInterval = 0.5) {
        testDuration = duration
        app.launch()
        try? Utils.clearFolder(atPath: Utils.logSavingPath) // Clear logs.
        stopCountdownTimer()
        startCountdownTimer() // Start the countdown timer.
        Utils.log("***<Test begin!>***")
        while !isTestingComplete{
            // Randomly select page elements.
            let element = app.randomElement(of: elementType)
            if element != nil {
                currentStep += 1
                takeScreenshot(element: element!)
                performRandomAction(on: element!, actions: actions) // Perform random UI operations.
                XCTWaiter().wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "self == %d", XCUIApplication.State.runningForeground.rawValue), object: app)], timeout: stepInterval)
                if app.state != .runningForeground {
                    app.activate()
                    Utils.saveImagesToFiles(images: screenshotData)
                    Utils.saveImagesToFiles(images: screenshotOfElementData, name: "screenshot_element")
                    Utils.log("The app crashed. The screenshot before the crash has been saved in the screenshot folder.")
                }
            }
        }
        Utils.log("***<Test finished!>***")
        // Compress the 'Logs' folder.
        let zipFile = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/Logs.zip"
        let success =  Utils.zip(folderPath: Utils.logSavingPath, zipFilePath: zipFile)
        if !success {
            Utils.log("Failed to compress folder: \(Utils.logSavingPath)")
        }
    }
    // MARK: Private method
    /**
     Start a countdown timer and terminate the test when the countdown ends.
     */
    private func startCountdownTimer() {
        DispatchQueue.global().async {
            self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {[weak self] timer in
                if self?.testDuration == 0 {
                    self?.isTestingComplete = true
                    self?.stopCountdownTimer()
                    return
                }
                self?.testDuration -= 1
            }
            RunLoop.current.add(self.countdownTimer!, forMode: .common)
            RunLoop.current.run()
        }
    }
    
    /**
     Turn off the countdown timer
     */
    private func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    /**
     Random execution of the given UI operation.
     - parameter element: Page Elements.
     - parameter actions: Dictionary objects containing different UI operations.
     */
    private func performRandomAction(on element: XCUIElement, actions: [String: (XCUIElement) -> ()]) {
        let keys = Array(actions.keys)
        let randomIndex = Int.random(in: 0..<keys.count)
        let randomKey = keys[randomIndex]
        let action = actions[randomKey]
        
        if action == nil {
            return
        }
        
        if !element.exists {
            return
        }
        
        if !element.isHittable {
            return
        }
        Utils.log("step\(currentStep): \(randomKey) \(element.description)")
        action!(element)
    }
    
    /**
     Take a screenshot and store the data of it.
     */
    private func takeScreenshot(element: XCUIElement) {
        let screenshot = app.windows.firstMatch.screenshot().image
        if screenshotData.count == 3 {
            let minKey = screenshotData.keys.sorted().first!
            screenshotData.removeValue(forKey: minKey)
        }
        let screenshotWithRect = Utils.drawRectOnImage(image: screenshot, rect: element.frame)
        screenshotData[currentStep] = screenshotWithRect.pngData()
        let screenshotOfElement = element.screenshot().pngRepresentation
        if screenshotOfElementData.count == 3 {
            let minKey = screenshotOfElementData.keys.sorted().first!
            screenshotOfElementData.removeValue(forKey: minKey)
        }
        screenshotOfElementData[currentStep] = screenshotOfElement
    }

}


extension XCUIElement {
    
    func randomElement(of types: [ElementType]) -> XCUIElement? {
        var allElement:[XCUIElement] = []
        for type in types {
            if !self.exists{
                break
            }
            var elements: [XCUIElement]
            if self.alerts.count > 0 {
                elements = self.alerts.descendants(matching: type).allElementsBoundByIndex
            }else {
                elements = self.descendants(matching: type).allElementsBoundByIndex
            }
            let filteredElements = elements.filter { element in
                if !element.exists {
                    return false
                }
                if !element.isHittable || !element.isEnabled {
                    return false // Filter out non clickable and blocked elements.
                }
                return true
            }
            allElement.append(contentsOf: filteredElements)
        }
        
        return allElement.randomElement()
    }
}




