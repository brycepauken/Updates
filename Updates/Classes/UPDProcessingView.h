//
//  UPDProcessingView.h
//  Updates
//
//  Created by Bryce Pauken on 7/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDProcessingView : UIView <UITextFieldDelegate>

@property (nonatomic, copy) void(^completionBlock)(NSString *name, NSArray *instructions, UIImage *favicon, NSString *lastReponse, NSDictionary *differenceOptions);

- (void)beginProcessingAnimation;
- (void)processInstructions:(NSArray *)instructions;

@end
