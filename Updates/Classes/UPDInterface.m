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
#import "UPDBrowserView.h"
#import "UPDNavigationBar.h"
#import "UPDPreBrowserView.h"
#import "UPDPreProcessingView.h"
#import "UPDProcessingView.h"
#import "UPDTableView.h"

@interface UPDInterface ()

@property (nonatomic, strong) UPDBrowserView *browserView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UPDNavigationBar *navigationBar;
@property (nonatomic, strong) UPDPreBrowserView *preBrowserView;
@property (nonatomic, strong) UPDPreProcessingView *preProcessingView;
@property (nonatomic, strong) UPDProcessingView *processingView;
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
            [weakSelf.preBrowserView reset];
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
        [self.preBrowserView setGoButtonBlock:^(NSString *url){
            [weakSelf.browserView beginSession];
            [weakSelf.browserView loadURL:url];
            [weakSelf.scrollView setTag:2];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.scrollView.bounds.size.width*2, 0)];
            }];
        }];
        
        [self.scrollView addSubview:self.preBrowserView];
        
        self.browserView = [[UPDBrowserView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.size.width*2, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        [self.browserView setTag:2]; /*what page of the scollview the browser should be on*/
        [self.browserView setCancelSessionBlock:^{
            /*move browser view over for a more seamless animation*/
            [weakSelf.browserView setTag:1];
            [weakSelf.browserView setFrame:CGRectMake(weakSelf.scrollView.bounds.size.width, 0, weakSelf.scrollView.bounds.size.width, weakSelf.scrollView.bounds.size.height)];
            [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.scrollView.bounds.size.width, 0)];
            
            [weakSelf.scrollView setTag:0];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.scrollView setContentOffset:CGPointZero];
            } completion:^(BOOL finsished) {
                [weakSelf.browserView setTag:2];
                [weakSelf.browserView setFrame:CGRectMake(weakSelf.scrollView.bounds.size.width*2, 0, weakSelf.scrollView.bounds.size.width, weakSelf.scrollView.bounds.size.height)];
            }];
        }];
        [self.browserView setConfirmBlock:^(UIImage *browserImage, NSArray *instructions){
            [weakSelf.preProcessingView setHidden:NO];
            [weakSelf.preProcessingView beginPreProcessingWithBrowserImage:browserImage];
            [weakSelf.processingView processInstructions:instructions];
        }];
        [self.scrollView addSubview:self.browserView];
        
        self.preProcessingView = [[UPDPreProcessingView alloc] initWithFrame:self.bounds];
        [self.preProcessingView setHidden:YES];
        [self.preProcessingView setCompletionBlock:^{
            [weakSelf.processingView setHidden:NO];
            [weakSelf.processingView beginProcessingAnimation];
        }];
        
        [self.scrollView addSubview:self.preProcessingView];
        
        self.processingView = [[UPDProcessingView alloc] initWithFrame:self.bounds];
        [self.processingView setHidden:YES];
        [self.processingView setTag:2]; /*what page of the scollview the browser should be on*/
        [self.processingView setCompletionBlock:^(NSArray *instructions){
            /*move browser view over for a more seamless animation*/
            [weakSelf.processingView setTag:1];
            [weakSelf.processingView setFrame:CGRectMake(weakSelf.scrollView.bounds.size.width, 0, weakSelf.scrollView.bounds.size.width, weakSelf.scrollView.bounds.size.height)];
            [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.scrollView.bounds.size.width, 0)];
            
            [weakSelf.scrollView setTag:0];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.scrollView setContentOffset:CGPointZero];
            } completion:^(BOOL finsished) {
                [weakSelf.processingView setTag:2];
                [weakSelf.processingView setFrame:CGRectMake(weakSelf.scrollView.bounds.size.width*2, 0, weakSelf.scrollView.bounds.size.width, weakSelf.scrollView.bounds.size.height)];
                
                [weakSelf.preProcessingView setHidden:YES];
                [weakSelf.processingView setHidden:YES];
            }];
        }];
        [self.scrollView addSubview:self.processingView];
        
        [self setNeedsDisplay];
    }
    return self;
}

- (void)layoutSubviews {
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width*3, 0)];
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*self.scrollView.tag, 0)];
    [self.preBrowserView setFrame:CGRectMake(self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    [self.browserView setFrame:CGRectMake(self.scrollView.bounds.size.width*self.browserView.tag, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    [self.preProcessingView setFrame:CGRectMake(self.scrollView.bounds.size.width*2, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    [self.processingView setFrame:CGRectMake(self.scrollView.bounds.size.width*self.browserView.tag, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
}

@end
