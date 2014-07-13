//
//  UPDBrowserNavigationBar.h
//  Updates
//
//  Created by Bryce Pauken on 5/18/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDNavigationBar.h"

@class UPDBrowserURLBar;

@interface UPDBrowserNavigationBar : UPDNavigationBar

@property (nonatomic, retain) UIView *progressBar;
@property (nonatomic, retain) UPDBrowserURLBar *urlBar;

- (void)resetProgressBar;
- (void)resetProgressBarWithFade:(BOOL)fade;
- (void)progressBarAnimateToWidth:(CGFloat)width withDuration:(CGFloat)duration onCompletion:(void (^)(BOOL finished))completion;
- (BOOL)progressBarVisible;

@end
