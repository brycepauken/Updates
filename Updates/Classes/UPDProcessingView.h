//
//  UPDProcessingView.h
//  Updates
//
//  Created by Bryce Pauken on 7/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDProcessingView : UIView <UITextFieldDelegate>

@property (nonatomic, copy) void(^completionBlock)(NSString *name, NSURL *url, NSArray *instructions, UIImage *favicon, NSString *lastResponse, NSDictionary *differenceOptions, NSTimeInterval timerResult, NSDate *origDate, BOOL locked);
@property (nonatomic, copy) void(^errorBlock)();

- (void)beginProcessingAnimation;
- (void)processInstructions:(NSArray *)instructions forURL:(NSString *)url withFinalResponse:(NSString *)finalResponse withTimerResult:(NSTimeInterval)timerResult withOrigDate:(NSDate *)origDate;

@end
