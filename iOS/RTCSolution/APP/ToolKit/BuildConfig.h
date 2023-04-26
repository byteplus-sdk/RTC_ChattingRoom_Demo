//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#ifndef JoinRTSConfig_h
#define JoinRTSConfig_h

/**
 * @brief  You can fill in the provided server domain name for testing. However, you need to deploy your own server and replace this address with your own domain name, when officially launching this function.
 */
#define HeadUrl @""

/**
 * @brief The unique identifier of each application is obtained through the application of the RTC console. The instances generated by different AppIds are completely independent in the audio and video calls in RTC and cannot communicate with each other.
 * https://console.volcengine.com/rtc/listRTC
 */
#define APPID @""


/**
 * @brief When using RTC, AppKey is used to generate rtc token and authenticate rtc token.
 * https://console.volcengine.com/rtc/listRTC
 */
#define APPKey @""


/**
 * @brief It is required when using RTS, and is used for authentication when the server calls RTS openapi. Used to confirm that the server has the ownership of this APPID
 * https://console.volcengine.com/iam/keymanage/
 */
#define AccessKeyID @""


/**
 * @brief It is required when using RTS, and is used for authentication when the server calls RTS openapi. Used to confirm that the server has the ownership of this APPID
 * https://console.volcengine.com/iam/keymanage/
 */
#define SecretAccessKey @""



#endif /* JoinRTSConfig_h */