//
//  UPDPreBrowserURLBar.m
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDPreBrowserURLBar.h"

#import "UPDPreBrowserTextField.h"

@interface UPDPreBrowserURLBar()

@property (nonatomic, strong) UIButton *goButton;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation UPDPreBrowserURLBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setBackgroundColor:[UIColor UPDLightGreyColor]];
        [self setClipsToBounds:YES];
        [self.layer setCornerRadius:2];
        
        self.textField = [[UPDPreBrowserTextField alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width-self.bounds.size.height, self.bounds.size.height)];
        [self.textField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        [self.textField setDelegate:self];
        [self addSubview:self.textField];
        
        self.goButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-self.bounds.size.height+(self.bounds.size.height-UPD_PREBROWSER_URL_BAR_BUTTON_SIZE)/2,(self.bounds.size.height-UPD_PREBROWSER_URL_BAR_BUTTON_SIZE)/2,UPD_PREBROWSER_URL_BAR_BUTTON_SIZE,UPD_PREBROWSER_URL_BAR_BUTTON_SIZE)];
        [self.goButton addTarget:self action:@selector(goButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.goButton setAdjustsImageWhenDisabled:NO];
        [self.goButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self.goButton setEnabled:NO];
        [self.goButton setImage:[UIImage imageNamed:@"Forward"] forState:UIControlStateNormal];
        [self addSubview:self.goButton];
    }
    return self;
}

- (void)goButtonTapped {
    if(self.goButtonBlock) {
        self.goButtonBlock(self.textField.text);
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
    [self.textField resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)setButtonEnabled:(BOOL)enabled {
    [self setBackgroundColor:(enabled?[UIColor UPDLighterBlueColor]:[UIColor UPDLightGreyColor])];
    [self.goButton setEnabled:enabled];
}

- (void)setText:(NSString *)text {
    [self.textField setText:text];
}

- (void)textFieldDidChange {
    [self setButtonEnabled:[self.textField.text length]];
}

@end
