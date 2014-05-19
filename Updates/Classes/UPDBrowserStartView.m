//
//  UPDBrowserStartView.m
//  Updates
//
//  Created by Bryce Pauken on 5/17/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDBrowserStartView.h"

#import "UPDBrowserStartViewTextField.h"

@implementation UPDBrowserStartView

static NSArray *searchEngineNames;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.keyboardHeight = 0;
        if(!searchEngineNames) {
            searchEngineNames = [NSArray arrayWithObjects:@"Google",@"Bing",@"Yahoo",nil];
        }
        
        [self setBackgroundColor:[UIColor UPDBrowserStartColor]];
        
        self.textField = [[UPDBrowserStartViewTextField alloc] initWithFrame:CGRectMake((self.bounds.size.width-280)/2, (self.bounds.size.height-50)/2-75, 280, 50)];
        [self addSubview:self.textField];
        
        CGFloat searchEngineContainerWidth = [searchEngineNames count]*60-10;
        self.searchEngineContainer = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width-searchEngineContainerWidth)/2, (self.bounds.size.height-50)/2+25, searchEngineContainerWidth, 50)];
        for(int i=0;i<[searchEngineNames count];i++) {
            UIButton *searchEngine = [[UIButton alloc] initWithFrame:CGRectMake(i*60, 0, 50, 50)];
            [searchEngine addTarget:self action:@selector(searchEngineSelected:) forControlEvents:UIControlEventTouchUpInside];
            [searchEngine setImage:[UIImage imageNamed:[@"SearchEngineIcon" stringByAppendingString:[searchEngineNames objectAtIndex:i]]] forState:UIControlStateNormal];
            [searchEngine setTag:i];
            [searchEngine.layer setCornerRadius:4];
            [searchEngine.layer setMasksToBounds:YES];
            [self.searchEngineContainer addSubview:searchEngine];
        }
        [self addSubview:self.searchEngineContainer];
        
        NSString *searchEngineLabelText = @"or start with your favorite search engine";
        UIFont *searchEngineLabelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
        CGSize searchEngineLabelSize = [UPDCommon sizeOfText:searchEngineLabelText withFont:searchEngineLabelFont singleLine:YES];
        self.searchEngineLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.searchEngineContainer.frame.size.width-searchEngineLabelSize.width)/2, -searchEngineLabelSize.height-5, searchEngineLabelSize.width, searchEngineLabelSize.height)];
        [self.searchEngineLabel setFont:searchEngineLabelFont];
        [self.searchEngineLabel setText:searchEngineLabelText];
        [self.searchEngineLabel setTextColor:[UIColor whiteColor]];
        [self.searchEngineContainer addSubview:self.searchEngineLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)animateElements {
    POPSpringAnimation *textFieldAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    textFieldAnimation.toValue = @(((self.bounds.size.height-self.keyboardHeight)-50)/2-25*(self.keyboardHeight>0?0.4:1));
    textFieldAnimation.velocity = @(1000);
    [self.textField.layer pop_addAnimation:textFieldAnimation forKey:@"repositionForKeyboard"];
    
    POPSpringAnimation *searchEngineContainerAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    searchEngineContainerAnimation.toValue = @(((self.bounds.size.height-self.keyboardHeight)-50)/2+50+25*(self.keyboardHeight>0?0.4:1));
    searchEngineContainerAnimation.velocity = @(1000);
    [self.searchEngineContainer.layer pop_addAnimation:searchEngineContainerAnimation forKey:@"repositionForKeyboard"];
    
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.searchEngineLabel setAlpha:self.keyboardHeight>0?0:1];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.keyboardHeight = 0;
    [self animateElements];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardRect;
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardRect];
    keyboardRect = [self convertRect:keyboardRect fromView:self.window];
    self.keyboardHeight = keyboardRect.size.height;
    [self animateElements];
}

- (void)layoutSubviews {
    [self.textField.layer pop_removeAllAnimations];
    [self.textField.layer setFrame:CGRectMake((self.bounds.size.width-280)/2, ((self.bounds.size.height-self.keyboardHeight)-50)/2-75, 280, 50)];
    
    [self.searchEngineContainer.layer pop_removeAllAnimations];
    CGFloat searchEngineContainerWidth = [searchEngineNames count]*60-10;
    [self.searchEngineContainer.layer setFrame:CGRectMake((self.bounds.size.width-searchEngineContainerWidth)/2, ((self.bounds.size.height-self.keyboardHeight)-50)/2+25, searchEngineContainerWidth, 50)];

    [self.searchEngineLabel pop_removeAllAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (void)searchEngineSelected:(UIButton *)button {
    [self.textField setText:[NSString stringWithFormat:@"http://%@.com/",[[searchEngineNames objectAtIndex:button.tag] lowercaseString]]];
}

@end
