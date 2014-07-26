//
//  UPDButton.m
//  Updates
//
//  Created by Bryce Pauken on 7/25/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDButton.h"

@interface UPDButton()

@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIColor *normalBackgroundColor;

@end

@implementation UPDButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setHighlightedBackgroundColor:[UIColor UPDLightGreyBlueColor]];
        [self setNormalBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.layer setBorderColor:[UIColor UPDOffWhiteColor].CGColor];
        [self.layer setBorderWidth:2];
        [self.layer setCornerRadius:2];
        [self.layer setMasksToBounds:YES];
        
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        [self.label setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.label setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.label];
    }
    return self;
}

- (void)setAttributedTitle:(NSAttributedString *)title {
    [self.label setText:nil];
    [self.label setAttributedText:title];
    [self setNeedsLayout];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self.label setAlpha:enabled?1:0.5];
    [self.layer setBorderColor:enabled?[UIColor UPDOffWhiteColor].CGColor:[UIColor UPDOffWhiteColorTransparent].CGColor];
}

- (void)setFontSize:(CGFloat)size {
    [self.label setFont:[UIFont fontWithName:@"Futura-Medium" size:size]];
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

- (void)setNormalBackgroundColor:(UIColor *)normalBackgroundColor {
    _normalBackgroundColor = normalBackgroundColor;
    if(!self.highlighted) {
        [self setBackgroundColor:normalBackgroundColor];
    }
}

- (void)setTitle:(NSString *)title {
    [self.label setAttributedText:nil];
    [self.label setText:[title uppercaseString]];
    [self setNeedsLayout];
}

@end