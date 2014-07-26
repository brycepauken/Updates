//
//  UPDTableViewCell.m
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDTableViewCell.h"

@interface UPDTableViewCell()

@property (nonatomic, strong) UIView *bar;
@property (nonatomic, strong) UIView *divider;
@property (nonatomic, strong) UIImageView *faviconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *updatedLabel;

@end

@implementation UPDTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bar = [[UIView alloc] init];
        [self.bar setBackgroundColor:[UIColor redColor]];
        [self addSubview:self.bar];
        
        self.divider = [[UIView alloc] init];
        [self.divider setBackgroundColor:[UIColor UPDLightGreyColor]];
        [self.divider setHidden:YES];
        [self addSubview:self.divider];
        
        self.faviconView = [[UIImageView alloc] init];
        [self addSubview:self.faviconView];
        
        self.nameLabel = [[UILabel alloc] init];
        [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22]];
        [self.nameLabel setTextColor:[UIColor UPDOffBlackColor]];
        [self addSubview:self.nameLabel];
        
        self.updatedLabel = [[UILabel alloc] init];
        [self.updatedLabel setFont:[UIFont systemFontOfSize:14]];
        [self.updatedLabel setTextColor:[UIColor grayColor]];
        [self addSubview:self.updatedLabel];
    }
    return self;
}

- (void)layoutSubviews {
    int rightPadding = 10;
    
    CGSize nameLabelSize = [self.nameLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width-UPD_TABLEVIEW_CELL_LEFT_WIDTH-rightPadding, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.nameLabel.font} context:nil].size;
    nameLabelSize.height = ceilf(nameLabelSize.height);
    nameLabelSize.width = ceilf(nameLabelSize.width);
    
    CGSize updatedLabelSize = [self.updatedLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width-UPD_TABLEVIEW_CELL_LEFT_WIDTH-rightPadding, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.updatedLabel.font} context:nil].size;
    updatedLabelSize.height = ceilf(updatedLabelSize.height);
    updatedLabelSize.width = ceilf(updatedLabelSize.width);
    
    [self.faviconView setFrame:CGRectMake((UPD_TABLEVIEW_CELL_LEFT_WIDTH-UPD_TABLEVIEW_FAVICON_SIZE)/2, (self.bounds.size.height-UPD_TABLEVIEW_FAVICON_SIZE)/2, UPD_TABLEVIEW_FAVICON_SIZE, UPD_TABLEVIEW_FAVICON_SIZE)];
    [self.nameLabel setFrame:CGRectMake(UPD_TABLEVIEW_CELL_LEFT_WIDTH, self.bounds.size.height/2-nameLabelSize.height/2-10, self.bounds.size.width-UPD_TABLEVIEW_CELL_LEFT_WIDTH-rightPadding, nameLabelSize.height)];
    [self.updatedLabel setFrame:CGRectMake(UPD_TABLEVIEW_CELL_LEFT_WIDTH, self.bounds.size.height/2+10, self.bounds.size.width-UPD_TABLEVIEW_CELL_LEFT_WIDTH-rightPadding, updatedLabelSize.height)];
    
    [self.bar setFrame:CGRectMake(0, 0, UPD_TABLEVIEW_CELL_LEFT_BAR_WIDTH, self.bounds.size.height)];
    [self.divider setFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%f",scrollView.contentOffset.x);
}

- (void)setDividerHidden:(BOOL)hidden {
    [self.divider setHidden:hidden];
}

- (void)setFavicon:(UIImage *)favicon {
    [self.faviconView setImage:favicon];
    [self.bar setBackgroundColor:[UIColor colorFromImage:favicon]];
}

- (void)setLastUpdated:(NSDate *)lastUpdated {
    [self.updatedLabel setText:@"Last updated 5 minutes ago"];
}

- (void)setName:(NSString *)name {
    [self.nameLabel setText:name];
}

@end
