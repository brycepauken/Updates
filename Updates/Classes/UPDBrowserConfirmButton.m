//
//  UPDBrowserConfirmButton.m
//  Updates
//
//  Created by Bryce Pauken on 7/21/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDBrowserConfirmButton.h"

@interface UPDBrowserConfirmButton()

@property (nonatomic, strong) UIImageView *checkmark;
@property (nonatomic, strong) UIImageView *outline;

@end

@implementation UPDBrowserConfirmButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.outline = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.outline setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.outline setImage:[UIImage imageNamed:@"ButtonOutline"]];
        [self addSubview:self.outline];
        
        self.checkmark = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.checkmark setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.checkmark setImage:[UIImage imageNamed:@"AcceptLarge"]];
        [self addSubview:self.checkmark];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self.outline setAlpha:highlighted?0.5:1];
    [self.checkmark setAlpha:highlighted?0.5:1];
}

@end
