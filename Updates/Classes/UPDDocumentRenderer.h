//
//  UPDDocumentRenderer.h
//  Updates
//
//  Created by Bryce Pauken on 8/1/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDDocumentRenderer : NSObject <UIWebViewDelegate>

- (void)clearWebView;
- (void)countOccurrencesOfString:(NSString *)str inDocument:(NSString *)doc withBaseURL:(NSURL *)url withCompletionBlock:(void (^)(int count))completionBlock;
- (void)renderDocument:(NSString *)doc withBaseURL:(NSURL *)url completionBlock:(void (^)(NSString *newResponse))completionBlock;

@end
