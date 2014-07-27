//
//  UPDTimer.h
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDTimer : NSObject

+ (void)pauseTimer;
+ (void)resumeTimer;
+ (void)startTimer;
+ (NSTimeInterval)stopTimer;

@end
