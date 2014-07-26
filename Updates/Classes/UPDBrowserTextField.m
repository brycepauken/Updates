//
//  UPDBrowserTextField.m
//  Updates
//
//  Created by Bryce Pauken on 7/17/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDBrowserTextField.h"

@implementation UPDBrowserTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [self setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self setBackgroundColor:[UIColor UPDOffWhiteColor]];
        [self setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self setClipsToBounds:YES];
        [self setFont:[UIFont systemFontOfSize:18]];
        [self setKeyboardType:UIKeyboardTypeWebSearch];
        [self setPlaceholder:@"Enter Address"];
        [self setReturnKeyType:UIReturnKeyGo];
        [self setTextAlignment:NSTextAlignmentNatural];
        [self setTextColor:[UIColor darkGrayColor]];
    }
    return self;
}

/*
 The returned CGRect's width has an extra 20 pixels removed so
 that the text doesn't overlap the clear button.
 */
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x+10, bounds.origin.y, bounds.size.width-40, bounds.size.height);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

@end
