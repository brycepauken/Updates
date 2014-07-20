//
//  UPDBrowserView.m
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 The browser view houses everything needed to webbrowse—
 the actual UIWebView, along with top and bottom bars for
 navigation. It also handles a bit of the browsing logic,
 particularly around whether a given string is a URL or a
 search query.
 */

#import "UPDBrowserView.h"

#import "UPDBrowserBottomBar.h"
#import "UPDBrowserURLBar.h"
#import "UPDInstructionAccumulator.h"
#import "UPDURLProtocol.h"

@interface UPDBrowserView()

@property (nonatomic, strong) UPDBrowserBottomBar *bottomBar;
@property (nonatomic, strong) UIView *browserOverlay;
@property (nonatomic, strong) UPDInstructionAccumulator *instructionAccumulator;
@property (nonatomic, strong) UPDBrowserURLBar *urlBar;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation UPDBrowserView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setBackgroundColor:[UIColor UPDOffWhiteColor]];
        
        __unsafe_unretained UPDBrowserView *weakSelf = self;
        self.urlBar = [[UPDBrowserURLBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, UPD_NAVIGATION_BAR_HEIGHT+2)];
        [self.urlBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.urlBar setBeginEditingBlock:^{
            [weakSelf.browserOverlay setUserInteractionEnabled:YES];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.browserOverlay setAlpha:0.5];
            }];
        }];
        [self.urlBar setEndEditingBlock:^{
            [weakSelf browserOverlayTapped];
        }];
        [self addSubview:self.urlBar];
        
        self.bottomBar = [[UPDBrowserBottomBar alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-(UPD_NAVIGATION_BAR_HEIGHT-20), self.bounds.size.width, UPD_NAVIGATION_BAR_HEIGHT-20)];
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
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.urlBar.frame.size.height, self.bounds.size.width, self.bounds.size.height-self.urlBar.frame.size.height-self.bottomBar.frame.size.height)];
        [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.webView setDelegate:self];
        [self addSubview:self.webView];
        
        self.browserOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, self.urlBar.bounds.size.height, self.bounds.size.width, self.bounds.size.height-self.urlBar.bounds.size.height)];
        [self.browserOverlay setAlpha:0];
        [self.browserOverlay setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.browserOverlay setBackgroundColor:[UIColor UPDOffBlackColor]];
        [self.browserOverlay setUserInteractionEnabled:NO];
        [self addSubview:self.browserOverlay];
        UITapGestureRecognizer *browserOverlayTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(browserOverlayTapped)];
        [self.browserOverlay addGestureRecognizer:browserOverlayTapRecognizer];
    }
    return self;
}

/*
 Clear the cache and cookies, then register our custom
 url protocol to handle new requests and forward them
 to our accumulator
 */
- (void)beginSession {
    [self clearPersistentData];
    self.instructionAccumulator = [[UPDInstructionAccumulator alloc] init];
    [UPDURLProtocol setInstructionAccumulator:self.instructionAccumulator];
    [NSURLProtocol registerClass:[UPDURLProtocol class]];
}

- (void)browserOverlayTapped {
    [self.urlBar resignFirstResponder];
    [self.browserOverlay setUserInteractionEnabled:NO];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.browserOverlay setAlpha:0];
    }];
}

/*
 Clears cookies and the cache—important for making sure a request
 can be duplicated every time.
 */
- (void)clearPersistentData {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 Contrary to this method's name, loadURL accepts any string as
 input, and then checks to see if it's a URL. If it's not, then
 it performs a search instead.
 */
- (void)loadURL:(NSString *)url {
    NSURL *checkURL = [NSURL URLWithString:url];
    if((!checkURL || !checkURL.scheme || !checkURL.host) && ([url length]<7 || ![[url substringToIndex:7] isEqualToString:@"http://"])) {
        NSUInteger slashLoc = [url rangeOfString:@"/"].location;
        NSString *baseURL = slashLoc==NSNotFound?url:[url substringToIndex:slashLoc];
        if([baseURL rangeOfString:@"." options:NSBackwardsSearch].location!=NSNotFound && [baseURL rangeOfString:@"." options:NSBackwardsSearch].location!=baseURL.length-1 && [baseURL rangeOfString:@". " options:NSBackwardsSearch].location==NSNotFound) {
            checkURL = [NSURL URLWithString:[@"http://" stringByAppendingString:url]];
        }
    }
    if(!checkURL || !checkURL.scheme || !checkURL.host) {
        checkURL = [NSURL URLWithString:[@"http://www.google.com/search?sourceid=chrome&ie=UTF-8&q=" stringByAppendingString:[[url stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    [self.urlBar setText:checkURL.absoluteString];
    [self.urlBar resetProgressBarWithFade:NO];
    [self.urlBar progressBarAnimateToWidth:0.9 withDuration:5 onCompletion:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:checkURL]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(!self.urlBar.progressBarVisible) {
        [self.urlBar progressBarAnimateToWidth:0.9 withDuration:5 onCompletion:nil];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.urlBar setText:webView.request.mainDocumentURL.absoluteString];
    [self.urlBar progressBarAnimateToWidth:1 withDuration:0.3 onCompletion:^(BOOL finished) {
        [self.urlBar performSelector:@selector(resetProgressBar) withObject:nil afterDelay:0.5];
    }];
    [self.bottomBar setButtonEnabledWithName:@"Back" enabled:[webView canGoBack]];
    [self.bottomBar setButtonEnabledWithName:@"Forward" enabled:[webView canGoForward]];
}


@end
