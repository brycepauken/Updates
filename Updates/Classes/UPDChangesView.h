//
//  UPDChangesView.h
//  Updates
//
//  Created by Bryce Pauken on 7/27/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UPDInternalUpdate;

@interface UPDChangesView : UIView <UIWebViewDelegate>

@property (nonatomic, copy) void(^backButtonBlock)(UPDInternalUpdate *update);

- (void)showUpdate:(UPDInternalUpdate *)update;

@end
