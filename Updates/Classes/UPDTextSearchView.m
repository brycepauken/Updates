//
//  UPDTextSearchView.m
//  Updates
//
//  Created by Bryce Pauken on 8/2/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 This view is designed to show a static web page, allowing the user
 to search for and select text on the page. The webview must be active
 (to allow highlighting of text), but should not allow links to be clicked.
 */

#import "UPDTextSearchView.h"

#import "UPDTextSearchBar.h"

@interface UPDTextSearchView()

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic, strong) UPDTextSearchBar *searchBar;
@property (nonatomic) BOOL shouldLoad;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation UPDTextSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-UPD_TEXT_SEARCH_BAR_HEIGHT)];
        [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.webView setDataDetectorTypes:UIDataDetectorTypeNone];
        [self.webView setDelegate:self];
        [self.webView setScalesPageToFit:YES];
        [self addSubview:self.webView];
        
        __unsafe_unretained UPDTextSearchView *weakSelf = self;
        self.searchBar = [[UPDTextSearchBar alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-UPD_TEXT_SEARCH_BAR_HEIGHT, self.bounds.size.width, UPD_TEXT_SEARCH_BAR_HEIGHT)];
        [self.searchBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.searchBar setGoButtonBlock:^(NSString *text){
            if(weakSelf.goBlock) {
                weakSelf.goBlock(text, [[weakSelf.webView stringByEvaluatingJavaScriptFromString:@"UPDHighlightCount"] intValue]);
            }
        }];
        [self.searchBar setTextChanged:^(NSString *text){
            static NSString *highlightJS;
            static dispatch_once_t dispatchOnceToken;
            dispatch_once(&dispatchOnceToken, ^{
                highlightJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Highlight" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
            });
            [weakSelf.webView stringByEvaluatingJavaScriptFromString:highlightJS];
            
            [weakSelf.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"UPDHighlightOccurrencesOfString(\"%@\");",text]];
        }];
        [self addSubview:self.searchBar];
        
        self.closeButton = [[UIButton alloc] init];
        [self.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.closeButton setBackgroundColor:[UIColor UPDLightGreyBlueColor]];
        [self.closeButton setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
        [self.closeButton setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75)];
        [self.closeButton.layer setCornerRadius:UPD_ALERT_CANCEL_BUTTON_SIZE*0.75];
        [self.closeButton.layer setMasksToBounds:NO];
        [self.closeButton.layer setShadowColor:[UIColor UPDOffBlackColor].CGColor];
        [self.closeButton.layer setShadowOffset:CGSizeZero];
        [self.closeButton.layer setShadowOpacity:0.5];
        [self.closeButton.layer setShadowRadius:1];
        [self addSubview:self.closeButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)closeButtonTapped {
    if(self.cancelBlock) {
        self.cancelBlock();
    }
}

/*
 Only perform actions if there is an animation (otherwise, could just
 be rotation, which hides/shows keyboard instantly)
 */
- (void)keyboardWillHide:(NSNotification *)notification {
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if(duration>0) {
        if(self.keyboardHeight!=0) {
            self.keyboardHeight = 0;
            [UIView animateWithDuration:duration animations:^{
                [self layoutSubviews];
            }];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat newKeyboardHeight = [self convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] toView:self.window].size.height;
    if(duration>0||self.keyboardHeight != newKeyboardHeight) {
        self.keyboardHeight = newKeyboardHeight;
        [UIView animateWithDuration:duration animations:^{
            [self layoutSubviews];
        }];
    }
}

- (void)layoutSubviews {
    [self.webView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-UPD_TEXT_SEARCH_BAR_HEIGHT-self.keyboardHeight)];
    [self.searchBar setFrame:CGRectMake(0, self.bounds.size.height-UPD_TEXT_SEARCH_BAR_HEIGHT-self.keyboardHeight, self.bounds.size.width, UPD_TEXT_SEARCH_BAR_HEIGHT)];
    [self.closeButton setFrame:CGRectMake(-UPD_ALERT_CANCEL_BUTTON_SIZE/2, -UPD_ALERT_CANCEL_BUTTON_SIZE/2, UPD_ALERT_CANCEL_BUTTON_SIZE, UPD_ALERT_CANCEL_BUTTON_SIZE)];
}

- (void)loadDocument:(NSString *)doc withBaseURL:(NSURL *)baseURL {
    [self setShouldLoad:YES];
    [self.webView loadHTMLString:doc baseURL:baseURL];
}

/*
 We need to stop the webview from highlighting links, just so
 the user knows they shouldn't/can't go anywhere.
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.webView stringByEvaluatingJavaScriptFromString:@"var node=document.createElement('style');node.type=\"text/css\";var content=document.createTextNode(\"a{-webkit-tap-highlight-color:rgba(0,0,0,0);}\");node.appendChild(content);document.getElementsByTagName('head')[0].appendChild(node);"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(self.shouldLoad) {
        [self setShouldLoad:NO];
        return YES;
    }
    return NO;
}

@end
