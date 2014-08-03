//
//  UPDTextSearchField.m
//  Updates
//
//  Created by Bryce Pauken on 8/2/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDTextSearchField.h"

@implementation UPDTextSearchField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDOffWhiteColor]];
        [self setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self setClipsToBounds:NO];
        [self setFont:[UIFont systemFontOfSize:18]];
        [self setPlaceholder:@"Enter Text to Watch"];
        [self setReturnKeyType:UIReturnKeyDone];
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
