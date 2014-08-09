//
//  UPDStartingView.h
//  Updates
//
//  Created by Bryce Pauken on 8/8/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDStartView : UIView <UIScrollViewDelegate>

@property (nonatomic, copy) void (^okButtonBlock)();

- (void)dismiss;
- (void)show;

@end
