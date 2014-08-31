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

@interface UPDDocumentRenderer()

@property (nonatomic, copy) void (^completionBlock)(NSString *newResponse);
@property (nonatomic, copy) void (^countOccurrencesCompletion)(int count);
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic) int webViewLoadingCount;

@end

@implementation UPDDocumentRenderer

static UIWindow *_window;

+ (void)initialize {
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
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
}

- (void)countOccurrencesOfString:(NSString *)str inDocument:(NSString *)doc withBaseURL:(NSURL *)url withCompletionBlock:(void (^)(int count))completionBlock {
    [self setCountOccurrencesCompletion:completionBlock];
    [self setSearchString:str];
    [self.webView loadHTMLString:doc baseURL:url];
}

- (void)dealloc {
    self.webView = nil;
}

- (void)renderDocument:(NSString *)doc withBaseURL:(NSURL *)url completionBlock:(void (^)(NSString *newResponse))completionBlock {
    [self setCompletionBlock:completionBlock];
    [self.webView loadHTMLString:doc baseURL:url];
}

- (void)setupWebView {
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [self.webView setBackgroundColor:[UIColor redColor]];
    [self.webView setDelegate:self];
    [_window addSubview:self.webView];
}

#pragma mark - UIWebView Delegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.webViewLoadingCount++;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webViewLoadingCount--;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.webViewLoadingCount == 0) {
            if(self.completionBlock) {
                void(^completionBlockCopy)(NSString *newResponse) = [self.completionBlock copy];
                self.completionBlock = nil;
                completionBlockCopy([webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
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
    });
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    self.webViewLoadingCount--;
}

@end
