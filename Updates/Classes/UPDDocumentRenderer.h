//
//  UPDDocumentRenderer.h
//  Updates
//
//  Created by Bryce Pauken on 8/1/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDDocumentRenderer : NSObject <UIWebViewDelegate>

- (void)renderDocument:(NSString *)doc withBaseURL:(NSURL *)url completionBlock:(void (^)(NSString *newResponse))completionBlock;

@end
