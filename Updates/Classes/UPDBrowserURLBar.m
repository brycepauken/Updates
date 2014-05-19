//
//  UPDBrowserURLBar.m
//  Updates
//
//  Created by Bryce Pauken on 5/18/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDBrowserURLBar.h"

@implementation UPDBrowserURLBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [self setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setClipsToBounds:NO];
        [self setDelegate:self];
        [self setKeyboardType:UIKeyboardTypeURL];
        [self setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18]];
        [self setPlaceholder:@"http://"];
        [self setReturnKeyType:UIReturnKeyGo];
        [self setTextColor:[UIColor UPDOffBlackColor]];
        [self.layer setCornerRadius:4];
    }
    return self;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 8, 0);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(self.startEditingBlock) {
        self.startEditingBlock();
    }
    [self performSelectorOnMainThread:@selector(selectAll:) withObject:self waitUntilDone:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if(self.goBlock) {
        self.goBlock(self.text);
    }
    return YES;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 8, 0);
}

@end
