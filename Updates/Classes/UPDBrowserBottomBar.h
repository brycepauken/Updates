//
//  UPDBrowserBottomBar.h
//  Updates
//
//  Created by Bryce Pauken on 5/18/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDBrowserBottomBar : UIView

@property (nonatomic, retain) UIButton *finishButton;
@property (nonatomic, copy) void (^finishButtonBlock)();

@end
