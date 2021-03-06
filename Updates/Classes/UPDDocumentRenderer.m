//
//  UPDInstructionRenderer.m
//  Updates
//
//  Created by Bryce Pauken on 8/1/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 The document renderer is designed to load an HTML document in a
 web view. This can be used both for getting the final HTML code of
 a document (after executing JavaScript, for example), and for
 retrieving any cookies set with JavaScript.
 */

#import "UPDDocumentRenderer.h"

#import "UPDURLProtocol.h"

@interface UPDDocumentRenderer()

@property (nonatomic, copy) void (^completionBlock)(NSString *newResponse);
@property (nonatomic, copy) void (^countOccurrencesCompletion)(int count);
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic) int webViewLoadingCount;

@end

@implementation UPDDocumentRenderer

static BOOL _urlProtocolRegistered;
static UIWindow *_window;

+ (void)initialize {
    _urlProtocolRegistered = NO;
    _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.webViewLoadingCount = 0;
        [self performSelectorOnMainThread:@selector(setupWebView) withObject:nil waitUntilDone:YES];
    }
    return self;
}

- (void)clearWebView {
    [self performSelectorOnMainThread:@selector(clearWebViewMainThread) withObject:nil waitUntilDone:YES];
}

- (void)clearWebViewMainThread {
    if(_urlProtocolRegistered) {
        _urlProtocolRegistered = NO;
        [NSURLProtocol unregisterClass:[UPDURLProtocol class]];
    }
    [self.webView stopLoading];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

- (void)complete {
    if(self.completionBlock) {
        void(^completionBlockCopy)(NSString *newResponse) = [self.completionBlock copy];
        self.completionBlock = nil;
        completionBlockCopy([self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
    }
    
    else if(self.countOccurrencesCompletion) {
        void(^countOccurrencesCompletionCopy)(int count) = [self.countOccurrencesCompletion copy];
        self.countOccurrencesCompletion = nil;
        
        static NSString *highlightJS;
        static dispatch_once_t dispatchOnceToken;
        dispatch_once(&dispatchOnceToken, ^{
            highlightJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Highlight" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
        });
        [self.webView stringByEvaluatingJavaScriptFromString:highlightJS];
        
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"UPDHighlightOccurrencesOfString(\"%@\");",self.searchString]];
        countOccurrencesCompletionCopy([[self.webView stringByEvaluatingJavaScriptFromString:@"UPDHighlightCount"] intValue]);
    }
}

- (void)countOccurrencesOfString:(NSString *)str inDocument:(NSString *)doc withBaseURL:(NSURL *)url withCompletionBlock:(void (^)(int count))completionBlock {
    if(!_urlProtocolRegistered) {
        _urlProtocolRegistered = YES;
        [UPDURLProtocol setInstructionAccumulator:nil];
        [UPDURLProtocol setPreventUnnecessaryLoading:YES];
        [NSURLProtocol registerClass:[UPDURLProtocol class]];
    }
    [self setCountOccurrencesCompletion:completionBlock];
    [self setSearchString:str];
    [self.webView loadHTMLString:doc baseURL:url];
}

- (void)dealloc {
    [self.webView setDelegate:nil];
    [self.webView stopLoading];
    self.webView = nil;
}

- (void)renderDocument:(NSString *)doc withBaseURL:(NSURL *)url completionBlock:(void (^)(NSString *newResponse))completionBlock {
    if(!_urlProtocolRegistered) {
        _urlProtocolRegistered = YES;
        [UPDURLProtocol setInstructionAccumulator:nil];
        [UPDURLProtocol setPreventUnnecessaryLoading:YES];
        [NSURLProtocol registerClass:[UPDURLProtocol class]];
    }
    [self setCompletionBlock:completionBlock];
    [self.webView loadHTMLString:doc baseURL:url];
}

- (void)resetTimer {
    [self.timeoutTimer invalidate];
    [self setTimeoutTimer:nil];
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeout) userInfo:nil repeats:NO];
}

- (void)setupWebView {
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [self.webView setDelegate:self];
    [self.webView setScalesPageToFit:YES];
    [_window addSubview:self.webView];
}

- (void)timeout {
    [self.timeoutTimer invalidate];
    [self setTimeoutTimer:nil];
    [self complete];
}

#pragma mark - UIWebView Delegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.webViewLoadingCount++;
    [self resetTimer];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webViewLoadingCount--;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.webViewLoadingCount == 0) {
            [self.timeoutTimer invalidate];
            [self setTimeoutTimer:nil];
            [self complete];
        }
    });
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    self.webViewLoadingCount--;
}

@end
