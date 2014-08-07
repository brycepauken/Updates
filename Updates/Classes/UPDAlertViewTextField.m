//
//  UPDAlertViewTextField.m
//  Updates
//
//  Created by Bryce Pauken on 8/6/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDAlertViewTextField.h"

@implementation UPDAlertViewTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDOffWhiteColor]];
        [self setClipsToBounds:NO];
        [self setFont:[UIFont systemFontOfSize:18]];
        [self setPlaceholder:@"Enter Password"];
        [self setReturnKeyType:UIReturnKeyDone];
        [self setSecureTextEntry:YES];
        [self setTextColor:[UIColor darkGrayColor]];
        [self.layer setCornerRadius:2];
        [self.layer setMasksToBounds:YES];
    }
    return self;
}

/*
 The returned CGRect's width has an extra 20 pixels removed so
 that the text doesn't overlap the clear button.
 */
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

@end
