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

#import "UPDButton.h"
#import "UPDInstructionProcessor.h"

@interface UPDProcessingView()

@property (nonatomic, strong) UIImageView *checkmark;
@property (nonatomic, strong) UPDInstructionProcessor *instructionProcessor;
@property (nonatomic, strong) UIImageView *outline;
@property (nonatomic, strong) UIImageView *outlineQuarter;
@property (nonatomic, strong) UPDButton *processingButton;
@property (nonatomic, strong) UILabel *processingLabel;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation UPDProcessingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        
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
        [self.scrollView setScrollEnabled:NO];
        [self.scrollView setScrollsToTop:NO];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:self.scrollView];
        
        self.processingLabel = [[UILabel alloc] init];
        [self.processingLabel setAlpha:0];
        [self.processingLabel setFont:[UIFont systemFontOfSize:18]];
        [self.processingLabel setNumberOfLines:0];
        [self.processingLabel setText:@"Your new update is processing.\nThis may take a few moments.\n\nDon't worry!\nYou can use this time to set\nup your update's information."];
        [self.processingLabel setTextAlignment:NSTextAlignmentCenter];
        [self.processingLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self.scrollView addSubview:self.processingLabel];
        
        self.processingButton = [[UPDButton alloc] init];
        [self.processingButton setAlpha:0];
        [self.processingButton setTitle:@"OK"];
        [self.scrollView addSubview:self.processingButton];
    }
    return self;
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

- (void)layoutSubviews {
    /*page 1*/
    CGSize processingLabelSize = [self.processingLabel.text boundingRectWithSize:CGSizeMake(self.scrollView.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.processingLabel.font} context:nil].size;
    processingLabelSize.height = ceilf(processingLabelSize.height);
    processingLabelSize.width = ceilf(processingLabelSize.width);
    CGFloat padding1 = (self.scrollView.bounds.size.height-processingLabelSize.height-UPD_PROCESSING_BUTTON_HEIGHT)/3;
    [self.processingLabel setFrame:CGRectMake((self.scrollView.bounds.size.width-processingLabelSize.width)/2, padding1, processingLabelSize.width, processingLabelSize.height)];
    [self.processingButton setFrame:CGRectMake((self.scrollView.bounds.size.width-UPD_PROCESSING_BUTTON_WIDTH)/2, padding1+processingLabelSize.height+padding1, UPD_PROCESSING_BUTTON_WIDTH, UPD_PROCESSING_BUTTON_HEIGHT)];
    
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
        [self.checkmark setFrame:newCheckFrame];
        [self.outline setFrame:newCheckFrame];
        [self.outlineQuarter setFrame:newCheckFrame];
        [self.scrollView setFrame:newScrollViewFrame];
    }
}

- (void)processInstructions:(NSArray *)instructions {
    self.instructionProcessor = [[UPDInstructionProcessor alloc] init];
    [self.instructionProcessor setInstructions:instructions];
    [self.instructionProcessor beginProcessing];
}

@end
