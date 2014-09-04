//
//  UPDHelpView.h
//  Updates
//
//  Created by Bryce Pauken on 8/14/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDHelpView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) void (^closeButtonBlock)();

- (void)dismiss;
- (void)show;

@end
