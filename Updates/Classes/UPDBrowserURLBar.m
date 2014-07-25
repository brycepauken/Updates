//
//  UPDBrowserURLBar.m
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 This is the view that appears at the top of the screen
 while web browsing. Only notable feature is the UPDBrowserTextField.
 */

#import "UPDBrowserURLBar.h"

#import "UPDBrowserTextField.h"

@interface UPDBrowserURLBar()

@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UPDBrowserTextField *textField;
@property (nonatomic, strong) UIView *textFieldContainer;

@end

@implementation UPDBrowserURLBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self setClipsToBounds:NO];
        
        self.textFieldContainer = [[UIView alloc] initWithFrame:CGRectMake(UPD_URL_BAR_PADDING, 20+(self.bounds.size.height-22-UPD_URL_BAR_HEIGHT)/2, self.bounds.size.width-UPD_URL_BAR_PADDING*2, UPD_URL_BAR_HEIGHT)];
        [self.textFieldContainer setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.textFieldContainer setBackgroundColor:[UIColor UPDOffWhiteColor]];
        [self.textFieldContainer.layer setCornerRadius:2];
        [self addSubview:self.textFieldContainer];
        
        self.textField = [[UPDBrowserTextField alloc] initWithFrame:CGRectMake(0, 0, self.textFieldContainer.bounds.size.width, self.textFieldContainer.bounds.size.height)];
        [self.textField setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.textField setDelegate:self];
        [self.textFieldContainer addSubview:self.textField];
        
        self.progressBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-4, 0, 2)];
        [self.progressBar setBackgroundColor:[UIColor UPDOffWhiteColor]];
        
        [self addSubview:self.progressBar];
        
    }
    return self;
}

- (void)goButtonTapped {
    if(self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
    if(self.goButtonBlock) {
        self.goButtonBlock(self.textField.text);
    }
}

- (BOOL)resignFirstResponder {
    [self.textField resignFirstResponder];
    return YES;
}

- (void)setText:(NSString *)text {
    [self.textField setText:text];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(self.beginEditingBlock) {
        self.beginEditingBlock();
    }
    UITextRange *range = [self.textField textRangeFromPosition:self.textField.endOfDocument toPosition:self.textField.endOfDocument];
    [self.textField setSelectedTextRange:range];
    dispatch_async(dispatch_get_main_queue(), ^{
        UITextRange *range = [self.textField textRangeFromPosition:self.textField.beginningOfDocument toPosition:self.textField.endOfDocument];
        [self.textField setSelectedTextRange:range];
    });
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if(self.endEditingBlock) {
        self.endEditingBlock();
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    [self goButtonTapped];
    return YES;
}

#pragma mark - Progress Bar Methods

- (void)progressBarAnimateToWidth:(CGFloat)width withDuration:(CGFloat)duration onCompletion:(void (^)(BOOL finished))completion {
    CGFloat currentWidth = ((CALayer *)self.progressBar.layer.presentationLayer).frame.size.width;
    [self.progressBar.layer removeAllAnimations];
    [self.progressBar setFrame:CGRectMake(0, self.bounds.size.height-4, currentWidth, 2)];
    if(duration==0) {
        [self.progressBar setFrame:CGRectMake(0, self.bounds.size.height-4, self.bounds.size.width*(width), 2)];
        if(completion) {
            completion(YES);
        }
    }
    else {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self.progressBar setFrame:CGRectMake(0, self.bounds.size.height-4, self.bounds.size.width*(width), 2)];
        } completion:completion];
    }
}

- (BOOL)progressBarVisible {
    return self.progressBar.frame.size.width>0;
}

- (void)resetProgressBar {
    [self resetProgressBarWithFade:YES];
}

- (void)resetProgressBarWithFade:(BOOL)fade {
    if(!fade) {
        [self.progressBar setFrame:CGRectMake(0, self.bounds.size.height-4, 0, 2)];
    }
    else {
        [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
            [self.progressBar setAlpha:0];
        }
        completion:^(BOOL finished){
            [self.progressBar setFrame:CGRectMake(0, self.bounds.size.height-4, 0, 2)];
            [self.progressBar setAlpha:1];
        }];
    }
}

@end
