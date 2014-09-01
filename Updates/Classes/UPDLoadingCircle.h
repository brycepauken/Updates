//
//  UPDLoadingCircle.h
//  Updates
//
//  Created by Bryce Pauken on 8/31/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDLoadingCircle : UIView

@property (nonatomic, strong) UIColor *color;

- (CGFloat)progress;
- (void)setProgress:(CGFloat)progress;

@end
