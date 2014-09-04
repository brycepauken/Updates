//
//  UPDHelpView.m
//  Updates
//
//  Created by Bryce Pauken on 8/14/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDHelpView.h"

#import "UPDAlertView.h"
#import "UPDAppDelegate.h"
#import "UPDHelpViewCell.h"
#import "UPDInterface.h"
#import "UPDViewController.h"

@interface UPDHelpView()

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *interfaceOverlay;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation UPDHelpView

static NSArray *_questions;

+ (void)initialize {
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        _questions = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Help" ofType:@"plist"]];
    });
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setAlpha:0.98];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.layer setCornerRadius:2];
        
        self.interfaceOverlay = [[UIView alloc] init];
        [self.interfaceOverlay setAlpha:0];
        [self.interfaceOverlay setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.interfaceOverlay setBackgroundColor:[UIColor UPDOffBlackColor]];
        [self.interfaceOverlay setUserInteractionEnabled:YES];
        
        self.tableView = [[UITableView alloc] init];
        [self.tableView setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.tableView setDataSource:self];
        [self.tableView setDelegate:self];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:self.tableView];
        
        self.closeButton = [[UIButton alloc] init];
        [self.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.closeButton setBackgroundColor:[UIColor UPDLightGreyBlueColor]];
        [self.closeButton setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
        [self.closeButton setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75)];
        [self.closeButton.layer setCornerRadius:UPD_ALERT_CANCEL_BUTTON_SIZE*0.75];
        [self.closeButton.layer setMasksToBounds:NO];
        [self.closeButton.layer setShadowColor:[UIColor UPDOffBlackColor].CGColor];
        [self.closeButton.layer setShadowOffset:CGSizeZero];
        [self.closeButton.layer setShadowOpacity:0.5];
        [self.closeButton.layer setShadowRadius:1];
        [self addSubview:self.closeButton];
        
        [self.tableView registerClass:[UPDHelpViewCell class] forCellReuseIdentifier:@"UPDHelpViewCell"];
    }
    return self;
}

- (void)closeButtonTapped {
    if(self.closeButtonBlock) {
        self.closeButtonBlock();
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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(CGRectContainsPoint(CGRectInset(self.closeButton.frame, -self.closeButton.frame.size.width, -self.closeButton.frame.size.height), point)) {
        return self.closeButton;
    }
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews {
    [self.closeButton setFrame:CGRectMake(-UPD_ALERT_CANCEL_BUTTON_SIZE/2, -UPD_ALERT_CANCEL_BUTTON_SIZE/2, UPD_ALERT_CANCEL_BUTTON_SIZE, UPD_ALERT_CANCEL_BUTTON_SIZE)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UPDHelpViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UPDHelpViewCell"];
    if(!cell) {
        cell = [[UPDHelpViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UPDHelpViewCell"];
    }
    [cell setBottomDividerHidden:indexPath.row<[self tableView:tableView numberOfRowsInSection:indexPath.section]-1];
    [cell setText:[[_questions objectAtIndex:indexPath.row] objectAtIndex:0]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UPDAlertView *alertView = [[UPDAlertView alloc] init];
    __unsafe_unretained UPDAlertView *weakAlertView = alertView;
    [alertView setTitle:[[_questions objectAtIndex:indexPath.row] objectAtIndex:0]];
    [alertView setMessage:[[[_questions objectAtIndex:indexPath.row] objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]];
    [alertView setOkButtonBlock:^{
        [weakAlertView dismiss];
    }];
    [alertView show];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize labelSize = [[[_questions objectAtIndex:indexPath.row] objectAtIndex:0] boundingRectWithSize:CGSizeMake(UPD_ALERT_WIDTH-UPD_ALERT_PADDING*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-Medium" size:UPD_HELPVIEW_CELL_FONT_SIZE]} context:nil].size;
    return ceilf(labelSize.height)+UPD_ALERT_PADDING*2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_questions count];
}

- (void)show {
    UIView *interface = ((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]).viewController.interface;
    
    [self.interfaceOverlay setFrame:interface.bounds];
    [interface addSubview:self.interfaceOverlay];
    
    //position subviews
    [self layoutSubviews];
    
    [self setFrame:CGRectMake((interface.bounds.size.width-UPD_ALERT_WIDTH)/2, (interface.bounds.size.height-UPD_HELPVIEW_HEIGHT)/2, UPD_ALERT_WIDTH, UPD_HELPVIEW_HEIGHT)];
    [self.tableView setFrame:self.bounds];
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
