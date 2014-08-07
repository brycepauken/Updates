//
//  UPDAlertView.m
//  Updates
//
//  Created by Bryce Pauken on 7/19/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 A modified view that we can use as an alert—automatically adds
 itself right on top of the interface when show is called
 */

#import "UPDAlertView.h"

#import "UPDAlertViewButton.h"
#import "UPDAlertViewTextField.h"
#import "UPDAppDelegate.h"
#import "UPDViewController.h"

@interface UPDInterface : UIView

@end


@interface UPDAlertView()

@property (nonatomic, strong) UIImageView *checkMark;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic, strong) UIView *interfaceOverlay;
@property (nonatomic, strong) UPDAlertViewButton *noButton;
@property (nonatomic, strong) UPDAlertViewButton *okButton;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UPDAlertViewButton *yesButton;

@end

@implementation UPDAlertView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setAlpha:0.98];
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.layer setCornerRadius:2];
        
        self.interfaceOverlay = [[UIView alloc] init];
        [self.interfaceOverlay setAlpha:0];
        [self.interfaceOverlay setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.interfaceOverlay setBackgroundColor:[UIColor UPDOffBlackColor]];
        [self.interfaceOverlay setUserInteractionEnabled:YES];
        
        self.titleLabel = [[UILabel alloc] init];
        [self.titleLabel setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.titleLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:20]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.titleLabel];
        
        self.messageLabel = [[UILabel alloc] init];
        [self.messageLabel setBackgroundColor:[UIColor UPDLightBlueColor]];
        [self.messageLabel setFont:[UIFont systemFontOfSize:18]];
        [self.messageLabel setNumberOfLines:0];
        [self.messageLabel setTextAlignment:NSTextAlignmentCenter];
        [self.messageLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.messageLabel];
        
        self.noButton = [[UPDAlertViewButton alloc] init];
        [self.noButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.noButton setImage:[UIImage imageNamed:@"Cancel"]];
        [self.noButton setTitle:@"No"];
        [self addSubview:self.noButton];
        
        self.yesButton = [[UPDAlertViewButton alloc] init];
        [self.yesButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.yesButton setImage:[UIImage imageNamed:@"Accept"]];
        [self.yesButton setTitle:@"Yes"];
        [self addSubview:self.yesButton];
        
        self.okButton = [[UPDAlertViewButton alloc] init];
        [self.okButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.okButton setTitle:@"Got it"];
        [self addSubview:self.okButton];
        
        self.textField = [[UPDAlertViewTextField alloc] init];
        [self.textField setDelegate:self];
        [self.okButton addSubview:self.textField];
        
        self.checkMark = [[UIImageView alloc] init];
        [self.checkMark setImage:[UIImage imageNamed:@"Accept"]];
        [self.okButton addSubview:self.checkMark];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
        UITapGestureRecognizer *tapRecognizerOverlay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
        [self addGestureRecognizer:tapRecognizer];
        [self.interfaceOverlay addGestureRecognizer:tapRecognizerOverlay];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [self.textField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)backgroundTapped {
    [self.textField resignFirstResponder];
}

- (void)buttonTapped:(UIButton *)button {
    if(button==self.noButton&&self.noButtonBlock) {
        self.noButtonBlock();
    }
    else if(button==self.yesButton&&self.yesButtonBlock) {
        self.yesButtonBlock();
    }
    else if(button==self.okButton) {
        if(self.okButtonBlock) {
            self.okButtonBlock();
        }
        else if(self.textSubmitBlock) {
            self.textSubmitBlock();
        }
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

/*
 Make the textfield's hit area bigger (if it's visible),
 to account for the padding area around it—this is just so
 nobody accidentally hits the button surrounding it.
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(!self.textField.hidden&&CGRectContainsPoint(CGRectInset([self convertRect:self.textField.frame fromView:self.okButton], -UPD_ALERT_BUTTON_PADDING, -UPD_ALERT_BUTTON_PADDING), point)) {
        return self.textField;
    }
    return [super hitTest:point withEvent:event];
}

/*
 Only perform actions if there is an animation (otherwise, could just
 be rotation, which hides/shows keyboard instantly)
 */
- (void)keyboardWillHide:(NSNotification *)notification {
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if(duration>0) {
        if(self.keyboardHeight!=0) {
            self.keyboardHeight = 0;
            [UIView animateWithDuration:duration animations:^{
                [self layoutSubviews];
            }];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat newKeyboardHeight = [self convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] toView:self.window].size.height;
    if(duration>0||self.keyboardHeight != newKeyboardHeight) {
        self.keyboardHeight = newKeyboardHeight;
        [UIView animateWithDuration:duration animations:^{
            [self layoutSubviews];
        }];
    }
}

/*
 Allow the bottom button(s) to be tapped too.
 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.bounds, point) || (!self.noButton.hidden && CGRectContainsPoint(self.noButton.frame, point)) || (!self.yesButton.hidden && CGRectContainsPoint(self.yesButton.frame, point)) || (!self.okButton.hidden && CGRectContainsPoint(self.okButton.frame, point));
}

- (void)layoutSubviews {
    CGFloat buttonWidth = (self.bounds.size.width-UPD_ALERT_PADDING)/2.0f;
    [self.noButton setFrame:CGRectMake(0, self.bounds.size.height+UPD_ALERT_PADDING, buttonWidth, UPD_ALERT_BUTTON_HEIGHT)];
    [self.yesButton setFrame:CGRectMake(buttonWidth+UPD_ALERT_PADDING, self.bounds.size.height+UPD_ALERT_PADDING, buttonWidth, UPD_ALERT_BUTTON_HEIGHT)];
    [self.okButton setFrame:CGRectMake(0, self.bounds.size.height+UPD_ALERT_PADDING, self.bounds.size.width, UPD_ALERT_BUTTON_HEIGHT)];
    [self.textField setFrame:CGRectMake(UPD_ALERT_BUTTON_PADDING, UPD_ALERT_BUTTON_PADDING, self.okButton.bounds.size.width-self.okButton.bounds.size.height-UPD_ALERT_BUTTON_PADDING*2, self.okButton.bounds.size.height-UPD_ALERT_BUTTON_PADDING*2)];
    [self.checkMark setFrame:CGRectMake(self.okButton.bounds.size.width-self.okButton.bounds.size.height+(self.okButton.bounds.size.height-UPD_ALERT_BUTTON_ICON_SIZE)/2-UPD_ALERT_BUTTON_PADDING/2, (self.okButton.bounds.size.height-UPD_ALERT_BUTTON_ICON_SIZE)/2, UPD_ALERT_BUTTON_ICON_SIZE, UPD_ALERT_BUTTON_ICON_SIZE)];
    
    [self setFrame:CGRectMake((self.superview.bounds.size.width-self.bounds.size.width)/2, (self.superview.bounds.size.height-self.bounds.size.height)/2, self.bounds.size.width, self.bounds.size.height)];
    CGFloat verticalOffset = 0;
    if(self.keyboardHeight>0) {
        CGFloat curY = [self.superview convertRect:self.textField.frame fromView:self.okButton].origin.y;
        CGFloat goalY = ((self.superview.bounds.size.height-self.keyboardHeight)-self.textField.frame.size.height)/2;
        verticalOffset = goalY-curY;
    }
    [self setFrame:CGRectMake((self.superview.bounds.size.width-self.bounds.size.width)/2, verticalOffset+(self.superview.bounds.size.height-self.bounds.size.height)/2, self.bounds.size.width, self.bounds.size.height)];

    [((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]).viewController setHideStatusBar:self.frame.origin.y<20&&self.keyboardHeight>0];
    [((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]).viewController setNeedsStatusBarAppearanceUpdate];
}

- (void)setFontSize:(CGFloat)fontSize {
    [self.messageLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [self.titleLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:fontSize+2]];
}

- (void)setTitle:(NSString *)title {
    _title = [title uppercaseString];
}

- (void)show {
    UIView *interface = ((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]).viewController.interface;
    
    [self.yesButton setHidden:!self.yesButtonBlock||!self.noButtonBlock];
    [self.noButton setHidden:!self.yesButtonBlock||!self.noButtonBlock];
    [self.okButton setHidden:(!self.okButtonBlock&&!self.textSubmitBlock)];
    [self.textField setHidden:!self.textSubmitBlock];
    if(self.textSubmitBlock) {
        [self.okButton setDisabledBackgroundColor:[UIColor lightGrayColor]];
        [self.okButton setTitle:@""];
        [self textFieldDidChange];
    }
    
    [self.interfaceOverlay setFrame:interface.bounds];
    [interface addSubview:self.interfaceOverlay];
    
    CGSize titleLabelSize = [self.title boundingRectWithSize:CGSizeMake(UPD_ALERT_WIDTH-UPD_ALERT_PADDING*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.titleLabel.font} context:nil].size;
    titleLabelSize.height = ceilf(titleLabelSize.height);
    titleLabelSize.width = ceilf(titleLabelSize.width);
    [self.titleLabel setFrame:CGRectMake(UPD_ALERT_PADDING, UPD_ALERT_PADDING, UPD_ALERT_WIDTH-UPD_ALERT_PADDING*2, titleLabelSize.height)];
    [self.titleLabel setText:self.title];
    
    CGSize messageLabelSize = [self.message boundingRectWithSize:CGSizeMake(UPD_ALERT_WIDTH-UPD_ALERT_PADDING*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.messageLabel.font} context:nil].size;
    messageLabelSize.height = ceilf(messageLabelSize.height);
    messageLabelSize.width = ceilf(messageLabelSize.width);
    [self.messageLabel setFrame:CGRectMake(UPD_ALERT_PADDING, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+UPD_ALERT_PADDING, UPD_ALERT_WIDTH-UPD_ALERT_PADDING*2, messageLabelSize.height)];
    [self.messageLabel setText:self.message];
    
    CGFloat alertHeight = titleLabelSize.height+messageLabelSize.height+UPD_ALERT_PADDING*3;
    CGFloat alertHeightWithButtons = alertHeight+UPD_ALERT_BUTTON_HEIGHT+UPD_ALERT_PADDING;
    [self setFrame:CGRectMake((interface.bounds.size.width-UPD_ALERT_WIDTH)/2, (interface.bounds.size.height-alertHeightWithButtons)/2, UPD_ALERT_WIDTH, alertHeight)];
    [interface addSubview:self];
    
    /*begin alert animation*/
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
    /*end alert animation*/
    
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.interfaceOverlay setAlpha:0.8];
    }];
}

- (void)textFieldDidChange {
    [self.checkMark setAlpha:self.textField.text.length>=6?1:0.5];
    [self.okButton setEnabled:self.textField.text.length>=6];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
