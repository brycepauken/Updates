//
//  UPDTableViewCell.m
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDTableViewCell.h"

#import "NSDate+UPDExtensions.h"

@interface UPDTableViewCell()

@property (nonatomic, strong) UIView *bar;
@property (nonatomic) BOOL canHide;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UIView *divider;
@property (nonatomic, strong) UIImageView *faviconView;
@property (nonatomic) BOOL hideMessageReceived;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *updatedLabel;
@property (nonatomic, strong) NSTimer *updatedLabelTimer;

@property (nonatomic, copy) void((^contactBlock)());
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) CFTimeInterval startTimestamp;

@end

@implementation UPDTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setClipsToBounds:YES];
        
        self.divider = [[UIView alloc] init];
        [self.divider setBackgroundColor:[UIColor UPDLightGreyColor]];
        [self.divider setHidden:YES];
        [self addSubview:self.divider];
        
        self.bar = [[UIView alloc] init];
        [self.bar setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.bar];
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.spinner setHidesWhenStopped:YES];
        [self addSubview:self.spinner];
        
        self.circleView = [[UIView alloc] init];
        [self.circleView.layer setCornerRadius:UPD_TABLEVIEW_CIRCLE_SIZE/2];
        [self.circleView.layer setShadowOffset:CGSizeZero];
        [self.circleView.layer setShadowOpacity:0.5];
        [self.circleView.layer setShadowRadius:1];
        [self.circleView setHidden:YES];
        [self addSubview:self.circleView];
        
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

- (void)setCircleColor:(UIColor *)color {
    if(color) {
        [self.circleView setBackgroundColor:color];
        [self.circleView.layer setShadowColor:color.CGColor];
        [self.circleView setHidden:NO];
    }
    else {
        [self.circleView setHidden:YES];
    }
    [self setNeedsLayout];
}

- (void)hideSpinnerWithContactBlock:(void (^)())contactBlock {
    [self setContactBlock:contactBlock];
    [self setHideMessageReceived:YES];
    [self tryHiding];
}

- (void)hideSpinnerAnimation {
    if(!self.startTimestamp) {
        self.startTimestamp = self.displayLink.timestamp;
    }
    CFTimeInterval elapsedTime = (self.displayLink.timestamp - self.startTimestamp);
    CGFloat mappedTime = -2.5*(elapsedTime*2)*(elapsedTime*2)+3.5*(elapsedTime*2);
    [self setBounds:CGRectMake(-UPD_TABLEVIEW_CELL_LEFT_WIDTH+UPD_TABLEVIEW_CELL_LEFT_WIDTH*mappedTime, 0, self.bounds.size.width, self.bounds.size.height)];
    
    if(elapsedTime>=0.1&&self.contactBlock) {
        void (^contactBlock)() = self.contactBlock;
        self.contactBlock = nil;
        contactBlock();
    }
    if(elapsedTime>=0.2) {
        [self.displayLink invalidate];
        [self setBounds:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    }
}

- (void)layoutSubviews {
    int rightPadding = 10;
    
    CGSize nameLabelSize = [self.nameLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width-UPD_TABLEVIEW_CELL_LEFT_WIDTH-rightPadding, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.nameLabel.font} context:nil].size;
    nameLabelSize.height = ceilf(nameLabelSize.height);
    nameLabelSize.width = ceilf(nameLabelSize.width);
    
    CGSize updatedLabelSize = [self.updatedLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width-UPD_TABLEVIEW_CELL_LEFT_WIDTH-rightPadding, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.updatedLabel.font} context:nil].size;
    updatedLabelSize.height = ceilf(updatedLabelSize.height);
    updatedLabelSize.width = ceilf(updatedLabelSize.width);
    
    [self.nameLabel setFrame:CGRectMake(UPD_TABLEVIEW_CELL_LEFT_WIDTH, self.bounds.size.height/2-nameLabelSize.height/2-10, self.bounds.size.width-UPD_TABLEVIEW_CELL_LEFT_WIDTH-rightPadding, nameLabelSize.height)];
    [self.updatedLabel setFrame:CGRectMake(UPD_TABLEVIEW_CELL_LEFT_WIDTH, self.bounds.size.height/2+10, self.bounds.size.width-UPD_TABLEVIEW_CELL_LEFT_WIDTH-rightPadding, updatedLabelSize.height)];
    if(self.circleView.hidden) {
        [self.faviconView setFrame:CGRectMake((UPD_TABLEVIEW_CELL_LEFT_WIDTH-UPD_TABLEVIEW_FAVICON_SIZE)/2, (self.bounds.size.height-UPD_TABLEVIEW_FAVICON_SIZE)/2, UPD_TABLEVIEW_FAVICON_SIZE, UPD_TABLEVIEW_FAVICON_SIZE)];
    }
    else {
        [self.faviconView setFrame:CGRectMake((UPD_TABLEVIEW_CELL_LEFT_BAR_WIDTH+UPD_TABLEVIEW_CELL_LEFT_WIDTH-UPD_TABLEVIEW_FAVICON_SIZE)/2, self.bounds.size.height/2-10-UPD_TABLEVIEW_FAVICON_SIZE/2, UPD_TABLEVIEW_FAVICON_SIZE, UPD_TABLEVIEW_FAVICON_SIZE)];
        [self.circleView setFrame:CGRectMake((UPD_TABLEVIEW_CELL_LEFT_BAR_WIDTH+UPD_TABLEVIEW_CELL_LEFT_WIDTH-UPD_TABLEVIEW_CIRCLE_SIZE)/2, self.bounds.size.height/2+10+updatedLabelSize.height/2-UPD_TABLEVIEW_CIRCLE_SIZE/2, UPD_TABLEVIEW_CIRCLE_SIZE, UPD_TABLEVIEW_CIRCLE_SIZE)];
    }
    
    [self.spinner setCenter:CGPointMake(-UPD_TABLEVIEW_CELL_LEFT_WIDTH/2, self.bounds.size.height/2)];
    [self.bar setFrame:CGRectMake(0, -10, UPD_TABLEVIEW_CELL_LEFT_BAR_WIDTH, self.bounds.size.height+20)];
    [self.divider setFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
}

- (void)setDividerHidden:(BOOL)hidden {
    [self.divider setHidden:hidden];
}

- (void)setFavicon:(UIImage *)favicon {
    [self.faviconView setImage:favicon];
    [self.bar setBackgroundColor:[UIColor colorFromImage:favicon]];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self setBackgroundColor:highlighted?[UIColor UPDMoreOffWhiteColor]:[UIColor UPDOffWhiteColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}

- (void)setLastUpdated:(NSDate *)lastUpdated {
    if(![_lastUpdated isEqualToDate:lastUpdated]) {
        _lastUpdated = lastUpdated;
        if(self.updatedLabelTimer) {
            [self.updatedLabelTimer invalidate];
        }
        [self setUpdatedLabelTimer:[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateDateText) userInfo:nil repeats:YES]];
        [self updateDateText];
    }
}

- (void)setName:(NSString *)name {
    [self.nameLabel setText:name];
}

- (void)showSpinner {
    [self.spinner startAnimating];
    
    [self setCanHide:NO];
    [self setHideMessageReceived:NO];
    
    self.startTimestamp = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(showSpinnerAnimation)];
    [self.displayLink setFrameInterval:1];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self setCanHide:YES];
        [self tryHiding];
    });
}

- (void)showSpinnerAnimation {
    if(!self.startTimestamp) {
        self.startTimestamp = self.displayLink.timestamp;
    }
    CFTimeInterval elapsedTime = (self.displayLink.timestamp - self.startTimestamp);
    CGFloat mappedTime;
    if(elapsedTime<=0.5) {
        mappedTime = -2.5*(elapsedTime*2)*(elapsedTime*2)+3.5*(elapsedTime*2);
    }
    else {
        mappedTime = -1.6*(elapsedTime*2)*(elapsedTime*2)+4*(elapsedTime*2)-1.4;
    }
    [self setBounds:CGRectMake(-UPD_TABLEVIEW_CELL_LEFT_WIDTH*mappedTime, 0, self.bounds.size.width, self.bounds.size.height)];

    if(elapsedTime>=0.75) {
        [self.displayLink invalidate];
        
        [self setBounds:CGRectMake(-UPD_TABLEVIEW_CELL_LEFT_WIDTH, 0, self.bounds.size.width, self.bounds.size.height)];
    }
}

- (void)tryHiding {
    if(self.canHide && self.hideMessageReceived) {
        self.startTimestamp = 0;
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(hideSpinnerAnimation)];
        [self.displayLink setFrameInterval:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        });
    }
}

- (void)updateDateText {
    if(self.lastUpdated && [self.lastUpdated timeIntervalSince1970]>0) {
        [self.updatedLabel setText:[NSString stringWithFormat:@"Last updated %@",[self.lastUpdated relativeDateFromDate:[NSDate date]]]];
    }
    else {
        [self.updatedLabel setText:@"Never updated"];
    }
}

@end
