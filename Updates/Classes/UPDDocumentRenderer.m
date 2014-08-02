//
//  UPDInstructionRenderer.m
//  Updates
//
//  Created by Bryce Pauken on 8/1/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDDocumentRenderer.h"

@interface UPDDocumentRenderer()

@property (nonatomic, copy) void (^completionBlock)(NSString *newResponse);
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
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
            [self.webView setBackgroundColor:[UIColor redColor]];
            [self.webView setDelegate:self];
            self.webViewLoadingCount = 0;
            [_window addSubview:self.webView];
        });
    }
    return self;
}

/*- (void)dealloc {
    self.webView = nil;
}*/

- (void)renderDocument:(NSString *)doc withBaseURL:(NSURL *)url completionBlock:(void (^)(NSString *newResponse))completionBlock {
    [self setCompletionBlock:completionBlock];
    [self.webView loadHTMLString:doc baseURL:url];
}

#pragma mark - UIWebView Delegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.webViewLoadingCount++;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webViewLoadingCount--;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.webViewLoadingCount == 0 && self.completionBlock) {
            void(^completionBlockCopy)(NSString *newResponse) = [self.completionBlock copy];
            self.completionBlock = nil;
            completionBlockCopy([webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
        }
    });
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    self.webViewLoadingCount--;
}

@end
