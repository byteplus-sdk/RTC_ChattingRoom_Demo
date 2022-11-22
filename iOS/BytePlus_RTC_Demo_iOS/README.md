Chatting room is an open source sample project provided by BytePlus RTC. This topic describes how to run this sample project to try the RTC Chatting room.

## **Note**

After using the project file to build an application, you can use the built application for Chatting room.
You and your colleagues must join the same room to have a Chatting room.

## **Prerequisites**

- [Xcode](https://developer.apple.com/download/all/?q=Xcode) 12.0+
	

- Real device that is running iOS 12.0 or later
	

- [AppleID](http://appleid.apple.com/)
	

- [BytePlus developer account](https://console.byteplus.com/auth/login/)
	

- [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#getting-started) 1.10.0+
	

## **Project setup**

### **Step 1: Contact BytePlus Technical Support to create an account in the** **RTC** **console**

### **Step 2: Obtain AppID and AppKey**

Obtain the AppID and AppKey by creating an application on the [App Management](https://console.byteplus.com/rtc/listRTC) page or using the created application in the BytePlus RTC console.

### **Step 3: Obtain AccessKey** **ID** **and SecretAccessKey**

Obtain the **AccessKeyID and SecretAccessKey** on the [Key Management](https://console.byteplus.com/iam/keymanage) page in the BytePlus RTC console.

### **Step 4: Build project**

1. Open a CLI on a terminal and go to the root directory `VoiceChatDemo/iOS/veRTC_Demo_iOS`.
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_f355b34053e4cefd1cb120b83a7658f3.png" width="500px" >

2. Run the `pod install` command to build the project.<br>
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_88ecddfff007de82fbb7a25ffa57a438.png" width="500px" >

3. Go to the root directory `VideoChatDemo/iOS/veRTC_Demo_iOS`. Launch Xcode and open the file `veRTC_Demo.xcworkspace`
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_747178378f8ff84bd1ed945e2783f58a.png" width="500px" >	

 
4. In Xcode, open the file `Pods/Development Pods/Core/BuildConfig.h` .

5. Enter **LoginUrl**. <br>
You can use **https://demo.byteplus.com/rtc/demo/rtc\_demo\_special/login** as the test domain name of the server. However, this domain name only provides testing running and cannot be used for official operations.
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_1b4b3615df81d0039e0514122b5e65df.png" width="500px" >
6. Enter AppID, AppKey, AccessKeyID, and SecretAccessKey <br>
Enter the **AppID, App Key, AccessKeyID**, and **SecretAccessKey** obtained from the BytePlus RTC console in the corresponding fields of the file `BuildConfig.h`.<br>
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_8585fe2c1d6ddeeb8d8a7674658f2e31.png" width="500px" >

### **Step 5: Configure developer certificate**

1. Connect your mobile phone to the computer and select your iOS device in the `iOS Device` option.
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_29e64208fb8ee3f6768999e1f8515aae.png" width="500px" >

2. Log in to your Apple ID.
2.1 Select **Xcode** **> Preferences** in the upper left corner on the Xcode page, or use the **Command** + shortcut to open Preferences.
2.2 Select **Accounts**, click the Add button (+) in the lower-left corner, and select Apple ID to log in to your account.
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_029bd0755308fffa3f4c7c670159667c.png" width="500px" >

3. Configure developer certificate.<br>
3.1 Click the `VeRTC_Demo` project in the left navigation pane of Xcode, click the `VeRTC_Demo` project under the `TARGETS` menu, and select **Signing & Capabilities > Automatically manage signing** to automatically generate the certificate.
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_0b906d74aa894b60d13aa31747a69a22.png" width="500px" >

3.2 Select Personal Team from the **Team** pop-up menu.
	<img src="(https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_5b16cbcb2ae6b5d8f3961d35a675f037.png" width="500px" >

3.3 **Change Bundle Identifier.** <br>
The default `vertc.veRTCDemo.ios` has been registered. Change it to another Bundle ID in the format of `vertc.xxx`.
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_49ae7cf89288819dcfb6f560f4948d64.png" width="500px" >

### **Step 6: Compile and run**

Select **Product** > **Run** to compile the sample project. A new app will be added to your iOS device after the sample project is compiled. For a free Apple ID, you need to go to `Settings > General > VPN & Device Management > Description File & Device Management` to trust the developer app.<br>
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_484d71be3a3cb19d98cd523419386395.png" width="500px" >
<br>
The following figure shows the screen when the app starts running.<br>
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_d75f48b7251addd0709bdbf9b518e27d.jpg" width="200px" >