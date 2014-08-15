//
//  UPDNavigationBar.m
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 Our own custom navigation bar—derived from UIView instead of
 UINavigationBar (for the sake of control, but with the cost
 of some sanity)
 */

#import "UPDNavigationBar.h"

@interface UPDNavigationBar ()

@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *settingsButton;

@end

@implementation UPDNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(UPD_NAVIGATION_BAR_BUTTON_PADDING*2+UPD_NAVIGATION_BAR_BUTTON_SIZE, 20, self.bounds.size.width-(UPD_NAVIGATION_BAR_BUTTON_PADDING*2+UPD_NAVIGATION_BAR_BUTTON_SIZE)*2, self.bounds.size.height-20)];
        [self.label setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.label];
        [self setText:@"Updates"];
        
        self.addButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-(UPD_NAVIGATION_BAR_BUTTON_SIZE+UPD_NAVIGATION_BAR_BUTTON_PADDING), 20+((self.bounds.size.height-20)-UPD_NAVIGATION_BAR_BUTTON_SIZE)/2, UPD_NAVIGATION_BAR_BUTTON_SIZE, UPD_NAVIGATION_BAR_BUTTON_SIZE)];
        [self.addButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.addButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self.addButton setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
        [self.addButton setHidden:YES];
        [self addSubview:self.addButton];
        
        self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(UPD_NAVIGATION_BAR_BUTTON_PADDING, 20+((self.bounds.size.height-20)-UPD_NAVIGATION_BAR_BUTTON_SIZE)/2, UPD_NAVIGATION_BAR_BUTTON_SIZE, UPD_NAVIGATION_BAR_BUTTON_SIZE)];
        [self.backButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [self.backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
        [self.backButton setHidden:YES];
        [self addSubview:self.backButton];
        
        self.settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(UPD_NAVIGATION_BAR_BUTTON_PADDING-(UPD_NAVIGATION_BAR_BUTTON_SIZE_SETTINGS-UPD_NAVIGATION_BAR_BUTTON_SIZE)/2, 20+((self.bounds.size.height-20)-UPD_NAVIGATION_BAR_BUTTON_SIZE_SETTINGS)/2, UPD_NAVIGATION_BAR_BUTTON_SIZE_SETTINGS, UPD_NAVIGATION_BAR_BUTTON_SIZE_SETTINGS)];
        [self.settingsButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.settingsButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [self.settingsButton setImage:[UIImage imageNamed:@"Settings"] forState:UIControlStateNormal];
        [self.settingsButton setHidden:YES];
        [self addSubview:self.settingsButton];
    }
    return self;
}

- (void)buttonTapped:(UIButton *)button {
    if(button==self.addButton&&self.addButtonBlock) {
        self.addButtonBlock();
    }
    else if(button==self.backButton&&self.backButtonBlock) {
        self.backButtonBlock();
    }
    else if(button==self.settingsButton&&self.settingsButtonBlock) {
        self.settingsButtonBlock();
    }
}

- (void)layoutSubviews {
    [self.label setFrame:CGRectMake(UPD_NAVIGATION_BAR_BUTTON_PADDING*2+UPD_NAVIGATION_BAR_BUTTON_SIZE, 20, self.bounds.size.width-(UPD_NAVIGATION_BAR_BUTTON_PADDING*2+UPD_NAVIGATION_BAR_BUTTON_SIZE)*2, self.bounds.size.height-20)];
}

/*
 We override hitTest so we can give buttons a larger tap area
 (an extra width in either direction, so 300% of the original
 size in each direction).
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(!self.addButton.hidden&&CGRectContainsPoint(CGRectInset(self.addButton.frame, -self.addButton.frame.size.width, -self.addButton.frame.size.height), point)) {
        return self.addButton;
    }
    else if(!self.backButton.hidden&&CGRectContainsPoint(CGRectInset(self.backButton.frame, -self.backButton.frame.size.width, -self.backButton.frame.size.height), point)) {
        return self.backButton;
    }
    else if(!self.settingsButton.hidden&&CGRectContainsPoint(CGRectInset(self.settingsButton.frame, -self.settingsButton.frame.size.width, -self.settingsButton.frame.size.height), point)) {
        return self.settingsButton;
    }
    return [super hitTest:point withEvent:event];
}

- (void)setAddButtonBlock:(void (^)())addButtonBlock {
    _addButtonBlock = addButtonBlock;
    [self.addButton setHidden:!addButtonBlock];
}

- (void)setBackButtonBlock:(void (^)())backButtonBlock {
    _backButtonBlock = backButtonBlock;
    [self.backButton setHidden:!backButtonBlock];
}

- (void)setSettingsButtonBlock:(void (^)())settingsButtonBlock {
    _settingsButtonBlock = settingsButtonBlock;
    [self.settingsButton setHidden:!settingsButtonBlock];
}

- (void)setLabelFont:(UIFont *)font {
    [self.label setFont:font];
}

- (void)setText:(NSString *)text {
    if([self.label.font isEqual:[UIFont fontWithName:@"Futura-Medium" size:20]]) {
        NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString:[text uppercaseString]];
        [labelText addAttribute:NSKernAttributeName value:@(8.0) range:NSMakeRange(0, labelText.length-1)];
        [self.label setAttributedText:labelText];
    }
    else {
        [self.label setText:text];
    }
}

@end
