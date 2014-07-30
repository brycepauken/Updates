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

#import "UPDAlertView.h"
#import "UPDBrowserBottomBar.h"
#import "UPDBrowserCancelButton.h"
#import "UPDBrowserConfirmButton.h"
#import "UPDBrowserURLBar.h"
#import "UPDInstructionAccumulator.h"
#import "UPDTimer.h"
#import "UPDURLProtocol.h"

@interface UPDBrowserView()

@property (nonatomic, strong) UPDBrowserBottomBar *bottomBar;
@property (nonatomic, strong) UIView *browserOverlay;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UILabel *confirmLabel;
@property (nonatomic, strong) UPDInstructionAccumulator *instructionAccumulator;
@property (nonatomic, strong) UPDBrowserURLBar *urlBar;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *completeOverlay;

@end

@implementation UPDBrowserView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        
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
        [self.urlBar setGoButtonBlock:^(NSString *url){
            [weakSelf loadURL:url];
        }];
        [self addSubview:self.urlBar];
        
        self.bottomBar = [[UPDBrowserBottomBar alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-(UPD_NAVIGATION_BAR_HEIGHT-20), self.bounds.size.width, UPD_NAVIGATION_BAR_HEIGHT-20) buttonNames:@[@"Cancel",@"Back",@"Forward",@"Accept"]];
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
        [self.bottomBar setBlockForButtonWithName:@"Cancel" block:^{
            [UPDTimer pauseTimer];
            UPDAlertView *alertView = [[UPDAlertView alloc] init];
            __unsafe_unretained UPDAlertView *weakAlertView = alertView;
            [alertView setTitle:@"Cancel"];
            [alertView setMessage:@"Are you sure you want to cancel the current update?\n\nNo progress will be saved."];
            [alertView setNoButtonBlock:^{
                [UPDTimer resumeTimer];
                [weakAlertView dismiss];
            }];
            [alertView setYesButtonBlock:^{
                [UPDTimer stopTimer];
                [weakAlertView dismiss];
                [weakSelf cancelSession];
            }];
            [alertView show];
        }];
        [self.bottomBar setBlockForButtonWithName:@"Accept" block:^{
            [UPDTimer pauseTimer];
            [weakSelf.completeOverlay setUserInteractionEnabled:YES];
            [weakSelf bringSubviewToFront:weakSelf.completeOverlay];
            [weakSelf bringSubviewToFront:weakSelf.confirmLabel];
            [weakSelf bringSubviewToFront:weakSelf.cancelButton];
            [weakSelf bringSubviewToFront:weakSelf.confirmButton];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.completeOverlay setAlpha:0.9];
                [weakSelf.cancelButton setAlpha:1];
                [weakSelf.confirmButton setAlpha:1];
                [weakSelf.confirmLabel setAlpha:1];
            } completion:^(BOOL finished) {
                [weakSelf.confirmButton setUserInteractionEnabled:YES];
                [weakSelf.cancelButton setUserInteractionEnabled:YES];
            }];
            
        }];
        [self addSubview:self.bottomBar];
        
        self.browserOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, self.urlBar.bounds.size.height, self.bounds.size.width, self.bounds.size.height-self.urlBar.bounds.size.height)];
        [self.browserOverlay setAlpha:0];
        [self.browserOverlay setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.browserOverlay setBackgroundColor:[UIColor UPDOffBlackColor]];
        [self.browserOverlay setUserInteractionEnabled:NO];
        [self addSubview:self.browserOverlay];
        UITapGestureRecognizer *browserOverlayTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(browserOverlayTapped)];
        [self.browserOverlay addGestureRecognizer:browserOverlayTapRecognizer];
        
        self.completeOverlay = [[UIView alloc] initWithFrame:self.bounds];
        [self.completeOverlay setAlpha:0];
        [self.completeOverlay setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.completeOverlay setBackgroundColor:[UIColor UPDOffBlackColor]];
        [self.completeOverlay setUserInteractionEnabled:NO];
        [self addSubview:self.completeOverlay];
        
        self.confirmLabel = [[UILabel alloc] init];
        [self.confirmLabel setAlpha:0];
        [self.confirmLabel setFont:[UIFont boldSystemFontOfSize:22]];
        [self.confirmLabel setNumberOfLines:0];
        [self.confirmLabel setText:@"Would you like to watch\nthis page for updates?"];
        [self.confirmLabel setText:@"Is this the page you would\nlike to watch for updates?"];
        [self.confirmLabel setTextAlignment:NSTextAlignmentCenter];
        [self.confirmLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.confirmLabel];
        
        self.confirmButton = [[UPDBrowserConfirmButton alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE)];
        [self.confirmButton addTarget:self action:@selector(confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.confirmButton setAlpha:0];
        [self.confirmButton setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.confirmButton setUserInteractionEnabled:NO];
        [self addSubview:self.confirmButton];
        
        self.cancelButton = [[UPDBrowserCancelButton alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE/2)/2, self.confirmButton.frame.origin.y+self.confirmButton.frame.size.height+10, UPD_CONFIRM_BUTTON_SIZE/2, UPD_CONFIRM_BUTTON_SIZE/2)];
        [self.cancelButton addTarget:self action:@selector(confirmationCancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setAlpha:0];
        [self.cancelButton setUserInteractionEnabled:NO];
        [self addSubview:self.cancelButton];
    }
    return self;
}

/*
 Clear the cache and cookies, then register our custom
 url protocol to handle new requests and forward them
 to our accumulator
 */
- (void)beginSession {
    [UPDTimer startTimer];
    
    [self clearPersistentData];
    self.instructionAccumulator = [[UPDInstructionAccumulator alloc] init];
    [UPDURLProtocol setInstructionAccumulator:self.instructionAccumulator];
    [NSURLProtocol registerClass:[UPDURLProtocol class]];
    
    for(UIView *view in [self subviews]) {
        if([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
            break;
        }
    }
    if(!self.urlBar.superview) {
        [self addSubview:self.urlBar];
    }
    if(!self.bottomBar.superview) {
        [self addSubview:self.bottomBar];
    }
    
    if(self.webView.superview) {
        [self.webView removeFromSuperview];
    }
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.urlBar.frame.size.height, self.bounds.size.width, self.bounds.size.height-self.urlBar.frame.size.height-self.bottomBar.frame.size.height)];
    [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
    [self.webView setDelegate:self];
    [self.webView setScalesPageToFit:YES];
    [self addSubview:self.webView];
    [self setUserInteractionEnabled:YES];
}

- (void)browserOverlayTapped {
    [self.urlBar resignFirstResponder];
    [self.browserOverlay setUserInteractionEnabled:NO];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.browserOverlay setAlpha:0];
    }];
}

- (void)cancelSession {
    [NSURLProtocol unregisterClass:[UPDURLProtocol class]];
    if(self.cancelSessionBlock) {
        self.cancelSessionBlock();
    }
}

- (void)confirmationCancelButtonTapped {
    [UPDTimer resumeTimer];
    [self.confirmButton setUserInteractionEnabled:NO];
    [self.cancelButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.completeOverlay setAlpha:0];
        [self.cancelButton setAlpha:0];
        [self.confirmButton setAlpha:0];
        [self.confirmLabel setAlpha:0];
    }];
}

/*
 Renders the browser (and url/bottom bars) to an image
 to give the processing view
 */
- (void)confirmButtonTapped {
    if(self.confirmBlock) {
        NSTimeInterval timerResult = [UPDTimer stopTimer];
        NSDate *origDate = [NSDate date];
        
        NSString *currentURL = [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
        if(!currentURL) {
            currentURL = self.webView.request.URL.absoluteString;
        }
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [self.urlBar.layer renderInContext:context];
        CGContextTranslateCTM(context, 0, self.urlBar.layer.bounds.size.height);
        [self.webView.layer renderInContext:context];
        CGContextTranslateCTM(context, 0, self.webView.layer.bounds.size.height);
        [self.bottomBar.layer renderInContext:context];
        CGContextTranslateCTM(context, 0, -self.urlBar.layer.bounds.size.height-self.webView.layer.bounds.size.height);
        
        UIImage *browserImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-browserImage.size.width)/2, (self.bounds.size.height-browserImage.size.height)/2, browserImage.size.width, browserImage.size.height)];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [imageView setImage:browserImage];
        [self addSubview:imageView];
        [self.completeOverlay setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        
        [self.webView removeFromSuperview];
        [self.urlBar removeFromSuperview];
        [self.bottomBar removeFromSuperview];
        
        [self bringSubviewToFront:self.completeOverlay];
        [self bringSubviewToFront:self.confirmLabel];
        [self bringSubviewToFront:self.cancelButton];
        [self bringSubviewToFront:self.confirmButton];
        
        [self setUserInteractionEnabled:NO];
        [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
            [self.cancelButton setAlpha:0];
            [self.confirmLabel setAlpha:0];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:UPD_TRANSITION_DURATION_SLOW delay:UPD_TRANSITION_DELAY options:0 animations:^{
                [imageView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, UPD_BROWSER_IMAGE_SCALE, UPD_BROWSER_IMAGE_SCALE)];
                [self.completeOverlay setTransform:CGAffineTransformScale(CGAffineTransformIdentity, UPD_BROWSER_IMAGE_SCALE, UPD_BROWSER_IMAGE_SCALE)];
                [self.completeOverlay setAlpha:UPD_BROWSER_IMAGE_OPACITY];
            } completion:^(BOOL finished) {
                self.confirmBlock(browserImage, self.instructionAccumulator.instructions, currentURL, timerResult, origDate);
            }];
        }];
    }
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

- (void)layoutSubviews {
    CGSize confirmLabelSize = [self.confirmLabel.text boundingRectWithSize:CGSizeMake(UPD_CONFIRM_LABEL_WIDTH, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.confirmLabel.font} context:nil].size;
    confirmLabelSize.height = ceilf(confirmLabelSize.height);
    confirmLabelSize.width = ceilf(confirmLabelSize.width);
    [self.confirmLabel setFrame:CGRectMake((self.bounds.size.width-confirmLabelSize.width)/2, self.confirmButton.frame.origin.y/2-confirmLabelSize.height/2, confirmLabelSize.width, confirmLabelSize.height)];
    
    [self.cancelButton setFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE/2)/2, self.confirmButton.frame.origin.y+self.confirmButton.frame.size.height+self.confirmButton.frame.origin.y/2-self.cancelButton.frame.size.height/2, UPD_CONFIRM_BUTTON_SIZE/2, UPD_CONFIRM_BUTTON_SIZE/2)];
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
