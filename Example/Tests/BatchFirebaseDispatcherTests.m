//
//  BatchFirebaseDispatcherTests.m
//  Batch-Firebase-Dispatcher_Tests
//
//  Created by Elliot Gouy on 23/10/2019.
//  Copyright © 2019 elliot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock.h>
#import <FirebaseAnalytics/FirebaseAnalytics.h>

#import "BatchFirebaseDispatcher.h"
#import "BatchPayloadDispatcherTests.h"

@interface BatchFirebaseDispatcherTests : XCTestCase

@property (nonatomic) id helperMock;
@property (nonatomic) BatchFirebaseDispatcher *dispatcher;

@end

@implementation BatchFirebaseDispatcherTests

- (void)setUp
{
    [super setUp];

    _dispatcher = [BatchFirebaseDispatcher instance];
    _helperMock = OCMClassMock([FIRAnalytics class]);
    OCMStub([_helperMock logEventWithName:[OCMArg any] parameters:[OCMArg any]]);
}

- (void)tearDown
{
    [super tearDown];
    
    [_helperMock stopMocking];
    _helperMock = nil;
}

- (void)testPushNoData
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"source": @"batch",
        @"medium": @"push"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testNotificationDeeplinkQueryVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_source=batchsdk&utm_medium=push-batch&utm_campaign=yoloswag&utm_content=button1";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"campaign": @"yoloswag",
        @"medium": @"push-batch",
        @"content": @"button1",
        @"source": @"batchsdk"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testNotificationDeeplinkQueryVarsEncode
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_source=%5Bbatchsdk%5D&utm_medium=push-batch&utm_campaign=yoloswag&utm_content=button1";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"campaign": @"yoloswag",
        @"medium": @"push-batch",
        @"content": @"button1",
        @"source": @"[batchsdk]"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testNotificationDeeplinkFragmentVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"campaign": @"154879548754",
        @"medium": @"pushbatch01",
        @"content": @"notif001",
        @"source": @"batch-sdk"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testNotificationDeeplinkNonTrimmed
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"    \n     https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001     \n    ";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"campaign": @"154879548754",
        @"medium": @"pushbatch01",
        @"content": @"notif001",
        @"source": @"batch-sdk"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testNotificationDeeplinkFragmentVarsEncode
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test#utm_source=%5Bbatch-sdk%5D&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"campaign": @"154879548754",
        @"medium": @"pushbatch01",
        @"content": @"notif001",
        @"source": @"[batch-sdk]"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testNotificationCustomPayload
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    testPayload.customPayload = @{
        @"utm_medium": @"654987",
        @"utm_source": @"jesuisuntest",
        @"utm_campaign": @"heinhein",
        @"utm_content": @"allo118218",
    };
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"medium": @"654987",
        @"source": @"jesuisuntest",
        @"campaign": @"heinhein",
        @"content": @"notif001",
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testNotificationDeeplinkPriority
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_source=batchsdk&utm_campaign=yoloswag#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    testPayload.customPayload = @{
        @"utm_medium": @"654987",
    };
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"medium": @"654987",
        @"source": @"batchsdk",
        @"campaign": @"yoloswag",
        @"content": @"notif001",
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testInAppNoData
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppShow andPayload:testPayload];
    
    NSString *expectedName = @"batch_in_app_show";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"source": @"batch",
        @"medium": @"in-app",
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testInAppTrackingID
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.trackingId = @"jesuisuntrackingid";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppShow andPayload:testPayload];
    
    NSString *expectedName = @"batch_in_app_show";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"campaign": @"jesuisuntrackingid",
        @"source": @"batch",
        @"medium": @"in-app",
        @"batch_tracking_id": @"jesuisuntrackingid"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testInAppDeeplinkContentQueryVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios?utm_content=yoloswag";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppClick andPayload:testPayload];
    
    NSString *expectedName = @"batch_in_app_click";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"source": @"batch",
        @"medium": @"in-app",
        @"content": @"yoloswag"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testInAppDeeplinkContentQueryVarsUppercase
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios?UtM_coNTEnt=yoloswag";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppClick andPayload:testPayload];
    
    NSString *expectedName = @"batch_in_app_click";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"source": @"batch",
        @"medium": @"in-app",
        @"content": @"yoloswag"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}


- (void)testInAppDeeplinkFragmentQueryVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios#utm_content=yoloswag2";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppClick andPayload:testPayload];
    
    NSString *expectedName = @"batch_in_app_click";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"source": @"batch",
        @"medium": @"in-app",
        @"content": @"yoloswag2"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testInAppDeeplinkFragmentQueryVarsUppercase
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios#uTm_CoNtEnT=yoloswag2";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppClick andPayload:testPayload];
    
    NSString *expectedName = @"batch_in_app_click";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"source": @"batch",
        @"medium": @"in-app",
        @"content": @"yoloswag2"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testInAppDeeplinkContentPriority
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios?utm_content=testprio#utm_content=yoloswag2";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppClose andPayload:testPayload];
    
    NSString *expectedName = @"batch_in_app_close";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"source": @"batch",
        @"medium": @"in-app",
        @"content": @"testprio"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

- (void)testInAppDeeplinkContentNoId
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_content=jesuisuncontent";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppClose andPayload:testPayload];
    
    NSString *expectedName = @"batch_in_app_close";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"source": @"batch",
        @"medium": @"in-app",
        @"content": @"jesuisuncontent"
    };
    OCMVerify([_helperMock logEventWithName:expectedName parameters:expectedParameters]);
}

@end
