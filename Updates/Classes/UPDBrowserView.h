//
//  UPDBrowserView.h
//  Updates
//
//  Created by Bryce Pauken on 5/17/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UPDBrowserBottomBar;
@class UPDBrowserNavigationBar;
@class UPDBrowserStartView;

@interface UPDBrowserView : UIView <UIGestureRecognizerDelegate, UIWebViewDelegate>

@property (nonatomic, retain) UPDBrowserBottomBar *bottomBar;
@property (nonatomic, retain) NSMutableArray *instructions;
@property (nonatomic, retain) UPDBrowserNavigationBar *navigationBar;
@property (nonatomic, retain) UPDBrowserStartView *startView;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIView *webViewOverlay;

- (void)loadURL:(NSString *)url;

@end
