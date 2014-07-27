//
//  UPDProcessingView.m
//  Updates
//
//  Created by Bryce Pauken on 7/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 This view is reponsible for creating and managing the instruction
 processor, along with asking the user questions about the update
 on the interface side of things.
 */

#import "UPDProcessingView.h"

#import "UPDAlertView.h"
#import "UPDButton.h"
#import "UPDInstructionProcessor.h"
#import "UPDProcessingTextField.h"

@interface UPDProcessingView()

@property (nonatomic) BOOL canComplete;
@property (nonatomic, strong) UIImageView *checkmark;
@property (nonatomic, strong) UILabel *checkTypeLabel;
@property (nonatomic, strong) UPDButton *checkTypeButtonAll;
@property (nonatomic, strong) UPDButton *checkTypeButtonText;
@property (nonatomic, strong) UILabel *confirmationLabel;
@property (nonatomic, strong) UPDButton *confirmationButtonYes;
@property (nonatomic, strong) UPDButton *confirmationButtonNo;
@property (nonatomic, strong) NSDictionary *differenceOptions;
@property (nonatomic, strong) UIImage *favicon;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic, strong) UPDInstructionProcessor *instructionProcessor;
@property (nonatomic, strong) NSArray *instructions;
@property (nonatomic, strong) NSString *lastResponse;
@property (nonatomic, strong) UPDButton *nameButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UPDProcessingTextField *nameTextField;
@property (nonatomic, strong) UIImageView *outline;
@property (nonatomic, strong) UIImageView *outlineQuarter;
@property (nonatomic, strong) UPDButton *processingButton;
@property (nonatomic, strong) UILabel *processingLabel;
@property (nonatomic, strong) UILabel *protectLabel;
@property (nonatomic, strong) UPDButton *protectButtonNo;
@property (nonatomic, strong) UPDButton *protectButtonWhy;
@property (nonatomic, strong) UPDButton *protectButtonYes;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic) NSTimeInterval timerResult;

@end

@implementation UPDProcessingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        self.canComplete = NO;
        
        self.outlineQuarter = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE)];
        [self.outlineQuarter setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.outlineQuarter setImage:[UIImage imageNamed:@"ButtonOutlineQuarter"]];
        [self.outlineQuarter setHidden:YES];
        [self addSubview:self.outlineQuarter];
        
        self.outline = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE)];
        [self.outline setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.outline setImage:[UIImage imageNamed:@"ButtonOutline"]];
        [self addSubview:self.outline];
        
        self.checkmark = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE)];
        [self.checkmark setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.checkmark setImage:[UIImage imageNamed:@"AcceptLarge"]];
        [self addSubview:self.checkmark];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, UPD_PROCESSING_SCROLLVIEW_SIZE, UPD_PROCESSING_SCROLLVIEW_SIZE)];
        [self.scrollView setClipsToBounds:NO];
        [self.scrollView setContentSize:CGSizeMake(UPD_PROCESSING_SCROLLVIEW_SIZE*5, UPD_PROCESSING_SCROLLVIEW_SIZE)];
        [self.scrollView setScrollEnabled:NO];
        [self.scrollView setScrollsToTop:NO];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:self.scrollView];
        
        /*page1*/
        
        self.processingLabel = [[UILabel alloc] init];
        [self.processingLabel setAlpha:0];
        [self.processingLabel setFont:[UIFont systemFontOfSize:18]];
        [self.processingLabel setNumberOfLines:0];
        [self.processingLabel setText:@"Your new update is processing.\nThis may take a few moments.\n\nDon't worry!\nYou can use this time to set\nup your update's information."];
        [self.processingLabel setTextAlignment:NSTextAlignmentCenter];
        [self.processingLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self.scrollView addSubview:self.processingLabel];
        
        self.processingButton = [[UPDButton alloc] init];
        [self.processingButton addTarget:self action:@selector(scrollToPageFromButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.processingButton setAlpha:0];
        [self.processingButton setTitle:@"OK"];
        [self.scrollView addSubview:self.processingButton];
        
        /*page2*/
        
        self.nameLabel = [[UILabel alloc] init];
        [self.nameLabel setAlpha:0];
        [self.nameLabel setFont:[UIFont systemFontOfSize:18]];
        [self.nameLabel setNumberOfLines:0];
        [self.nameLabel setTag:1];
        [self.nameLabel setText:@"Choose a name for\nyour new update:"];
        [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.nameLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self.scrollView addSubview:self.nameLabel];
        
        self.nameTextField = [[UPDProcessingTextField alloc] init];
        [self.nameTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        [self.nameTextField setAlpha:0];
        [self.nameTextField setDelegate:self];
        [self.nameTextField setTag:1];
        [self.scrollView addSubview:self.nameTextField];
        
        self.nameButton = [[UPDButton alloc] init];
        [self.nameButton addTarget:self action:@selector(scrollToPageFromButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.nameButton setAlpha:0];
        [self.nameButton setEnabled:NO];
        [self.nameButton setTag:1];
        [self.nameButton setTitle:@"OK"];
        [self.scrollView addSubview:self.nameButton];
        
        /*page 3*/
        
        self.protectLabel = [[UILabel alloc] init];
        [self.protectLabel setAlpha:0];
        [self.protectLabel setFont:[UIFont systemFontOfSize:18]];
        [self.protectLabel setNumberOfLines:0];
        [self.protectLabel setTag:2];
        [self.protectLabel setText:@"Did you enter any sensative\ndata, such as passwords\nor personal information?"];
        [self.protectLabel setTextAlignment:NSTextAlignmentCenter];
        [self.protectLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self.scrollView addSubview:self.protectLabel];
        
        for(int i=0;i<3;i++) {
            UPDButton *button = [[UPDButton alloc] init];
            [button addTarget:self action:@selector(protectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [button setAlpha:0];
            [button setTag:2];
            [self.scrollView addSubview:button];
            if(i==0) {
                [button setTitle:@"Yes"];
                self.protectButtonYes = button;
            }
            else if(i==1) {
                [button setTitle:@"Why?"];
                self.protectButtonWhy = button;
            }
            else if(i==2) {
                [button setTitle:@"No"];
                self.protectButtonNo = button;
            }
        }
        
        /*page 4*/
        
        self.checkTypeLabel = [[UILabel alloc] init];
        [self.checkTypeLabel setAlpha:0];
        [self.checkTypeLabel setFont:[UIFont systemFontOfSize:18]];
        [self.checkTypeLabel setNumberOfLines:0];
        [self.checkTypeLabel setTag:3];
        [self.checkTypeLabel setText:@"When should this page\nbe considered updated?"];
        [self.checkTypeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.checkTypeLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self.scrollView addSubview:self.checkTypeLabel];
        
        for(int i=0;i<2;i++) {
            UPDButton *button = [[UPDButton alloc] init];
            [button addTarget:self action:@selector(checkTypeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [button setAlpha:0];
            [button setFontSize:16];
            [button setTag:3];
            [self.scrollView addSubview:button];
            if(i==0) {
                NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[@"When Certain Text Changes" uppercaseString]];
                [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Futura-Medium" size:16] range:NSMakeRange(0, 5)];
                [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Verdana-Bold" size:16] range:NSMakeRange(5, 12)];
                [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Futura-Medium" size:16] range:NSMakeRange(17, 8)];
                [button setAttributedTitle:title];
                self.checkTypeButtonText = button;
            }
            else if(i==1) {
                NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[@"When Anything Changes" uppercaseString]];
                [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Futura-Medium" size:16] range:NSMakeRange(0, 5)];
                [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Verdana-Bold" size:16] range:NSMakeRange(5, 8)];
                [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Futura-Medium" size:16] range:NSMakeRange(13, 8)];
                [button setAttributedTitle:title];
                self.checkTypeButtonAll = button;
            }
        }
        
        /*page 5*/
        self.confirmationLabel = [[UILabel alloc] init];
        [self.confirmationLabel setAlpha:0];
        [self.confirmationLabel setFont:[UIFont systemFontOfSize:18]];
        [self.confirmationLabel setNumberOfLines:0];
        [self.confirmationLabel setTag:4];
        [self.confirmationLabel setText:@"Watching for any change can lead to false updates due to small differences from visit to visit.\n\nAre you sure you want to continue?"];
        [self.confirmationLabel setTextAlignment:NSTextAlignmentCenter];
        [self.confirmationLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self.scrollView addSubview:self.confirmationLabel];
        
        for(int i=0;i<2;i++) {
            UPDButton *button = [[UPDButton alloc] init];
            [button addTarget:self action:@selector(confirmationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [button setAlpha:0];
            [button setTag:4];
            [self.scrollView addSubview:button];
            if(i==0) {
                [button setTitle:@"No"];
                self.confirmationButtonNo = button;
            }
            else if(i==1) {
                [button setTitle:@"Yes"];
                self.confirmationButtonYes = button;
            }
        }
        
        UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
        [self addGestureRecognizer:backgroundTap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)backgroundTapped {
    [self.nameTextField resignFirstResponder];
}

- (void)beginProcessingAnimation {
    [self.outlineQuarter setHidden:NO];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotationAnimation setCumulative:YES];
    [rotationAnimation setDuration:UPD_PROCESSING_ANIMATION_DURATION];
    [rotationAnimation setRepeatCount:MAXFLOAT];
    [rotationAnimation setToValue:@(M_PI*2)];
    [self.outlineQuarter.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    CGRect newCheckFrame, newScrollViewFrame;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.bounds.size.width>self.bounds.size.height) {
        CGFloat padding = (self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE-UPD_PROCESSING_SCROLLVIEW_SIZE)/3;
        newCheckFrame = CGRectMake(padding, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE);
        newScrollViewFrame = CGRectMake(padding+UPD_CONFIRM_BUTTON_SIZE+padding, (self.bounds.size.height-UPD_PROCESSING_SCROLLVIEW_SIZE)/2, UPD_PROCESSING_SCROLLVIEW_SIZE, UPD_PROCESSING_SCROLLVIEW_SIZE);
    }
    else {
        CGFloat padding = (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE-UPD_PROCESSING_SCROLLVIEW_SIZE)/3;
        newCheckFrame = CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, padding, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE);
        newScrollViewFrame = CGRectMake((self.bounds.size.width-UPD_PROCESSING_SCROLLVIEW_SIZE)/2, padding+UPD_CONFIRM_BUTTON_SIZE+padding, UPD_PROCESSING_SCROLLVIEW_SIZE, UPD_PROCESSING_SCROLLVIEW_SIZE);
    }
    [self.scrollView setFrame:newScrollViewFrame];
    [self layoutIfNeeded];
    [self.checkmark setAutoresizingMask:UIViewAutoresizingNone];
    [self.outline setAutoresizingMask:UIViewAutoresizingNone];
    [self.outlineQuarter setAutoresizingMask:UIViewAutoresizingNone];
    [UIView animateWithDuration:UPD_PROCESSING_ANIMATION_DURATION animations:^{
        [self.outline setAlpha:0];
        
        [self.checkmark setFrame:newCheckFrame];
        [self.outline setFrame:newCheckFrame];
        [self.outlineQuarter setFrame:newCheckFrame];
        
        [self.processingButton setAlpha:1];
        [self.processingLabel setAlpha:1];
    }];
}

- (void)checkTypeButtonTapped:(UIButton *)button {
    if(button==self.checkTypeButtonAll) {
        [self scrollToPage:4];
    }
}

- (void)confirmationButtonTapped:(UIButton *)button {
    if(button==self.confirmationButtonNo) {
        [self scrollToPage:3];
    }
    else if(button==self.confirmationButtonYes) {
        self.differenceOptions = @{@"DifferenceType":@"Any"};
        
        [self.checkmark setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.outline setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.outlineQuarter setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        CGRect newCheckFrame = CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE);
        [self.scrollView setUserInteractionEnabled:NO];
        [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
            [self.confirmationLabel setAlpha:0];
            [self.confirmationButtonNo setAlpha:0];
            [self.confirmationButtonYes setAlpha:0];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [self.checkmark setFrame:newCheckFrame];
                [self.outline setFrame:newCheckFrame];
                [self.outlineQuarter setFrame:newCheckFrame];
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UPD_TRANSITION_DELAY*4*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    self.canComplete = YES;
                    [self tryCompletion];
                });
            }];
        }];
    }
}

/*
 Standard layoutSubviews method, in this case going through each
 scrollview page, along with creating different interfaces for rotated
 iPhones and iPod Touches. Many of the setFrame's are intentionally
 unsimplified, to show where each padding variable visually comes into play.
 Label sizing method could probably be simplified later on.
 */
- (void)layoutSubviews {
    /*page 1*/
    CGSize processingLabelSize = [self.processingLabel.text boundingRectWithSize:CGSizeMake(self.scrollView.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.processingLabel.font} context:nil].size;
    processingLabelSize.height = ceilf(processingLabelSize.height);
    processingLabelSize.width = ceilf(processingLabelSize.width);
    CGFloat padding1 = (self.scrollView.bounds.size.height-processingLabelSize.height-UPD_PROCESSING_BUTTON_HEIGHT)/3;
    [self.processingLabel setFrame:CGRectMake((self.scrollView.bounds.size.width-processingLabelSize.width)/2, padding1, processingLabelSize.width, processingLabelSize.height)];
    [self.processingButton setFrame:CGRectMake((self.scrollView.bounds.size.width-UPD_PROCESSING_BUTTON_WIDTH)/2, padding1+processingLabelSize.height+padding1, UPD_PROCESSING_BUTTON_WIDTH, UPD_PROCESSING_BUTTON_HEIGHT)];
    
    /*page 2*/
    CGSize nameLabelSize = [self.nameLabel.text boundingRectWithSize:CGSizeMake(self.scrollView.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.nameLabel.font} context:nil].size;
    nameLabelSize.height = ceilf(nameLabelSize.height);
    nameLabelSize.width = ceilf(nameLabelSize.width);
    CGFloat padding2 = (self.scrollView.bounds.size.height-nameLabelSize.height-UPD_PROCESSING_TEXTFIELD_HEIGHT-UPD_PROCESSING_BUTTON_HEIGHT)/4;
    [self.nameLabel setFrame:CGRectMake(self.scrollView.bounds.size.width+(self.scrollView.bounds.size.width-nameLabelSize.width)/2, padding2, nameLabelSize.width, nameLabelSize.height)];
    [self.nameTextField setFrame:CGRectMake(self.scrollView.bounds.size.width, (padding2+nameLabelSize.height+padding2), self.scrollView.bounds.size.width, UPD_PROCESSING_TEXTFIELD_HEIGHT)];
    [self.nameButton setFrame:CGRectMake(self.scrollView.bounds.size.width+(self.scrollView.bounds.size.width-UPD_PROCESSING_BUTTON_WIDTH)/2, padding2+nameLabelSize.height+padding2+UPD_PROCESSING_TEXTFIELD_HEIGHT+padding2, UPD_PROCESSING_BUTTON_WIDTH, UPD_PROCESSING_BUTTON_HEIGHT)];
    
    /*page 3*/
    CGSize protectLabelSize = [self.protectLabel.text boundingRectWithSize:CGSizeMake(self.scrollView.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.protectLabel.font} context:nil].size;
    protectLabelSize.height = ceilf(protectLabelSize.height);
    protectLabelSize.width = ceilf(protectLabelSize.width);
    CGFloat padding3 = (self.scrollView.bounds.size.height-protectLabelSize.height-UPD_PROCESSING_BUTTON_HEIGHT)/3;
    CGFloat padding3buttons = (self.scrollView.bounds.size.width-UPD_PROCESSING_BUTTON_WIDTH*3)/4;
    [self.protectLabel setFrame:CGRectMake(self.scrollView.bounds.size.width*2+(self.scrollView.bounds.size.width-protectLabelSize.width)/2, padding3, protectLabelSize.width, protectLabelSize.height)];
    [self.protectButtonYes setFrame:CGRectMake(self.scrollView.bounds.size.width*2+padding3buttons, padding3+protectLabelSize.height+padding3, UPD_PROCESSING_BUTTON_WIDTH, UPD_PROCESSING_BUTTON_HEIGHT)];
    [self.protectButtonNo setFrame:CGRectMake(self.scrollView.bounds.size.width*2+padding3buttons+UPD_PROCESSING_BUTTON_WIDTH+padding3buttons, padding3+protectLabelSize.height+padding3, UPD_PROCESSING_BUTTON_WIDTH, UPD_PROCESSING_BUTTON_HEIGHT)];
    [self.protectButtonWhy setFrame:CGRectMake(self.scrollView.bounds.size.width*2+padding3buttons+UPD_PROCESSING_BUTTON_WIDTH+padding3buttons+UPD_PROCESSING_BUTTON_WIDTH+padding3buttons, padding3+protectLabelSize.height+padding3, UPD_PROCESSING_BUTTON_WIDTH, UPD_PROCESSING_BUTTON_HEIGHT)];
    
    /*page 4*/
    CGSize checkTypeLabelSize = [self.checkTypeLabel.text boundingRectWithSize:CGSizeMake(self.scrollView.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.checkTypeLabel.font} context:nil].size;
    checkTypeLabelSize.height = ceilf(checkTypeLabelSize.height);
    checkTypeLabelSize.width = ceilf(checkTypeLabelSize.width);
    CGFloat padding4 = (self.scrollView.bounds.size.height-checkTypeLabelSize.height-UPD_PROCESSING_BUTTON_HEIGHT*2-10)/3;
    [self.checkTypeLabel setFrame:CGRectMake(self.scrollView.bounds.size.width*3+(self.scrollView.bounds.size.width-checkTypeLabelSize.width)/2, padding4, checkTypeLabelSize.width, checkTypeLabelSize.height)];
    [self.checkTypeButtonText setFrame:CGRectMake(self.scrollView.bounds.size.width*3-10, padding4+checkTypeLabelSize.height+padding4, self.scrollView.bounds.size.width+20, UPD_PROCESSING_BUTTON_HEIGHT)];
    [self.checkTypeButtonAll setFrame:CGRectMake(self.scrollView.bounds.size.width*3-10, padding4+checkTypeLabelSize.height+padding4+UPD_PROCESSING_BUTTON_HEIGHT+10, self.scrollView.bounds.size.width+20, UPD_PROCESSING_BUTTON_HEIGHT)];
    
    /*page 5*/
    CGSize confirmationLabelSize = [self.confirmationLabel.text boundingRectWithSize:CGSizeMake(self.scrollView.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.confirmationLabel.font} context:nil].size;
    confirmationLabelSize.height = ceilf(confirmationLabelSize.height);
    confirmationLabelSize.width = ceilf(confirmationLabelSize.width);
    CGFloat padding5 = (self.scrollView.bounds.size.height-confirmationLabelSize.height-UPD_PROCESSING_BUTTON_HEIGHT)/3;
    CGFloat padding5buttons = (self.scrollView.bounds.size.width-UPD_PROCESSING_BUTTON_WIDTH*2)/3;
    [self.confirmationLabel setFrame:CGRectMake(self.scrollView.bounds.size.width*4+(self.scrollView.bounds.size.width-confirmationLabelSize.width)/2, padding5, confirmationLabelSize.width, confirmationLabelSize.height)];
    [self.confirmationButtonNo setFrame:CGRectMake(self.scrollView.bounds.size.width*4+padding5buttons, padding5+confirmationLabelSize.height+padding5, UPD_PROCESSING_BUTTON_WIDTH, UPD_PROCESSING_BUTTON_HEIGHT)];
    [self.confirmationButtonYes setFrame:CGRectMake(self.scrollView.bounds.size.width*4+padding5buttons+UPD_PROCESSING_BUTTON_WIDTH+padding5buttons, padding5+confirmationLabelSize.height+padding5, UPD_PROCESSING_BUTTON_WIDTH, UPD_PROCESSING_BUTTON_HEIGHT)];
    
    /*checkmark and scrollview positions*/
    if(self.checkmark.autoresizingMask==UIViewAutoresizingNone) {
        CGRect newCheckFrame, newScrollViewFrame;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.bounds.size.width>self.bounds.size.height) {
            CGFloat padding = (self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE-UPD_PROCESSING_SCROLLVIEW_SIZE)/3;
            newCheckFrame = CGRectMake(padding, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE);
            newScrollViewFrame = CGRectMake(padding+UPD_CONFIRM_BUTTON_SIZE+padding, (self.bounds.size.height-UPD_PROCESSING_SCROLLVIEW_SIZE)/2, UPD_PROCESSING_SCROLLVIEW_SIZE, UPD_PROCESSING_SCROLLVIEW_SIZE);
        }
        else {
            CGFloat padding = (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE-UPD_PROCESSING_SCROLLVIEW_SIZE)/3;
            newCheckFrame = CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, padding, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE);
            newScrollViewFrame = CGRectMake((self.bounds.size.width-UPD_PROCESSING_SCROLLVIEW_SIZE)/2, padding+UPD_CONFIRM_BUTTON_SIZE+padding, UPD_PROCESSING_SCROLLVIEW_SIZE, UPD_PROCESSING_SCROLLVIEW_SIZE);
        }
        
        /*raise views up to center nameTextField if keyboard visible*/
        CGFloat viewOffset=0;
        if(self.keyboardHeight>0) {
            CGFloat goalY = ((self.bounds.size.height-self.keyboardHeight)-self.nameTextField.bounds.size.height)/2;
            CGFloat curY = newScrollViewFrame.origin.y+self.nameTextField.frame.origin.y;
            viewOffset = goalY-curY;
        }
        newCheckFrame.origin.y += viewOffset;
        newScrollViewFrame.origin.y += viewOffset;
        
        [self.checkmark setFrame:newCheckFrame];
        [self.outline setFrame:newCheckFrame];
        [self.outlineQuarter setFrame:newCheckFrame];
        [self.scrollView setFrame:newScrollViewFrame];
    }
}

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

- (void)processInstructions:(NSArray *)instructions forURL:(NSString *)url withTimerResult:(NSTimeInterval)timerResult {
    self.instructionProcessor = [[UPDInstructionProcessor alloc] init];
    [self.instructionProcessor setInstructions:instructions];
    [self.instructionProcessor setUrl:url];
    [self setTimerResult:timerResult];
    __unsafe_unretained UPDProcessingView *weakSelf = self;
    [self.instructionProcessor setCompletionBlock:^(NSArray *instructions, UIImage *favicon, NSString *lastReponse){
        weakSelf.instructions = instructions;
        weakSelf.favicon = favicon;
        weakSelf.lastResponse = lastReponse;
        [weakSelf tryCompletion];
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.instructionProcessor beginProcessing];
    });
}

- (void)protectButtonTapped:(UIButton *)button {
    if(button==self.protectButtonWhy) {
        UPDAlertView *alertView = [[UPDAlertView alloc] init];
        __unsafe_unretained UPDAlertView *weakAlertView = alertView;
        [alertView setTitle:@"Glad you asked"];
        [alertView setMessage:@"If any of the steps needed to get to the webpage you specified contain sensative data, we'll encrypt them with a master password provieded by you."];
        [alertView setFontSize:16];
        [alertView setOkButtonBlock:^{
            [weakAlertView dismiss];
        }];
        [alertView show];
    }
    else if(button==self.protectButtonNo) {
        [self scrollToPage:3];
    }
}

- (void)scrollToPageFromButton:(UIButton *)button {
    if(button==self.processingButton) {
        [self scrollToPage:1];
    }
    else if(button==self.nameButton) {
        [self.nameTextField resignFirstResponder];
        [self scrollToPage:2];
    }
}

- (void)scrollToPage:(int)page {
    [self.scrollView setTag:page];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*page, 0)];
        for(UIView *view in [self.scrollView subviews]) {
            [view setAlpha:page==view.tag?1:0];
        }
    }];
}

- (void)textFieldDidChange {
    [self.nameButton setEnabled:[self.nameTextField.text length]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self scrollToPage:2];
    return YES;
}

/*
 This method is run after the instructions are fully processed
 and all questions have been asked of the user, continuing on if
 both conditions have been met.
 */
- (void)tryCompletion {
    if(self.instructions && self.canComplete) {
        [self.outlineQuarter.layer removeAnimationForKey:@"rotationAnimation"];
        [self.outline setAlpha:1];
        [self.outlineQuarter setAlpha:0];
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D scale1 = CATransform3DMakeScale(1.0, 1.0, 1);
        CATransform3D scale2 = CATransform3DMakeScale(1.1, 1.1, 1);
        CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
        
        NSArray *frameValues = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:scale1],[NSValue valueWithCATransform3D:scale2],[NSValue valueWithCATransform3D:scale3],[NSValue valueWithCATransform3D:scale4], nil];
        [animation setValues:frameValues];
        
        NSArray *frameTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.6],[NSNumber numberWithFloat:0.9],[NSNumber numberWithFloat:1.0], nil];
        [animation setKeyTimes:frameTimes];
        
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = YES;
        animation.duration = UPD_TRANSITION_DURATION;
        
        [self.checkmark.layer addAnimation:animation forKey:@"popup"];
        [self.outline.layer addAnimation:animation forKey:@"popupCopy"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UPD_TRANSITION_DELAY*4*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if(self.completionBlock) {
                self.completionBlock(self.nameTextField.text, self.instructions, self.favicon, self.lastResponse, self.differenceOptions, self.timerResult);
            }
        });
    }
}

@end
