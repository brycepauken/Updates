//
//  UPDBrowserView.h
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDBrowserView : UIView <UIWebViewDelegate>

- (void)beginSession;
- (void)loadURL:(NSString *)url;

@end
