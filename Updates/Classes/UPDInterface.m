//
//  UPDInterface.m
//  Update
//
//  Created by Bryce Pauken on 5/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDInterface.h"

#import "UPDBrowserView.h"
#import "UPDNavigationBar.h"
#import "UPDTableViewContoller.h"

@implementation UPDInterface

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.scrollView setScrollEnabled:NO];
        [self.scrollView setScrollsToTop:NO];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:self.scrollView];
        
        self.divider = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width, 0, 1, self.bounds.size.height)];
        [self.divider setBackgroundColor:[UIColor lightGrayColor]];
        [self.scrollView addSubview:self.divider];
        
        CGFloat navigationBarHeight = UPD_NAVIGATION_BAR_HEIGHT+([UPDCommon isIOS7]?20:0);
        self.navigationBar = [[UPDNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, navigationBarHeight)];
        [self.navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.scrollView addSubview:self.navigationBar];
        
        __weak UPDInterface *weakSelf = self;
        self.tableViewController = [[UPDTableViewContoller alloc] initWithAddBlock:^{
            [weakSelf startBrowsing];
        }];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.bounds.size.width, self.bounds.size.height-navigationBarHeight)];
        [self.tableView setDelegate:self.tableViewController];
        [self.tableView setDataSource:self.tableViewController];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.scrollView addSubview:self.tableView];
        
        self.browserView = [[UPDBrowserView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.size.width+1, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:self.browserView];
        
        [self setNeedsLayout];
    }
    return self;
}

- (void)layoutSubviews {
    [self.scrollView setContentSize:CGSizeMake(self.bounds.size.width*2+1, self.bounds.size.height)];
    [self.divider setFrame:CGRectMake(self.bounds.size.width, 0, 1, self.bounds.size.height)];
    
    CGFloat navigationBarHeight = UPD_NAVIGATION_BAR_HEIGHT+([UPDCommon isIOS7]?20:0);
    [self.tableView setFrame:CGRectMake(0, navigationBarHeight, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height-navigationBarHeight)];
    [self.browserView setFrame:CGRectMake(self.scrollView.bounds.size.width+1, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    
    [self updateScrollViewContentOffset];
}

- (void)startBrowsing {
    [self.scrollView setTag:1];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self updateScrollViewContentOffset];
    }];
    
    [AppDelegate.viewController setHideStatusBar:YES];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION/2.0f animations:^{
        [AppDelegate.viewController setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        [AppDelegate.viewController setHideStatusBar:NO];
        [AppDelegate.viewController setLightStatusBarContent:YES];
        [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
            [AppDelegate.viewController setNeedsStatusBarAppearanceUpdate];
        }];
    }];
}

- (void)updateScrollViewContentOffset {
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.tag*self.scrollView.bounds.size.width+self.scrollView.tag, 0)];
}

@end
