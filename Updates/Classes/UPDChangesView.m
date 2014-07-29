//
//  UPDChangesView.m
//  Updates
//
//  Created by Bryce Pauken on 7/27/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDChangesView.h"

#import "UPDBrowserBottomBar.h"
#import "UPDDocumentComparator.h"
#import "UPDInternalUpdate.h"
#import "UPDNavigationBar.h"

#import "UPDURLProtocol.h"

@interface UPDChangesView()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UPDBrowserBottomBar *bottomBar;
@property (nonatomic, strong) UPDInternalUpdate *update;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation UPDChangesView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        
        __unsafe_unretained UPDChangesView *weakSelf = self;
        self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(UPD_NAVIGATION_BAR_BUTTON_PADDING, 20+((UPD_NAVIGATION_BAR_HEIGHT-20)-UPD_NAVIGATION_BAR_BUTTON_SIZE)/2, UPD_NAVIGATION_BAR_BUTTON_SIZE, UPD_NAVIGATION_BAR_BUTTON_SIZE)];
        [self.backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [self.backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
        [self addSubview:self.backButton];
        
        self.bottomBar = [[UPDBrowserBottomBar alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-(UPD_NAVIGATION_BAR_HEIGHT-20), self.bounds.size.width, UPD_NAVIGATION_BAR_HEIGHT-20) buttonNames:@[@"Back",@"Forward"]];
        [self.bottomBar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [self.bottomBar setBlockForButtonWithName:@"Back" block:^{
            if(weakSelf.webView.canGoBack) {
                [weakSelf.webView goBack];
            }
        }];
        [self.bottomBar setBlockForButtonWithName:@"Forward" block:^{
            if(weakSelf.webView.canGoForward) {
                [weakSelf.webView goForward];
            }
        }];
        [self addSubview:self.bottomBar];
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, UPD_NAVIGATION_BAR_HEIGHT, self.bounds.size.width, self.bounds.size.height-UPD_NAVIGATION_BAR_HEIGHT-self.bottomBar.bounds.size.height)];
        [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.webView setDelegate:self];
        [self addSubview:self.webView];
    }
    return self;
}

- (void)backButtonTapped {
    if(self.backButtonBlock) {
        self.backButtonBlock();
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(CGRectContainsPoint(CGRectInset(self.backButton.frame, -self.backButton.frame.size.width, -self.backButton.frame.size.height), point)) {
        return self.backButton;
    }
    return [super hitTest:point withEvent:event];
}

- (void)showUpdate:(UPDInternalUpdate *)update {
    self.update = update;
    if(update.lastResponse == nil) {
        [self.webView loadHTMLString:[NSKeyedUnarchiver unarchiveObjectWithData:update.origResponse] baseURL:[NSKeyedUnarchiver unarchiveObjectWithData:update.url]];
    }
    else {
        NSString *highlightedPage = [UPDDocumentComparator document:[NSKeyedUnarchiver unarchiveObjectWithData:update.lastResponse] compareTextWithDocument:[NSKeyedUnarchiver unarchiveObjectWithData:update.origResponse] highlightChanges:YES];
        [self.webView loadHTMLString:highlightedPage baseURL:[NSKeyedUnarchiver unarchiveObjectWithData:update.url]];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.bottomBar setButtonEnabledWithName:@"Back" enabled:[webView canGoBack]];
    [self.bottomBar setButtonEnabledWithName:@"Forward" enabled:[webView canGoForward]];
}

@end
