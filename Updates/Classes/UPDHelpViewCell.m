//
//  UPDHelpViewCell.m
//  Updates
//
//  Created by Bryce Pauken on 9/4/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDHelpViewCell.h"

@interface UPDHelpViewCell()

@property (nonatomic, strong) UIView *bottomDivider;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *topDivider;

@end

@implementation UPDHelpViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(UPD_ALERT_PADDING, UPD_ALERT_PADDING, self.bounds.size.width-UPD_ALERT_PADDING*2, self.bounds.size.height-UPD_ALERT_PADDING*2)];
        [self.label setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.label setFont:[UIFont fontWithName:@"Futura-Medium" size:UPD_HELPVIEW_CELL_FONT_SIZE]];
        [self.label setNumberOfLines:0];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.label];
        
        self.topDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 2)];
        [self.topDivider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.topDivider setBackgroundColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.topDivider];
        
        self.bottomDivider = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-2, self.bounds.size.width, 2)];
        [self.bottomDivider setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [self.bottomDivider setBackgroundColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.bottomDivider];
    }
    return self;
}

- (void)setBottomDividerHidden:(BOOL)bottomDividerHidden {
    [self.bottomDivider setHidden:bottomDividerHidden];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self setBackgroundColor:highlighted?[UIColor UPDLightGreyBlueColor]:[UIColor UPDLightBlueColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}

- (void)setText:(NSString *)text {
    [self.label setText:text];
}

- (void)setTopDividerHidden:(BOOL)topDividerHidden {
    [self.topDivider setHidden:topDividerHidden];
}

@end
