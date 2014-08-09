//
//  UPDStartingView.m
//  Updates
//
//  Created by Bryce Pauken on 8/8/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDStartView.h"

#import "UPDAlertViewButton.h"
#import "UPDAppDelegate.h"
#import "UPDInterface.h"
#import "UPDViewController.h"

@interface UPDStartView()

@property (nonatomic, strong) UIView *fullBackground;
@property (nonatomic, strong) UIView *interfaceOverlay;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) UPDAlertViewButton *okButton;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UPDAlertViewButton *scrollButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *topBackground;

@end

@implementation UPDStartView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setAlpha:0.98];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.layer setCornerRadius:2];
        [self.layer setMasksToBounds:NO];
        
        self.topBackground = [[UIView alloc] init];
        [self.topBackground setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.topBackground.layer setCornerRadius:2];
        [self.topBackground.layer setMasksToBounds:NO];
        [self addSubview:self.topBackground];
        
        self.fullBackground = [[UIView alloc] init];
        [self.fullBackground setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.fullBackground.layer setCornerRadius:2];
        [self.fullBackground.layer setMasksToBounds:NO];
        [self addSubview:self.fullBackground];
        
        self.interfaceOverlay = [[UIView alloc] init];
        [self.interfaceOverlay setAlpha:0];
        [self.interfaceOverlay setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.interfaceOverlay setBackgroundColor:[UIColor UPDOffBlackColor]];
        [self.interfaceOverlay setUserInteractionEnabled:YES];
        
        self.titleLabel = [[UILabel alloc] init];
        [self.titleLabel setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.titleLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [self.titleLabel setText:[@"Things To Know" uppercaseString]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self.titleLabel setUserInteractionEnabled:NO];
        [self addSubview:self.titleLabel];
        
        self.scrollView = [[UIScrollView alloc] init];
        [self.scrollView setDelegate:self];
        [self.scrollView setPagingEnabled:YES];
        [self.scrollView setScrollsToTop:NO];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:self.scrollView];
        
        self.labels = @[[UILabel new],[UILabel new],[UILabel new],[UILabel new],[UILabel new]];
        int labelIndex = 0;
        for(UILabel *label in self.labels) {
            [label setBackgroundColor:[UIColor UPDLightBlueColor]];
            [label setFont:[UIFont systemFontOfSize:18]];
            [label setNumberOfLines:0];
            switch(labelIndex) {
                case 0:
                    [label setText:@"Updates lets you keep\ntrack of webpages.\n\nJust browse to your page,\nthen add it to your own\npull-to-refresh enabled list."];
                    break;
                case 1:
                    [label setText:@"Most pages work well with Updates, even those behind logins. Simply get to the page the way you normally would.\n\nUpdates should be able to figure out the rest."];
                    break;
                case 2:
                    [label setText:@"However, it's a whole world wide web out there, so if a page doesn't work, tell us.\n\nWe'll do our best to fix it in the future."];
                    break;
                case 3:
                    [label setText:@"You can watch up to three pages right now.\n\nAfter that, you can spend one dollar and have unlimited updates on each of your devices forever."];
                    break;
                case 4:
                    [label setText:@"Purchasing unlimited updates helps ensure that this app stays updated itself, and also certifies you as a fantastic human being.\n\nEnjoy Updates!"];
                    break;
            }
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTextColor:[UIColor UPDOffWhiteColor]];
            [self.scrollView addSubview:label];
            labelIndex++;
        }
        
        self.scrollButton = [[UPDAlertViewButton alloc] init];
        [self.scrollButton setFont:[UIFont fontWithName:@"Futura-Medium" size:16]];
        [self.scrollButton setTextColor:[UIColor UPDLightGreyColor]];
        [self.scrollButton setTitle:@"(Scroll Sidways)"];
        [self.scrollButton setUserInteractionEnabled:NO];
        [self addSubview:self.scrollButton];
        
        self.okButton = [[UPDAlertViewButton alloc] init];
        [self.okButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.okButton setAlpha:0];
        [self.okButton setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [self.okButton setTitle:@"Got It"];
        [self.okButton setUserInteractionEnabled:NO];
        [self addSubview:self.okButton];
        
        self.pageControl = [[UIPageControl alloc] init];
        [self.pageControl setNumberOfPages:self.labels.count];
        [self.pageControl setCurrentPage:0];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)buttonTapped {
    if(self.okButtonBlock) {
        self.okButtonBlock();
    }
}

- (void)dismiss {
    [self setUserInteractionEnabled:NO];
    [self.interfaceOverlay setUserInteractionEnabled:NO];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self setAlpha:0];
        [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)];
        [self.interfaceOverlay setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.interfaceOverlay removeFromSuperview];
    }];
}

- (void)layoutSubviews {
    [self.titleLabel setFrame:CGRectMake((self.bounds.size.width-self.titleLabel.frame.size.width)/2, UPD_ALERT_PADDING, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
    [self.scrollView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self.scrollView setContentSize:CGSizeMake(self.bounds.size.width*self.labels.count, self.bounds.size.height)];
    int labelIndex = 0;
    for(UILabel *label in self.labels) {
        [label setFrame:CGRectMake(self.scrollView.bounds.size.width*labelIndex+(self.scrollView.bounds.size.width-label.frame.size.width)/2, UPD_ALERT_PADDING+self.titleLabel.frame.size.height+UPD_ALERT_PADDING, label.frame.size.width, label.frame.size.height)];
        labelIndex++;
    }
    [self.scrollButton setFrame:CGRectMake(0, self.bounds.size.height-UPD_ALERT_BUTTON_HEIGHT, self.bounds.size.width, UPD_ALERT_BUTTON_HEIGHT)];
    [self.okButton setFrame:CGRectMake(0, self.bounds.size.height-UPD_ALERT_BUTTON_HEIGHT, self.bounds.size.width, UPD_ALERT_BUTTON_HEIGHT)];
    [self.topBackground setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-UPD_ALERT_BUTTON_HEIGHT-UPD_ALERT_PADDING)];
    [self.fullBackground setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self.pageControl setFrame:CGRectMake((self.bounds.size.width-self.pageControl.frame.size.width)/2, self.bounds.size.height-UPD_ALERT_BUTTON_HEIGHT-UPD_ALERT_PADDING/2-self.pageControl.frame.size.height/2, self.pageControl.frame.size.width, self.pageControl.frame.size.height)];
    
    [((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]).viewController setHideStatusBar:self.frame.origin.y<20];
    [((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]).viewController setNeedsStatusBarAppearanceUpdate];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat alpha = (scrollView.contentOffset.x-(scrollView.contentSize.width-scrollView.bounds.size.width*2))/(CGFloat)scrollView.bounds.size.width;
    alpha = MAX(0, MIN(1, alpha));
    [self.okButton setAlpha:alpha];
    [self.okButton setUserInteractionEnabled:alpha>0.75?YES:NO];
    [self.fullBackground setAlpha:1-alpha];
    [self.pageControl setAlpha:MAX(0, 1-alpha*2)];
    
    [self.pageControl setCurrentPage:round(self.scrollView.contentOffset.x/(CGFloat)self.scrollView.bounds.size.width)];
}

- (void)show {
    UIView *interface = ((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]).viewController.interface;
    
    [self.interfaceOverlay setFrame:interface.bounds];
    [interface addSubview:self.interfaceOverlay];
    
    [self.titleLabel sizeToFit];
    CGFloat maxLabelHeight = 0;
    for(UILabel *label in self.labels) {
        CGSize labelSize = [label.text boundingRectWithSize:CGSizeMake(UPD_ALERT_WIDTH-UPD_ALERT_PADDING*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: label.font} context:nil].size;
        [label setFrame:CGRectMake(0, 0, ceilf(labelSize.width), ceilf(labelSize.height))];
        if(label.frame.size.height>maxLabelHeight) {
            maxLabelHeight = label.frame.size.height;
        }
    }
    [self.scrollView setFrame:CGRectMake(0, 0, self.bounds.size.width, maxLabelHeight)];
    
    [self layoutSubviews];
    
    CGFloat frameHeight = UPD_ALERT_PADDING+self.titleLabel.frame.size.height+UPD_ALERT_PADDING+maxLabelHeight+UPD_ALERT_PADDING+UPD_ALERT_PADDING+UPD_ALERT_BUTTON_HEIGHT;
    [self setFrame:CGRectMake((interface.bounds.size.width-UPD_ALERT_WIDTH)/2, (interface.bounds.size.height-frameHeight)/2, UPD_ALERT_WIDTH, frameHeight)];
    [interface addSubview:self];
    
    /*begin settings animation*/
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.1, 1.1, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:scale1],[NSValue valueWithCATransform3D:scale2],[NSValue valueWithCATransform3D:scale3],[NSValue valueWithCATransform3D:scale4], nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:0.8],[NSNumber numberWithFloat:1.0], nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    animation.duration = UPD_TRANSITION_DURATION;
    
    [self.layer addAnimation:animation forKey:@"popup"];
    /*end settings animation*/
    
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.interfaceOverlay setAlpha:0.8];
    }];
}

@end
