//
//  UPDSettingsView.h
//  Updates
//
//  Created by Bryce Pauken on 8/8/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface UPDSettingsView : UIView <MFMailComposeViewControllerDelegate>

@property (nonatomic, copy) void (^closeButtonBlock)();

- (void)dismiss;
- (void)show;

@end
