//
//  UPDBrowserNavigationBar.m
//  Updates
//
//  Created by Bryce Pauken on 5/18/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDBrowserNavigationBar.h"

#import "UPDBrowserURLBar.h"

@implementation UPDBrowserNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDOffWhiteColor]];
        
        self.urlBar = [[UPDBrowserURLBar alloc] initWithFrame:CGRectInset(self.contentView.bounds, 5, 5)];
        [self.urlBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:self.urlBar];
        
        self.progressBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.bounds.size.height-2, self.contentView.bounds.size.width/3, 2)];
        [self.progressBar setBackgroundColor:[UIColor UPDBrightBlueColor]];
        [self.contentView addSubview:self.progressBar];
    }
    return self;
}

- (void)resetProgressBar {
    [self resetProgressBarWithFade:YES];
}

- (void)resetProgressBarWithFade:(BOOL)fade {
    if(!fade) {
        [self.progressBar setFrame:CGRectMake(0, self.contentView.bounds.size.height-2, 0, 2)];
    }
    else {
        [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
            [self.progressBar setAlpha:0];
        }
        completion:^(BOOL finished){
            [self.progressBar setFrame:CGRectMake(0, self.contentView.bounds.size.height-2, 0, 2)];
            [self.progressBar setAlpha:1];
        }];
    }
}

- (void)progressBarAnimateToWidth:(CGFloat)width withDuration:(CGFloat)duration onCompletion:(void (^)(BOOL finished))completion {
    CGFloat currentWidth = ((CALayer *)self.progressBar.layer.presentationLayer).frame.size.width;
    [self.progressBar.layer removeAllAnimations];
    [self.progressBar setFrame:CGRectMake(0, self.contentView.bounds.size.height-2, currentWidth, 2)];
    if(duration==0) {
        [self.progressBar setFrame:CGRectMake(0, self.contentView.bounds.size.height-2, self.contentView.bounds.size.width*(width), 2)];
        if(completion) {
            completion(YES);
        }
    }
    else {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self.progressBar setFrame:CGRectMake(0, self.contentView.bounds.size.height-2, self.contentView.bounds.size.width*(width), 2)];
        } completion:completion];
    }
}

- (BOOL)progressBarVisible {
    return self.progressBar.frame.size.width>0;
}

@end
