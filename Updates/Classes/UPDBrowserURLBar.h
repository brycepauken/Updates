//
//  UPDBrowserURLBar.h
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDBrowserURLBar : UIView <UITextFieldDelegate>

@property (nonatomic, copy) void(^goButtonBlock)(NSString *url);

- (void)setText:(NSString *)text;

- (void)progressBarAnimateToWidth:(CGFloat)width withDuration:(CGFloat)duration onCompletion:(void (^)(BOOL finished))completion;
- (BOOL)progressBarVisible;
- (void)resetProgressBar;
- (void)resetProgressBarWithFade:(BOOL)fade;

@end
