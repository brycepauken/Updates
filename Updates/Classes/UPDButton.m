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
        
        self.label = [[UILabel alloc] init];
        [self.label setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    CGSize titleLabelSize = [self.label.text boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.label.font} context:nil].size;
    titleLabelSize.height = ceilf(titleLabelSize.height);
    titleLabelSize.width = ceilf(titleLabelSize.width);
    
    [self.label setFrame:CGRectMake((self.bounds.size.width-titleLabelSize.width)/2, (self.bounds.size.height-titleLabelSize.height)/2, titleLabelSize.width, titleLabelSize.height)];
    
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self setAlpha:enabled?1:0.5];
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
    [self.label setText:[title uppercaseString]];
    [self setNeedsLayout];
}

@end