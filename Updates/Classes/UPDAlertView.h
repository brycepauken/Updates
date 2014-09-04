//
//  UPDAlertView.h
//  Updates
//
//  Created by Bryce Pauken on 7/19/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDAlertView : UIView <UITextFieldDelegate>

@property (nonatomic, copy) void (^cancelButtonBlock)();
@property (nonatomic, strong) NSString *message;
@property (nonatomic) int minTextLength;
@property (nonatomic, copy) void (^noButtonBlock)();
@property (nonatomic, copy) void (^okButtonBlock)();
@property (nonatomic, copy) void (^textSubmitBlock)(NSString *text);
@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) void (^yesButtonBlock)();

- (void)dismiss;
- (void)setFontSize:(CGFloat)fontSize;
- (void)setOkButtonTitle:(NSString *)okButtonTitle;
- (void)show;

@end
