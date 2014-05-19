//
//  UPDViewController.h
//  Update
//
//  Created by Bryce Pauken on 5/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UPDInterface;

@interface UPDViewController : UIViewController

@property (nonatomic, retain) UPDInterface *interface;
@property (nonatomic) BOOL hideStatusBar;
@property (nonatomic) BOOL lightStatusBarContent;

@end
