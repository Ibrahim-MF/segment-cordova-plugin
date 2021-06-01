# segment-cordova-plugin

> Cordova plugin for [Segment mobile SDK](https://segment.com/docs/sources/#mobile)

This version of the plugin uses versions `4.1.4` (iOS) and `4.9.4` (Android) of the Segment mobile SDK.
You can view Android and iOS SDK sources on Github.

-  https://github.com/segmentio/analytics-android
-  https://github.com/segmentio/analytics-ios

Prerequisites:

-  Segment API keys

## Installing

You can install the latest version of the plugin directly from git through the Cordova CLI:

```bash
cordova plugin add https://github.com/Ibrahim-MF/segment-cordova-plugin.git \
    --variable ANDROID_API_KEY=<set-your-appoy-api-key-for-android> \
    --variable ANDROID_CUSTOM_ENDPOINT=<set-your-appoy-custom-endpoint-for-android> \
    --variable FCM_REGISTERATION_ENABLED=<true Or false> \
    --variable FCM_SENDER_ID=<set-your-firebase-sender-id> \
```

Or you can specify them as plugin variables in your config.xml, for example:

```bash
    <plugin name="segment-cordova-plugin" spec="git+https://github.com/Ibrahim-MF/segment-cordova-plugin.git">
        <variable name="ANDROID_API_KEY" value="set-your-appoy-api-key-for-android" />
        <variable name="ANDROID_CUSTOM_ENDPOINT" value="set-your-appoy-custom-endpoint-for-android" />
        <variable name="FCM_REGISTERATION_ENABLED" value="true" />
        <variable name="FCM_SENDER_ID" value="set-your-firebase-sender-id" />
    </plugin>
```

## Usage

In your 'deviceready' handler, start Segment Analytics :

```javascript
window.Segment.startWithConfiguration(IOS_OR_ANDROID_KEY);
```

To track a Screen :

```javascript
window.Segment.screen({
	name: 'Home',
	properties: {
		path: '/home',
	},
});
```

To track an Event:

```javascript
window.Segment.track({
	event: 'Order Completed',
	properties: {
		revenue: 10,
	},
});
```

To track an Identity:

```javascript
window.Segment.identity({
	userId: 'segment_sdk_user',
	traits: {
		birthday: '2000-01-01',
	},
});
```

## Configuration options for `.startWithConfiguration()`

You can configure number of options to setup SDK.

#### trackApplicationLifecycleEvents (Android and iOS)

Record certain application lifecycle events like `Application Opened`, `Application Installed`, `Application Updated`. (Default: false)

#### recordScreenViews (Android and iOS)

Record screen views automatically. It's not useful for the Cordova PhoneGap app. (Default: false)

#### defaultOptions (Android and iOS)

Specify which integrations should be enabled or not for all calls. (Default: All)

#### trackAttributionInformation (Android and iOS) [Removed since version 4.9.0]

Record attribution data from enabled providers using the mobile service. (Default: false)

#### flushQueueSize (Android and iOS)

The queue size at which to flush events. (Default: 20, Max: 250 for Android and 100 for iOS)

#### collectDeviceId (Android)

Record the device id. (Default: true)

#### flushInterval (Android)

The interval at which the client should flush events (Default: 30 seconds)

#### tag (Android)

Key for caching. It's used to share different caches across the instances (Default: "analytics_write_key")

#### logLevel (Android)

Controls the level of logging (Default: INFO)

#### shouldUseLocationServices (iOS)

Use location services. (Default: false)

#### enableAdvertisingTracking (iOS)

Record advertising info. (Default: true)

#### shouldUseBluetooth (iOS)

Record bluetooth information. (Default: false)

#### trackInAppPurchases (iOS)

Record in-app purchases from the App Store. (Default: false)

#### trackPushNotifications (iOS)

Record push notifications. (Default: false)

**Example Usage:**

```javascript
window.Segment.startWithConfiguration(IOS_OR_ANDROID_KEY, {
	trackApplicationLifecycleEvents: true,
	flushInterval: 60,
	trackInAppPurchases: true,
	recordScreenViews: true,
	enableFirebaseIntegration: true,
	enableBrazeIntegration: true,
});
```
