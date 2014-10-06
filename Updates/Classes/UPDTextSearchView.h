//
//  UPDTextSearchView.h
//  Updates
//
//  Created by Bryce Pauken on 8/2/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDTextSearchView : UIView <UIWebViewDelegate>

@property (nonatomic, copy) void(^cancelBlock)();
@property (nonatomic, copy) void(^goBlock)(NSString *text, int count);

- (void)loadDocument:(NSString *)doc withBaseURL:(NSURL *)baseURL;

@end
