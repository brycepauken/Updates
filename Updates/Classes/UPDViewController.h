//
//  UPDViewController.h
//  Updates
//
//  Created by Bryce Pauken on 7/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UPDInterface;

@interface UPDViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL hideStatusBar;
@property (nonatomic, strong) UPDInterface *interface;
@property (nonatomic) BOOL registersTaps;

@end
