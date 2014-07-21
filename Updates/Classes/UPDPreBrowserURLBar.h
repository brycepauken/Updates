//
//  UPDPreBrowserURLBar.h
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDPreBrowserURLBar : UIView <UITextFieldDelegate>

@property (nonatomic, copy) void(^goButtonBlock)(NSString *url);

- (void)setText:(NSString *)text;
- (void)textFieldDidChange;

@end
