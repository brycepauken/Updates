//
//  UPDTimer.m
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 A timer class to time how long it takes the user to create
 a new update. Not the most reusable class in the world (heck,
 it's not even an object), but works well for our one-use-at-a-time
 purpose.
 */

#import "UPDTimer.h"

NSTimeInterval _seconds;
NSDate *_startDate;

@implementation UPDTimer

+ (void)pauseTimer {
    if(_startDate) {
        _seconds += [[NSDate date] timeIntervalSinceDate:_startDate];
        _startDate = nil;
    }
}

+ (void)resumeTimer {
    if(_seconds>0 && _startDate == nil) {
        _startDate = [NSDate date];
    }
}

+ (void)startTimer {
    _seconds = 0;
    _startDate = [NSDate date];
}

+ (NSTimeInterval)stopTimer {
    if(_startDate) {
        _seconds += [[NSDate date] timeIntervalSinceDate:_startDate];
        _startDate = nil;
    }
    return _seconds;
}

@end
