//
//  UPDBrowserStartViewTextField.m
//  Updates
//
//  Created by Bryce Pauken on 5/17/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDBrowserStartViewTextField.h"

@implementation UPDBrowserStartViewTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [self setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setClipsToBounds:YES];
        [self setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24]];
        [self setPlaceholder:@"http://"];
        [self setTextColor:[UIColor UPDOffBlackColor]];
        [self.layer setCornerRadius:4];
        
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-self.bounds.size.height-1, -1, self.bounds.size.height+2, self.bounds.size.height+2)];
        [self.button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.button setBackgroundImage:[UIImage imageNamed:@"SearchBarArrow"] forState:UIControlStateNormal];
        [self.button.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.button.layer setBorderWidth:1];
        [self.button.layer setCornerRadius:4];
        [self addSubview:self.button];
    }
    return self;
}

- (void)buttonTapped {
    if(self.goBlock) {
        [self resignFirstResponder];
        self.goBlock(self.text);
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(15, 0, bounds.size.width-bounds.size.height-15, bounds.size.height);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(15, 0, bounds.size.width-bounds.size.height-15, bounds.size.height);
}

@end
