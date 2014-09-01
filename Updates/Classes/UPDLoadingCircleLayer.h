//
//  UPDLoadingCircleLayer.h
//  Updates
//
//  Created by Bryce Pauken on 8/31/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface UPDLoadingCircleLayer : CALayer

@property (nonatomic) CGFloat progress;

- (void)setColor:(UIColor *)color;

@end
