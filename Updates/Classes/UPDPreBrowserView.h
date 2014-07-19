//
//  UPDPreBrowserView.h
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDPreBrowserView : UIView

@property (nonatomic, copy) void(^backButtonBlock)();

- (void)setGoButtonBlock:(void (^)(NSString *))goButtonBlock;

@end
