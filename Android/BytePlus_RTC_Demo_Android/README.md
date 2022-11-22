Chatting room is an open source sample project provided by BytePlus RTC. This topic describes how to run this sample project to try the RTC Chatting room.

## **Note**

After using the project file to build an application, you can use the built application for Chatting room.
You and your colleagues must join the same room to have a Chatting room.
This open-source project doesn't support Effects-related function. Please download [BytePlus RTC APP](https://docs.byteplus.com/byteplus-rtc/docs/75707#download-solution-demo) to experience it.
If you have installed the BytePlus RTC APP, please uninstall it before compiling and running the sample project. Otherwise, an installation failure message will be displayed.

## **Prerequisites**

- Android Studio ([Chipmunk](https://developer.android.com/studio/releases) version recommended)
	

- [Gradle](https://gradle.org/releases/) (version： gradle-7.4.2-all)
	

- Real device that is running Android 4.4 or later
	

- [BytePlus developer account](https://console.byteplus.com/auth/login/)
	

### **Project setup**

### **Step 1: Contact BytePlus Technical Support to create an account in the** **RTC** **console**

### **Step 2: Obtain AppID and AppKey**

Obtain the AppID and AppKey by creating an application on the [App Management](https://console.byteplus.com/rtc/listRTC) page or using the created application in the BytePlus RTC console.

### **Step 3: Obtain the Access Key ID and Secret Access Key**

Obtain the **AccessKeyID and SecretAccessKey** on the [Key Management](https://console.byteplus.com/iam/keymanage) page in the BytePlus RTC console.

### **Step 4: Build project**
1. Launch Android Studio and open the folder `VideoChatDemo/Android/veRTC_Demo_Android`.
2. Enter the **LoginUrl**.
Open the file `gradle.properties` and enter the **LoginUrl**.
You can use **https://demo.byteplus.com/rtc/demo/rtc\_demo\_special/login** as the test domain name of the server. However, this domain name only provides testing running and cannot be used for official operations.
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_3794b5dbc97b4559611f7b075fcb20d1.png" width="500px" >


3. **Enter AppID, AppKey, AccessKeyID, and SecretAccessKey.** <br>
Open the file`gradle.properties`in the root directory and enter the **AppID, AppKey, AccessKeyID, and SecretAccessKey.** <br>
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_9ab4f0ed66084fc7d7fe996076c6f150.png" width="500px" >

**Step 5: Compile and run**

1. Connect your mobile phone to the computer, and enable the debugging feature in the Developer option on your phone. Once the device is successfully connected, the device name will be displayed in the upper right corner of the page.
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_ff9d8d722ec428a5743a0833ba13a4b4.png" width="500px" >	
2. Select **Run** > **Run 'app’** to compile the sample project. A new app will be added to your Android device after the sample project is compiled. Some mobile phones may require you to confirm the installation twice. Please select “Confirm Installation”.
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_cc51fc505c341a34901ce887b84aa033.png" width="500px" >	

The following figure shows the screen when the app starts running.<br>
	<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_1cdad8f754dc06a2b57e599a71451109.jpg" width="200px" >	