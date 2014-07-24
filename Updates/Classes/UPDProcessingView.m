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

#import "UPDInstructionProcessor.h"

@interface UPDProcessingView()

@property (nonatomic, strong) UIImageView *checkmark;
@property (nonatomic, strong) UPDInstructionProcessor *instructionProcessor;
@property (nonatomic, strong) UIImageView *outline;
@property (nonatomic, strong) UIImageView *outlineQuarter;

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
    
    [UIView animateWithDuration:UPD_PROCESSING_ANIMATION_DURATION animations:^{
        [self.outline setAlpha:0];
        
        CGRect newFrame = CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height/2-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE);
        [self.checkmark setFrame:newFrame];
        [self.outline setFrame:newFrame];
        [self.outlineQuarter setFrame:newFrame];
        [self.processing setFrame:newFrame];
    }];
}

- (void)processInstructions:(NSArray *)instructions {
    self.instructionProcessor = [[UPDInstructionProcessor alloc] init];
    [self.instructionProcessor setInstructions:instructions];
    [self.instructionProcessor beginProcessing];
}

@end
