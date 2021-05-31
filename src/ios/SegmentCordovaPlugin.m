#import "SegmentCordovaPlugin.h"
#import "SEGFirebaseIntegrationFactory.h"

// In-Case of using device-mode for Braze Uncomment the below lines
#import "SEGAppboyIntegrationFactory.h"
#import "Appboy.h"
#import "AppDelegate+Appboy.h"

@interface SegmentCordovaPlugin()
  @property NSString *APIKey;
  @property NSString *disableAutomaticPushRegistration;
  @property NSString *disableAutomaticPushHandling;
  @property NSString *apiEndpoint;
  @property NSString *enableIDFACollection;
  @property NSString *enableLocationCollection;
  @property NSString *enableGeofences;
  @property NSString *disableUNAuthorizationOptionProvisional;
@end

@implementation SegmentCordovaPlugin

- (void) pluginInitialize {
  NSDictionary *settings = self.commandDelegate.settings;
  self.APIKey = settings[@"com.appboy.api_key"];
  self.disableAutomaticPushRegistration = settings[@"com.appboy.ios_disable_automatic_push_registration"];
  self.disableAutomaticPushHandling = settings[@"com.appboy.ios_disable_automatic_push_handling"];
  self.apiEndpoint = settings[@"com.appboy.ios_api_endpoint"];
  self.enableIDFACollection = settings[@"com.appboy.ios_enable_idfa_automatic_collection"];
  self.enableLocationCollection = settings[@"com.appboy.enable_location_collection"];
  self.enableGeofences = settings[@"com.appboy.geofences_enabled"];
  self.disableUNAuthorizationOptionProvisional = settings[@"com.appboy.ios_disable_un_authorization_option_provisional"];
    
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishLaunchingListener:) name:UIApplicationDidFinishLaunchingNotification object:nil];
  if (![self.disableAutomaticPushHandling isEqualToString:@"YES"]) {
    [AppDelegate swizzleHostAppDelegate];
  }
}

- (void)didFinishLaunchingListener:(NSNotification *)notification {
  NSMutableDictionary *appboyLaunchOptions = [@{ABKSDKFlavorKey : @(CORDOVA)} mutableCopy];

  // Set location collection and geofences from preferences
  appboyLaunchOptions[ABKEnableAutomaticLocationCollectionKey] = self.enableLocationCollection;
  appboyLaunchOptions[ABKEnableGeofencesKey] = self.enableGeofences;

  // Add the endpoint only if it's non nil
  if (self.apiEndpoint != nil) {
    appboyLaunchOptions[ABKEndpointKey] = self.apiEndpoint;
  }

  [Appboy startWithApiKey:self.APIKey
            inApplication:notification.object
        withLaunchOptions:notification.userInfo
        withAppboyOptions:appboyLaunchOptions];

  if (![self.disableAutomaticPushRegistration isEqualToString:@"YES"]) {
    UIUserNotificationType notificationSettingTypes = (UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound);
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
      UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
      // If the delegate hasn't been set yet, set it here in the plugin
      if (center.delegate == nil) {
        center.delegate = [UIApplication sharedApplication].delegate;
      }
      UNAuthorizationOptions options = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
      if (@available(iOS 12.0, *)) {
        if (![self.disableUNAuthorizationOptionProvisional isEqualToString:@"YES"]) {
          options = options | UNAuthorizationOptionProvisional;
        }
      }
      [center requestAuthorizationWithOptions:options
                            completionHandler:^(BOOL granted, NSError *_Nullable error) {
                              [[Appboy sharedInstance] pushAuthorizationFromUserNotificationCenter:granted];
                            }];
      [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
      UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationSettingTypes categories:nil];
      [[UIApplication sharedApplication] registerForRemoteNotifications];
      [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
      [[UIApplication sharedApplication] registerForRemoteNotificationTypes: notificationSettingTypes];
    }
  }
}

- (void)startWithConfiguration:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    SEGAnalyticsConfiguration *configuration = nil;
    NSString* key = nil;
    NSDictionary* configOptions = nil;
    NSDictionary* options = nil;

    if ([command.arguments count] > 0) {
        key = [command.arguments objectAtIndex:0];
    }

    if (key != nil && [key length] > 0) {
        configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:key];

        if ([command.arguments count] > 1) {
            configOptions = [command.arguments objectAtIndex:1];

            // Set SEGAnalyticsConfiguration
            // https://github.com/segmentio/analytics-ios/blob/master/Analytics/Classes/SEGAnalyticsConfiguration.h
            if (![configOptions isEqual: [NSNull null]] ) {
                // ios only
                if ([configOptions objectForKey:@"shouldUseLocationServices"] != nil) {
                    configuration.shouldUseLocationServices = [[configOptions objectForKey:@"shouldUseLocationServices"] boolValue];
                }
                // ios only
                if ([configOptions objectForKey:@"enableAdvertisingTracking"] != nil) {
                    configuration.enableAdvertisingTracking = [[configOptions objectForKey:@"enableAdvertisingTracking"] boolValue];
                }
                // ios only
                if ([configOptions objectForKey:@"flushQueueSize"] != nil) {
                    configuration.flushAt = [[configOptions objectForKey:@"flushQueueSize"] unsignedIntegerValue];
                }
                if ([configOptions objectForKey:@"trackApplicationLifecycleEvents"]  != nil) {
                    configuration.trackApplicationLifecycleEvents = [[configOptions objectForKey:@"trackApplicationLifecycleEvents"] boolValue];
                }
                // ios only
                if ([configOptions objectForKey:@"shouldUseBluetooth"] != nil) {
                    configuration.shouldUseBluetooth = [[configOptions objectForKey:@"shouldUseBluetooth"] boolValue];
                }
                if ([configOptions objectForKey:@"recordScreenViews"] != nil) {
                    configuration.recordScreenViews = [[configOptions objectForKey:@"recordScreenViews"] boolValue];
                }
                // ios only
                if ([configOptions objectForKey:@"trackInAppPurchases"] != nil) {
                    configuration.trackInAppPurchases = [[configOptions objectForKey:@"trackInAppPurchases"] boolValue];
                }
                // ios only
                if ([configOptions objectForKey:@"trackPushNotifications"] != nil) {
                    configuration.trackPushNotifications = [[configOptions objectForKey:@"trackPushNotifications"] boolValue];
                }
                // Removed the ability to natively report attribution information 
                // via Segment integrations Since version 4.9.0
                // if ([configOptions objectForKey:@"trackAttributionInformation"] != nil) {
                //     configuration.trackAttributionData = [[configOptions objectForKey:@"trackAttributionInformation"] boolValue];
                // }
                if ([configOptions objectForKey:@"defaultOptions"] != nil) {
                    configuration.launchOptions = [configOptions objectForKey:@"defaultOptions"];
                }
                //Firebase Integration [device-mode]
                if ([configOptions objectForKey:@"enableFirebaseIntegration"] != nil && [[configOptions objectForKey:@"enableFirebaseIntegration"] boolValue] == true){
                    [configuration use:[SEGFirebaseIntegrationFactory instance]];
                }
                // Appboy Integration [device-mode]
                if ([configOptions objectForKey:@"enableBrazeIntegration"] != nil && [[configOptions objectForKey:@"enableBrazeIntegration"] boolValue] == true) {                      
                    [configuration use:[SEGAppboyIntegrationFactory instance]];
                 }
            }
        }

        [SEGAnalytics setupWithConfiguration:configuration];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Key is required."];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)identify:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    NSDictionary *inputs = nil;
    NSString* userId = nil;
    NSDictionary* traits = nil;
    NSDictionary* options = nil;

    if ([command.arguments count] > 0) {
        inputs = [command.arguments objectAtIndex:0];
        if (![inputs isEqual: [NSNull null]]) {
            userId = [inputs objectForKey:@"userId"];
            traits = [inputs objectForKey:@"traits"];
            options = [inputs objectForKey:@"options"];
        }
    }

    [[SEGAnalytics sharedAnalytics] identify:userId traits:traits options:options];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)track:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    NSDictionary *inputs = nil;
    NSString* event = nil;
    NSDictionary* properties = nil;
    NSDictionary* options = nil;

    if ([command.arguments count] > 0) {
        inputs = [command.arguments objectAtIndex:0];
        if (![inputs isEqual: [NSNull null]]) {
            event = [inputs objectForKey:@"event"];
            properties = [inputs objectForKey:@"properties"];
            options = [inputs objectForKey:@"options"];
        }
    }

    if (event != nil) {

        [[SEGAnalytics sharedAnalytics] track:event properties:properties options:options];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
    	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The name of the event is required."];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)screen:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    NSDictionary *inputs = nil;
    NSString* name = nil;
    NSDictionary* properties = nil;
    NSDictionary* options = nil;

    if ([command.arguments count] > 0) {
        inputs = [command.arguments objectAtIndex:0];
        if (![inputs isEqual: [NSNull null]]) {
            name = [inputs objectForKey:@"name"];
            properties = [inputs objectForKey:@"properties"];
            options = [inputs objectForKey:@"options"];
        }
    }

    if (name != nil) {
        [[SEGAnalytics sharedAnalytics] screen:name properties:properties options:options];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
    	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The name of the screen is required."];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)group:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    NSDictionary *inputs = nil;
    NSString* groupId = nil;
    NSDictionary* traits = nil;
    NSDictionary* options = nil;

    if ([command.arguments count] > 0) {
        inputs = [command.arguments objectAtIndex:0];
        if (![inputs isEqual: [NSNull null]]) {
            groupId = [inputs objectForKey:@"groupId"];
            traits = [inputs objectForKey:@"traits"];
            options = [inputs objectForKey:@"options"];
        }
    }

    if (groupId != nil) {
        [[SEGAnalytics sharedAnalytics] group:groupId traits:traits options:options];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
    	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The database ID for this group is required."];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)alias:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    NSDictionary *inputs = nil;
    NSString* newId = nil;
    NSDictionary* options = nil;

    if ([command.arguments count] > 0) {
        inputs = [command.arguments objectAtIndex:0];
        if (![inputs isEqual: [NSNull null]]) {
            newId = [inputs objectForKey:@"newId"];
            options = [inputs objectForKey:@"options"];
        }
    }

    if (newId != nil) {
        [[SEGAnalytics sharedAnalytics] alias:newId options:options];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
    	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The newId of the user to alias is required."];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getAnonymousId:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    NSString* anonymousId = [[SEGAnalytics sharedAnalytics] getAnonymousId];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                    messageAsString:anonymousId];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)reset:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    [[SEGAnalytics sharedAnalytics] reset];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end