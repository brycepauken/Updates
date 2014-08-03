//
//  UPDTextSearchBar.m
//  Updates
//
//  Created by Bryce Pauken on 8/2/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDTextSearchBar.h"

#import "UPDTextSearchField.h"

@interface UPDTextSearchBar()

@property (nonatomic, strong) UIView *divider;
@property (nonatomic, strong) UIButton *goButton;
@property (nonatomic, strong) UPDTextSearchField *searchField;

@end

@implementation UPDTextSearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDLightGreyColor]];
        
        self.searchField = [[UPDTextSearchField alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width-self.bounds.size.height, self.bounds.size.height)];
        [self.searchField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        [self.searchField setDelegate:self];
        [self addSubview:self.searchField];
        
        self.goButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-self.bounds.size.height+(self.bounds.size.height-UPD_PREBROWSER_URL_BAR_BUTTON_SIZE)/2,(self.bounds.size.height-UPD_PREBROWSER_URL_BAR_BUTTON_SIZE)/2,UPD_PREBROWSER_URL_BAR_BUTTON_SIZE,UPD_PREBROWSER_URL_BAR_BUTTON_SIZE)];
        [self.goButton addTarget:self action:@selector(goButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.goButton setAdjustsImageWhenDisabled:NO];
        [self.goButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self.goButton setEnabled:NO];
        [self.goButton setImage:[UIImage imageNamed:@"Forward"] forState:UIControlStateNormal];
        [self addSubview:self.goButton];
        
        self.divider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
        [self.divider setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:self.divider];
    }
    return self;
}

- (void)goButtonTapped {
    if(self.searchField.isFirstResponder) {
        [self.searchField resignFirstResponder];
    }
    if(self.goButtonBlock) {
        self.goButtonBlock(self.searchField.text);
    }
}

/*
 We override hitTest so we can give buttons a larger tap area
 (an extra width in either direction, so 300% of the original
 size in each direction).
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(CGRectContainsPoint(CGRectMake(self.bounds.size.width-self.bounds.size.height, 0, self.bounds.size.height, self.bounds.size.height), point)) {
        return self.goButton;
    }
    return [super hitTest:point withEvent:event];
}

- (BOOL)resignFirstResponder {
    [self.searchField resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)setButtonEnabled:(BOOL)enabled {
    [self setBackgroundColor:(enabled?[UIColor UPDLighterBlueColor]:[UIColor UPDLightGreyColor])];
    [self.goButton setEnabled:enabled];
}

- (void)setText:(NSString *)text {
    [self.searchField setText:text];
}

- (void)textFieldDidChange {
    [self setButtonEnabled:[self.searchField.text length]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchField resignFirstResponder];
    [self goButtonTapped];
    return YES;
}

@end
