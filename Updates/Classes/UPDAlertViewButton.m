//
//  UPDAlertViewButton.m
//  Updates
//
//  Created by Bryce Pauken on 7/20/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDAlertViewButton.h"

@interface UPDAlertViewButton()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation UPDAlertViewButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setHighlightedBackgroundColor:[UIColor UPDLightGreyBlueColor]];
        [self setNormalBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.layer setCornerRadius:2];
        [self.layer setMasksToBounds:YES];
        
        self.iconImageView = [[UIImageView alloc] init];
        [self addSubview:self.iconImageView];
        
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
    
    CGFloat totalContentWidth = self.iconImageView.image?titleLabelSize.width+UPD_ALERT_PADDING+UPD_ALERT_BUTTON_ICON_SIZE:titleLabelSize.width;
    [self.label setFrame:CGRectMake((self.bounds.size.width-totalContentWidth)/2, (self.bounds.size.height-titleLabelSize.height)/2, titleLabelSize.width, titleLabelSize.height)];
    [self.iconImageView setFrame:CGRectMake(self.label.frame.origin.x+self.label.frame.size.width+UPD_ALERT_PADDING, (self.bounds.size.height-UPD_ALERT_BUTTON_ICON_SIZE)/2, UPD_ALERT_BUTTON_ICON_SIZE, UPD_ALERT_BUTTON_ICON_SIZE)];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self setBackgroundColor:enabled?self.normalBackgroundColor:self.disabledBackgroundColor];
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

- (void)setTitle:(NSString *)title {
    [self.label setText:[title uppercaseString]];
    [self setNeedsLayout];
}

@end
