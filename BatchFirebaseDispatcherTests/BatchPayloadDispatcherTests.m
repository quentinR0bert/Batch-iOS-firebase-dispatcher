//
//  BatchPayloadDispatcherTests.m
//  Batch-Firebase-Dispatcher_Tests
//
//  Created by Elliot Gouy on 23/10/2019.
//  Copyright © 2019 elliot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BatchPayloadDispatcherTests.h"

@implementation BatchPayloadDispatcherTest

@synthesize notificationUserInfo;
@synthesize sourceMessage;

- (nullable NSObject *)customValueForKey:(nonnull NSString *)key {
    if (self.customPayload != nil) {
        return [self.customPayload objectForKey:key];
    }
    return nil;
}

@end
