//
//  UPDBrowserBottomButton.m
//  Updates
//
//  Created by Bryce Pauken on 7/19/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDBrowserBottomButton.h"

@interface UPDBrowserBottomButton()

@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation UPDBrowserBottomButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setHighlightedBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
        [self setNormalBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.layer setCornerRadius:2];
        [self.layer setMasksToBounds:YES];
        
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_BOTTOM_BAR_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_BOTTOM_BAR_BUTTON_SIZE)/2, UPD_BOTTOM_BAR_BUTTON_SIZE, UPD_BOTTOM_BAR_BUTTON_SIZE)];
        [self.iconImageView setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self addSubview:self.iconImageView];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self.iconImageView setAlpha:enabled?1:0.5];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self setBackgroundColor:highlighted?self.highlightedBackgroundColor:self.normalBackgroundColor];
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    _highlightedBackgroundColor = highlightedBackgroundColor;
    if(self.highlighted) {
        [self setBackgroundColor:highlightedBackgroundColor];
    }
}

- (void)setImage:(UIImage *)image {
    [self.iconImageView setImage:image];
}

- (void)setNormalBackgroundColor:(UIColor *)normalBackgroundColor {
    _normalBackgroundColor = normalBackgroundColor;
    if(!self.highlighted) {
        [self setBackgroundColor:normalBackgroundColor];
    }
}

@end
