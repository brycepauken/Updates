//
//  UPDNavigationBar.h
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDNavigationBar : UIView

@property (nonatomic, copy) void(^addButtonBlock)();
@property (nonatomic, copy) void(^backButtonBlock)();
@property (nonatomic, copy) void(^settingsButtonBlock)();

- (void)setLabelFont:(UIFont *)font;
- (void)setText:(NSString *)text;

@end
