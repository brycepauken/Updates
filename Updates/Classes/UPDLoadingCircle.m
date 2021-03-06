//
//  UPDLoadingCircle.m
//  Updates
//
//  Created by Bryce Pauken on 8/31/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDLoadingCircle.h"

#import "UPDLoadingCircleLayer.h"

@implementation UPDLoadingCircle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setOpaque:NO];
        [self.layer setContentsScale:[UIScreen mainScreen].scale];
        [self.layer setNeedsDisplay];
    }
    return self;
}

+ (Class)layerClass {
    return [UPDLoadingCircleLayer class];
}

- (CGFloat)progress {
    return [(UPDLoadingCircleLayer *)self.layer progress];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [(UPDLoadingCircleLayer *)self.layer setColor:color];
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:YES];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    if(animated) {
        [(UPDLoadingCircleLayer *)self.layer setProgress:progress];
    }
    else {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [(UPDLoadingCircleLayer *)self.layer setProgress:progress];
        [CATransaction commit];
    }
}

@end
