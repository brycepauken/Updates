//
//  UPDChangesView.m
//  Updates
//
//  Created by Bryce Pauken on 7/27/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDChangesView.h"

#import "NSData+UPDExtensions.h"
#import "NSDate+UPDExtensions.h"
#import "UPDBrowserBottomBar.h"
#import "UPDDocumentComparator.h"
#import "UPDInternalUpdate.h"
#import "UPDNavigationBar.h"

@interface UPDChangesView()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UPDBrowserBottomBar *bottomBar;
@property (nonatomic, strong) UPDNavigationBar *navigationBar;
@property (nonatomic, strong) UPDInternalUpdate *update;
@property (nonatomic, strong) NSDate *updatedDate;
@property (nonatomic, strong) UILabel *updatedLabel;
@property (nonatomic, strong) NSTimer *updatedLabelTimer;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation UPDChangesView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        
        __unsafe_unretained UPDChangesView *weakSelf = self;
        self.navigationBar = [[UPDNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, UPD_NAVIGATION_BAR_HEIGHT)];
        [self.navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.navigationBar setLabelFont:[UIFont systemFontOfSize:22]];
        [self.navigationBar setBackButtonBlock:^{
            if(weakSelf.backButtonBlock) {
                weakSelf.backButtonBlock(weakSelf.update);
            }
        }];
        [self addSubview:self.navigationBar];
        
        self.updatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, UPD_NAVIGATION_BAR_HEIGHT-5, self.bounds.size.width-20, 25)];
        [self.updatedLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.updatedLabel setFont:[UIFont systemFontOfSize:13]];
        [self.updatedLabel setText:@"This is the current page as of 59 minutes ago"];
        [self.updatedLabel setTextAlignment:NSTextAlignmentCenter];
        [self.updatedLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.updatedLabel];
        
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
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, UPD_NAVIGATION_BAR_HEIGHT+20, self.bounds.size.width, self.bounds.size.height-UPD_NAVIGATION_BAR_HEIGHT-20-self.bottomBar.bounds.size.height)];
        [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.webView setDelegate:self];
        [self.webView setScalesPageToFit:YES];
        [self addSubview:self.webView];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(CGRectContainsPoint(CGRectInset(self.backButton.frame, -self.backButton.frame.size.width, -self.backButton.frame.size.height), point)) {
        return self.backButton;
    }
    return [super hitTest:point withEvent:event];
}

- (void)setUpdatedDate:(NSDate *)updatedDate {
    if(![_updatedDate isEqualToDate:updatedDate]) {
        _updatedDate = updatedDate;
        if(self.updatedLabelTimer) {
            [self.updatedLabelTimer invalidate];
        }
        [self setUpdatedLabelTimer:[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateDateText) userInfo:nil repeats:YES]];
        [self updateDateText];
    }
}

- (void)showUpdate:(UPDInternalUpdate *)update {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    self.update = update;
    [self.navigationBar setText:update.name];
    void (^completionBlock)(NSDictionary *differenceOptions, NSString *key) = ^(NSDictionary *differenceOptions, NSString *key) {
        if(update.lastResponse == nil || [[differenceOptions objectForKey:@"DifferenceType"] isEqualToString:@"Text"]) {
            [self setUpdatedDate:update.origUpdated];
            if(key.length) {
                [self.webView loadHTMLString:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData decryptData:update.origResponse withKey:key]] baseURL:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData decryptData:update.url withKey:key]]];
            }
            else {
                [self.webView loadHTMLString:[NSKeyedUnarchiver unarchiveObjectWithData:update.origResponse] baseURL:[NSKeyedUnarchiver unarchiveObjectWithData:update.url]];
            }
        }
        else {
            [self setUpdatedDate:update.lastUpdated];
            if(key.length) {
                NSString *highlightedPage = [UPDDocumentComparator document:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData decryptData:update.lastResponse withKey:key]] compareTextWithDocument:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData decryptData:update.origResponse withKey:key]] highlightChanges:YES];
                [self.webView loadHTMLString:highlightedPage baseURL:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData decryptData:update.url withKey:key]]];
            }
            else {
                NSString *highlightedPage = [UPDDocumentComparator document:[NSKeyedUnarchiver unarchiveObjectWithData:update.lastResponse] compareTextWithDocument:[NSKeyedUnarchiver unarchiveObjectWithData:update.origResponse] highlightChanges:YES];
                [self.webView loadHTMLString:highlightedPage baseURL:[NSKeyedUnarchiver unarchiveObjectWithData:update.url]];
            }
        }
    };
    if(update.locked.boolValue) {
        void (^passwordBlock)(NSString *pass) = ^(NSString *pass){
            completionBlock([NSKeyedUnarchiver unarchiveObjectWithData:[NSData decryptData:update.differenceOptions withKey:pass]], pass);
        };
        NSString *encryptedPass = [UPDCommon getEncryptedPassword:^(NSString *encryptedPassword){
            if(encryptedPassword.length) {
                passwordBlock(encryptedPassword);
            }
        }];
        if(encryptedPass.length) {
            passwordBlock(encryptedPass);
        }
    }
    else {
        completionBlock([NSKeyedUnarchiver unarchiveObjectWithData:update.differenceOptions], nil);
    }
}

- (void)updateDateText {
    if(self.updatedDate && [self.updatedDate timeIntervalSince1970]>0) {
        [self.updatedLabel setText:[NSString stringWithFormat:@"This is the current page as of %@",[self.updatedDate relativeDateFromDate:[NSDate date]]]];
    }
    else {
        [self.updatedLabel setText:@"Never updated"];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.bottomBar setButtonEnabledWithName:@"Back" enabled:[webView canGoBack]];
    [self.bottomBar setButtonEnabledWithName:@"Forward" enabled:[webView canGoForward]];
}

@end
