//
//  UPDInterface.h
//  Update
//
//  Created by Bryce Pauken on 5/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UPDBrowserView;
@class UPDNavigationBar;
@class UPDTableViewContoller;

@interface UPDInterface : UIView

@property (nonatomic, retain) UPDBrowserView *browserView;
@property (nonatomic, retain) UIView *divider;
@property (nonatomic, retain) UPDNavigationBar *navigationBar;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UPDTableViewContoller *tableViewController;
@property (nonatomic, retain) UIScrollView *scrollView;

@end
