//
//  UPDInterface.m
//  Updates
//
//  Created by Bryce Pauken on 7/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 The interface view contains a single scrollview used to move around
 the application for a paging effect. This scollview houses both
 the main table view and the web view.
 */

#import "UPDInterface.h"

#import "QuartzCore/CALayer.h"
#import "UPDNavigationBar.h"
#import "UPDPreBrowserView.h"
#import "UPDTableView.h"

@interface UPDInterface ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UPDNavigationBar *navigationBar;
@property (nonatomic, strong) UPDPreBrowserView *preBrowserView;
@property (nonatomic, strong) UPDTableView *tableView;

@end

@implementation UPDInterface

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width*3, 0)];
        [self.scrollView setScrollEnabled:NO];
        [self.scrollView setScrollsToTop:NO];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self.scrollView setTag:0];
        [self addSubview:self.scrollView];
        
        __unsafe_unretained UPDInterface *weakSelf = self;
        self.navigationBar = [[UPDNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, UPD_NAVIGATION_BAR_HEIGHT)];
        [self.navigationBar setAddButtonBlock:^{
            [weakSelf.scrollView setTag:1];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
               [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.scrollView.bounds.size.width, 0)];
            }];
        }];
        [self.navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.scrollView addSubview:self.navigationBar];
        
        self.tableView = [[UPDTableView alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height-UPD_NAVIGATION_BAR_HEIGHT)];
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.scrollView addSubview:self.tableView];
        
        self.preBrowserView = [[UPDPreBrowserView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        [self.preBrowserView setBackButtonBlock:^{
            [weakSelf.scrollView setTag:0];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.scrollView setContentOffset:CGPointZero];
            }];
        }];
        [self.scrollView addSubview:self.preBrowserView];
        
        [self setNeedsDisplay];
    }
    return self;
}

- (void)layoutSubviews {
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width*3, 0)];
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*self.scrollView.tag, 0)];
    [self.preBrowserView setFrame:CGRectMake(self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
}

@end
