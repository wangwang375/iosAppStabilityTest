# iosAppStabilityTest

#### Description
Test program for iOS app stability testing.

#### Instructions

1.  Clone or download the project locally, enter the "AppStability" directory, double-click "AppStability. xcodeproj" to open the project using Xcode, and wait for the project to load.

	![image-20230322150946601](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230322150946601.png)

2.  Select Target: AppStabilityUITests and select your developer account or team in "Signing&Capabilities".

	![image-20230322152001121](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230322152001121.png)

3.  Open "AppStability>AppStabilityUITests>AppStabilityUITests>testStability()" and edit the relevant parameters.
	Create a StabilityTestRunner instance:
	```swift
	// Parameter bundleIdentifier: The bundle ID of the app you want to test
	let st = StabilityTestRunner(bundleIdentifier: "com.Apple.ExampleApp")
	```
	Customize all UI operations that need to be executed, and the test program randomly executes only one of these operations at each step:
	```swift
	// The elements in the array are dictionaries, the key of the dictionary is the description of the UI operation, and the value is the UI operation function that needs to be executed. During the testing process, one of these will be randomly selected
	let actions: [String: (XCUIElement) -> ()] = ["tap": { element in element.tap() },
	                                              "double tap": {element in element.doubleTap()}]
	```
	Customize the types of all UI element objects that require action. Each step of the test will randomly select a UI element from the specified type:
	```swift
	// The element in the array is a type object of a UI element
	let type:[XCUIElement.ElementType] = [.button, .switch, .cell]
	```
	Start testing:
	```swift
	// The parameter duration is the duration of the test, in seconds
	// The parameter stepInterval is the time interval between each UI operation, in seconds. It defaults to 0.5. You can also customize it
	st.startTesting(duration: 30, elementType: type, actions: actions, stepInterval: 0.5)
	```
	<u>**Note: After a UI operation causes an app to crash, if you immediately perform the next operation, and there is not enough time to detect the status of the app and restart it, unpredictable errors may result. Therefore, the value of the parameter stepInterval cannot be too small. The app needs a certain reaction time after each UI operation. Suggestion: stepInterval>=0.5.**</u>

	Save the test log to view on the mac:

	```swift
	let zipFile = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/Logs.zip"
	        let attachment = XCTAttachment(contentsOfFile: URL(fileURLWithPath: zipFile))
	        attachment.name = "Logs"
	        attachment.lifetime = .keepAlways
	        // Add the "Logs.zip" file to the end of test result file.
	        add(attachment)
	        Utils.log("The logs for test steps has been added to the end of test result file at /User/Library/Developer/Xcode/DerivedData/AppStability-*/Logs")
	```
	Screenshot:

![image-20230322154254187](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230322154254187.png)

4.  Perform Test

	Method 1: Execute through Xcode Test Navigator. Before executing, you need to manually select the target device, such as iPhone 14

	![image-20230322171124774](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230322171124774.png)

	Method 2: Use the xcodebuild command-line tool to execute the following commands in the AppStability root directory:

	```sh
	xcodebuild test -scheme AppStability -destination 'platform=iOS,name=<your iphone name>'
	```

5.  View test results

	You can view the ". xcresult" test results file in the following directory:/User/Library/Developer/Xcode/DeliveredData/AppStability - */Logs. Double click to view it using Xcode

	![image-20230322175819413](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230322175819413.png)

	You can also open it directly in Xcode: Right click the testStability function in the Test Navigator and click "jump to report"

	![image-20230322180155421](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230322180155421.png)

	The content of the. xcresult result file contains detailed records of UI operations throughout the testing process. Most importantly, at the end of the content, there is a log file that summarizes all testing activities: Logs.zip.

	![image-20230322181258737](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230322181258737.png)

	Logs.zip can be directly decompressed for viewing, and contains a "log. txt" that records all UI operations and screenshots of the first three UI operations at each crash point.

	![image-20230322181826408](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230322181826408.png)

	![image-20230322181921904](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230322181921904.png)

	Decompressed Logs

	![image-20230323095249536](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230323095249536.png)

	log.txt:

	```sh
	2023-03-23 09:45:17 ***<Test begin!>***
	2023-03-23 09:45:18 step1: tap "tap to trigger crash" Button
	2023-03-23 09:45:20 The app crashed. The screenshot before the crash has been saved in the screenshot folder.
	2023-03-23 09:45:21 step2: tap "go to page1" Button
	2023-03-23 09:45:23 step3: double tap "Back" Button
	2023-03-23 09:45:25 step4: tap "go to page1" Button
	2023-03-23 09:45:27 step5: double tap "Back" Button
	2023-03-23 09:45:29 step6: double tap "tap to trigger crash" Button
	2023-03-23 09:45:31 The app crashed. The screenshot before the crash has been saved in the screenshot folder.
	2023-03-23 09:45:32 step7: double tap "tap to trigger crash" Button
	2023-03-23 09:45:34 The app crashed. The screenshot before the crash has been saved in the screenshot folder.
	2023-03-23 09:45:35 step8: double tap "go to page1" Button
	2023-03-23 09:45:37 step9: tap "Back" Button
	2023-03-23 09:45:39 step10: double tap "go to page1" Button
	2023-03-23 09:45:40 ***<Test finished!>***
	```

	Screenshot (The sequence of screenshots is the sequence of UI operations, and the elements to be executed will be identified by red boxes):

	![image-20230323095951258](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230323095951258.png)

#### Usage example

There is a "tap to trigger crash" button in the "ExampleApp" that can trigger a crash. You can use this app to test the testing effect of the stability testing program.

 1.  Double click on "ExampleApp. xcodeproj" to open the project using Xcode

 2.  Select an available developer account

	![image-20230323111029126](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230323111029126.png)

 3.  Select available ios devices

	![image-20230323110636781](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230323110636781.png)

 4.  Install and run the app

	![image-20230323111214141](https://cdn.jsdelivr.net/gh/wangwang375/pic_bed/PicGoimage-20230323111214141.png)

At this point, ExampleApp has been installed on your device. You can test the performance of the stability test program according to the detailed tutorials in the "Instructions".

#### Contribution

1.  Fork the repository
2.  Create Feat_xxx branch
3.  Commit your code
4.  Create Pull Request


#### Suggestions and feedback

Contact author: wang_wang164@163.com
