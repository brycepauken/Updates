//
//  UPDBrowserView.m
//  Updates
//
//  Created by Bryce Pauken on 5/17/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDBrowserView.h"

#import "UPDBrowserBottomBar.h"
#import "UPDBrowserNavigationBar.h"
#import "UPDBrowserStartView.h"
#import "UPDBrowserStartViewTextField.h"
#import "UPDBrowserURLBar.h"

@implementation UPDBrowserView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        __weak UPDBrowserView *weakSelf = self;
        [AppDelegate setAddInstruction:^(NSString *url, NSString *post, NSString *response, NSDictionary *headers) {
            //[weakSelf.instructions addObject:[NSDictionary dictionaryWithObjectsAndKeys:url,@"url",post,@"post",response,@"response",headers,@"headers",nil]];
        }];
        
        CGFloat navigationBarHeight = UPD_NAVIGATION_BAR_HEIGHT+([UPDCommon isIOS7]?20:0);
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.bounds.size.width, self.bounds.size.height-navigationBarHeight-UPD_NAVIGATION_BAR_HEIGHT)];
        [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.webView setDelegate:self];
        [self addSubview:self.webView];
        
        self.webViewOverlay = [[UIView alloc] initWithFrame:self.webView.frame];
        [self.webViewOverlay setAlpha:0];
        [self.webViewOverlay setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.webViewOverlay setBackgroundColor:[UIColor blackColor]];
        [self addSubview:self.webViewOverlay];
        UITapGestureRecognizer *webViewOverlayTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webViewOverlayTapped)];
        [webViewOverlayTapRecognizer setDelegate:self];
        [self.webViewOverlay addGestureRecognizer:webViewOverlayTapRecognizer];
        
        self.navigationBar = [[UPDBrowserNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, navigationBarHeight)];
        [self.navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.navigationBar.urlBar setStartEditingBlock:^{
            [weakSelf.webViewOverlay setTag:1];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.webViewOverlay setAlpha:0.5];
            }];
        }];
        [self.navigationBar.urlBar setGoBlock:^(NSString *url){
            [weakSelf.webViewOverlay setTag:0];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.webViewOverlay setAlpha:0];
            }];
            [weakSelf loadURL:url];
        }];
        [self addSubview:self.navigationBar];
        
        self.bottomBar = [[UPDBrowserBottomBar alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-UPD_NAVIGATION_BAR_HEIGHT, self.bounds.size.width, UPD_NAVIGATION_BAR_HEIGHT)];
        [self.bottomBar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [self.bottomBar setFinishButtonBlock:^{
            /*NSMutableString *output = [[NSMutableString alloc] init];
            for(NSDictionary *instruction in weakSelf.instructions) {
                [output appendString:[instruction objectForKey:@"url"]];
                [output appendString:@"\n"];
                [output appendString:[instruction objectForKey:@"post"]];
                [output appendString:@"\n"];
                [output appendString:[[instruction objectForKey:@"headers"] description]];
                [output appendString:@"\n"];
                [output appendString:[instruction objectForKey:@"response"]];
                [output appendString:@"\n"];
                for(int i=0;i<50;i++) {
                    [output appendString:@"-"];
                }
                [output appendString:@"\n"];
                [output appendString:@"\n"];
            }
            NSLog(@"%@",output);*/
            
        }];
        [self addSubview:self.bottomBar];
        
        self.startView = [[UPDBrowserStartView alloc] initWithFrame:self.bounds];
        [self.startView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.startView.textField setGoBlock:^(NSString *url) {
            [weakSelf.navigationBar.urlBar setText:url];
            [weakSelf loadURL:url];
            
            POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
            anim.completionBlock = ^(POPAnimation *a, BOOL finished) {
                [weakSelf.startView removeFromSuperview];
            };
            anim.toValue = @(-weakSelf.startView.bounds.size.width);
            anim.velocity = @(200);
            [weakSelf.startView.layer pop_addAnimation:anim forKey:@"disappear"];
            
            [AppDelegate.viewController setHideStatusBar:YES];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION/2.0f animations:^{
                [AppDelegate.viewController setNeedsStatusBarAppearanceUpdate];
            } completion:^(BOOL finished) {
                [AppDelegate.viewController setHideStatusBar:NO];
                [AppDelegate.viewController setLightStatusBarContent:NO];
                [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                    [AppDelegate.viewController setNeedsStatusBarAppearanceUpdate];
                }];
            }];
        }];
        
        [self addSubview:self.startView];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(gestureRecognizer.view==self.webViewOverlay&&self.webViewOverlay.tag==0) {
        return NO;
    }
    return YES;
}

- (void)loadURL:(NSString *)url {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self.navigationBar resetProgressBarWithFade:NO];
    [self.navigationBar progressBarAnimateToWidth:0.9 withDuration:5 onCompletion:nil];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.navigationBar.urlBar setText:webView.request.mainDocumentURL.absoluteString];
    [self.navigationBar progressBarAnimateToWidth:1 withDuration:0.3 onCompletion:^(BOOL finished) {
        [self.navigationBar performSelector:@selector(resetProgressBar) withObject:nil afterDelay:0.5];
    }];
}

- (void)webViewOverlayTapped {
    [self.webViewOverlay setTag:0];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.webViewOverlay setAlpha:0];
    }];
    [self.navigationBar.urlBar resignFirstResponder];
}

@end
