//
//  UPDPreBrowserTextField.m
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 Making our own subclass of UITextField allows us to give the
 text a bit of padding—we'll also set up the text field here,
 while we're at it.
 */

#import "UPDPreBrowserTextField.h"

@implementation UPDPreBrowserTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [self setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self setBackgroundColor:[UIColor UPDOffWhiteColor]];
        [self setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self setClipsToBounds:NO];
        [self setFont:[UIFont systemFontOfSize:18]];
        [self setKeyboardType:UIKeyboardTypeWebSearch];
        [self setPlaceholder:@"Enter Address"];
        [self setReturnKeyType:UIReturnKeyGo];
        [self setTextColor:[UIColor darkGrayColor]];
    }
    return self;
}

/*
 The returned CGRect's width has an extra 20 pixels removed so
 that the text doesn't overlap the clear button.
 */
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x+10, bounds.origin.y, bounds.size.width-30, bounds.size.height);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

@end
