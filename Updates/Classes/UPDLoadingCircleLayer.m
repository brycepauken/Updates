//
//  UPDLoadingCircleLayer.m
//  Updates
//
//  Created by Bryce Pauken on 8/31/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDLoadingCircleLayer.h"

@implementation UPDLoadingCircleLayer

@dynamic progress;
UIColor *_color;

- (instancetype)init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

- (id)actionForKey:(NSString *)key {
    if([key isEqualToString:@"progress"]) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
        animation.duration = 1;
        [animation setFromValue:[self.presentationLayer valueForKey:key]];
        return animation;
    }
    return [super actionForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = MIN(center.x, center.y);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, center.x, center.y);
    
    CGContextSetFillColorWithColor(ctx, _color.CGColor);
    CGContextAddLineToPoint(ctx, center.x, center.y+radius);
    CGContextAddArc(ctx, center.x, center.y, radius, -M_PI_2, MIN(1, MAX(0, self.progress))*2*M_PI-M_PI_2, NO);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    [super drawInContext:ctx];

}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    return [key isEqualToString:@"progress"] || [super needsDisplayForKey:key];
}

- (void)setColor:(UIColor *)color {
    _color = color;
}

@end
