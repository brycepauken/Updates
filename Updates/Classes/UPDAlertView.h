//
//  UPDAlertView.h
//  Updates
//
//  Created by Bryce Pauken on 7/19/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDAlertView : UIView

@property (nonatomic, strong) NSString *message;
@property (nonatomic, copy) void (^noButtonBlock)();
@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) void (^yesButtonBlock)();

- (void)dismiss;
- (void)show;

@end
