//
//  UPDSwitch.h
//  Updates
//
//  Created by Bryce Pauken on 8/8/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDSwitch : UIView

@property (nonatomic, copy) void (^toggleBlock)(BOOL on);

- (void)setEnabled:(BOOL)enabled;
- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
