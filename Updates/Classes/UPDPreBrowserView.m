//
//  UPDPreBrowserView.m
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 The pre-browser view acts as a starting point for—or more
 accurately, a place to find the starting point of—the web view.
 */

#import "UPDPreBrowserView.h"

#import "UPDPreBrowserURLBar.h"

@interface UPDPreBrowserView()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic, strong) UILabel *navigationLabel;
@property (nonatomic, strong) NSArray *searchEngineButtons;
@property (nonatomic, strong) UILabel *searchEngineLabel;
@property (nonatomic, strong) UPDPreBrowserURLBar *urlBar;

@end

@implementation UPDPreBrowserView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        
        self.navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(UPD_NAVIGATION_BAR_BUTTON_PADDING*2+UPD_NAVIGATION_BAR_BUTTON_SIZE, 20, self.bounds.size.width-(UPD_NAVIGATION_BAR_BUTTON_PADDING*2+UPD_NAVIGATION_BAR_BUTTON_SIZE)*2, UPD_NAVIGATION_BAR_HEIGHT-20)];
        [self.navigationLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:14]];
        [self.navigationLabel setTextAlignment:NSTextAlignmentCenter];
        [self.navigationLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self addSubview:self.navigationLabel];
        NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString:@"STARTING POINT"];
        [labelText addAttribute:NSKernAttributeName value:@(6.0) range:NSMakeRange(0, labelText.length)];
        [self.navigationLabel setAttributedText:labelText];
        
        self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(UPD_NAVIGATION_BAR_BUTTON_PADDING-UPD_NAVIGATION_BAR_BUTTON_SIZE/2, 20+((UPD_NAVIGATION_BAR_HEIGHT-20)-UPD_NAVIGATION_BAR_BUTTON_SIZE*2)/2, UPD_NAVIGATION_BAR_BUTTON_SIZE*2, UPD_NAVIGATION_BAR_BUTTON_SIZE*2)];
        [self.backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [self.backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
        [self.backButton setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8)];
        [self.backButton.layer setBorderColor:[UIColor UPDOffWhiteColor].CGColor];
        [self.backButton.layer setBorderWidth:2];
        [self.backButton.layer setCornerRadius:4];
        [self addSubview:self.backButton];
        
        self.urlBar = [[UPDPreBrowserURLBar alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_PREBROWSER_URL_BAR_WIDTH)/2, (self.bounds.size.height-UPD_PREBROWSER_URL_BAR_HEIGHT)/2, UPD_PREBROWSER_URL_BAR_WIDTH, UPD_PREBROWSER_URL_BAR_HEIGHT)];
        [self addSubview:self.urlBar];
        
        self.searchEngineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.urlBar.frame.origin.y+self.urlBar.frame.size.height+20, self.bounds.size.width-20, 50)];
        [self.searchEngineLabel setFont:[UIFont systemFontOfSize:16]];
        [self.searchEngineLabel setNumberOfLines:0];
        [self.searchEngineLabel setTag:1]; /*tag==1 means can be visible, same for search engine buttons*/
        [self.searchEngineLabel setTextAlignment:NSTextAlignmentCenter];
        [self.searchEngineLabel setTextColor:[UIColor UPDOffWhiteColor]];
        [self.searchEngineLabel setUserInteractionEnabled:YES];
        [self addSubview:self.searchEngineLabel];
        NSMutableAttributedString* searchEngineText = [[NSMutableAttributedString alloc]initWithString:@"or start with your\n favorite search engine"];
        [searchEngineText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(3, 10)];
        [self.searchEngineLabel setAttributedText:searchEngineText];
        UITapGestureRecognizer *searchEngineLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchEngineLabelTapped)];
        [self.searchEngineLabel addGestureRecognizer:searchEngineLabelTap];
        
        self.searchEngineButtons = @[[[UIButton alloc] init],[[UIButton alloc] init],[[UIButton alloc] init],[[UIButton alloc] init]];
        for(int i=0;i<self.searchEngineButtons.count;i++) {
            UIButton *button = [self.searchEngineButtons objectAtIndex:i];
            [button addTarget:self action:@selector(searchEngineSelected:) forControlEvents:UIControlEventTouchUpInside];
            [button setAlpha:0];
            [button setClipsToBounds:YES];
            [button setEnabled:NO];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"SearchEngineIcon%@",(i==0?@"Google":(i==1?@"Yahoo":(i==2?@"Bing":@"Duck")))]] forState:UIControlStateNormal];
            [button.layer setCornerRadius:2];
            [self addSubview:button];
        }
        
        UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
        [self addGestureRecognizer:backgroundTap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)backButtonTapped {
    if(self.backButtonBlock) {
        [self.urlBar resignFirstResponder];
        self.backButtonBlock();
    }
}

- (void)backgroundTapped {
    [self.urlBar resignFirstResponder];
}

/*
 We override hitTest so we can give buttons a larger tap area
 (an extra width in either direction, so 300% of the original
 size in each direction).
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(CGRectContainsPoint(CGRectInset(self.backButton.frame, -self.backButton.frame.size.width, -self.backButton.frame.size.height), point)) {
        return self.backButton;
    }
    return [super hitTest:point withEvent:event];
}

/*
 Only perform actions if there is an animation (otherwise, could just
 be rotation, which hides/shows keyboard instantly)
 */
- (void)keyboardWillHide:(NSNotification *)notification {
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if(duration>0) {
        if(self.keyboardHeight!=0) {
            self.keyboardHeight = 0;
            [UIView animateWithDuration:duration animations:^{
                [self layoutSubviews];
            }];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat newKeyboardHeight = [self convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] toView:self.window].size.height;
    if(duration>0||self.keyboardHeight != newKeyboardHeight) {
        self.keyboardHeight = newKeyboardHeight;
        [UIView animateWithDuration:duration animations:^{
            [self layoutSubviews];
        }];
    }
}

/*
 Sets frames for some views, but also sets the alpha levels of some
 as needed, as this method is animated on keyboard hide/show
 */
- (void)layoutSubviews {
    CGFloat visibleHeight = self.bounds.size.height-self.keyboardHeight+(self.keyboardHeight?UPD_NAVIGATION_BAR_BUTTON_PADDING*2:0);
    
    [self.urlBar setFrame:CGRectMake((self.bounds.size.width-UPD_PREBROWSER_URL_BAR_WIDTH)/2, (visibleHeight-UPD_PREBROWSER_URL_BAR_HEIGHT)/2, UPD_PREBROWSER_URL_BAR_WIDTH, UPD_PREBROWSER_URL_BAR_HEIGHT)];
    [self.navigationLabel setFrame:CGRectMake(UPD_NAVIGATION_BAR_BUTTON_PADDING*2+UPD_NAVIGATION_BAR_BUTTON_SIZE, 20, self.bounds.size.width-(UPD_NAVIGATION_BAR_BUTTON_PADDING*2+UPD_NAVIGATION_BAR_BUTTON_SIZE)*2, UPD_NAVIGATION_BAR_HEIGHT-20)];
    [self.searchEngineLabel setAlpha:(self.keyboardHeight==0&&self.searchEngineLabel.tag?1:0)];
    [self.searchEngineLabel setFrame:CGRectMake(10, self.urlBar.frame.origin.y+self.urlBar.frame.size.height+20, self.bounds.size.width-20, 50)];
    
    CGFloat firstIconX = self.bounds.size.width/2-UPD_SEARCH_ENGINE_ICON_SIZE*self.searchEngineButtons.count/2.0-UPD_SEARCH_ENGINE_ICON_PADDING*(self.searchEngineButtons.count-1)/2.0;
    for(int i=0;i<self.searchEngineButtons.count;i++) {
        UIButton *button = [self.searchEngineButtons objectAtIndex:i];
        [button setAlpha:(self.keyboardHeight==0&&button.tag?1:0)];
        [button setFrame:CGRectMake(firstIconX+(UPD_SEARCH_ENGINE_ICON_SIZE+UPD_SEARCH_ENGINE_ICON_PADDING)*i, self.urlBar.frame.origin.y+self.urlBar.frame.size.height+20, UPD_SEARCH_ENGINE_ICON_SIZE, UPD_SEARCH_ENGINE_ICON_SIZE)];
    }
}

/*
 Sets the pre browser view to its original state. This probably should
 never be called when the view is visible—rather, just before it appears.
 */
- (void)reset {
    [self.urlBar resignFirstResponder];
    self.keyboardHeight = 0;
    [self.urlBar setText:@""];
    
    [self.searchEngineLabel setAlpha:1];
    [self.searchEngineLabel setTag:1];
    
    for(UIButton *button in self.searchEngineButtons) {
        [button setAlpha:0];
        [button setTag:0];
    }
}

/*
 Animate the search engine label down off the screen, and then each
 search engine icon up (after an increasing delay). The search engine
 icons are actually located where they're supposed to end up, so we have
 to change their locations first
 */
- (void)searchEngineLabelTapped {
    CGRect searchEngineLabelFrame = self.searchEngineLabel.frame;
    searchEngineLabelFrame.origin.y = self.bounds.size.height;
    [self.searchEngineLabel setTag:0];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.searchEngineLabel setAlpha:0];
        [self.searchEngineLabel setFrame:searchEngineLabelFrame];
    } completion:^(BOOL finished) {
        [self.searchEngineLabel setFrame:CGRectMake(10, self.urlBar.frame.origin.y+self.urlBar.frame.size.height+20, self.bounds.size.width-20, 50)];
    }];
    for(int i=0;i<self.searchEngineButtons.count;i++) {
        UIButton *button = [self.searchEngineButtons objectAtIndex:i];
        CGRect goalFrame = button.frame;
        CGRect startFrame = button.frame;
        startFrame.origin.y = self.bounds.size.height;
        [button setFrame:startFrame];
        [button setTag:1];
        [UIView animateWithDuration:UPD_TRANSITION_DURATION_SLOW delay:i*0.1+0.1 options:0 animations:^{
            [button setAlpha:1];
            [button setFrame:goalFrame];
        } completion:^(BOOL finished) {
            [button setEnabled:YES];
        }];
    }
}

- (void)searchEngineSelected:(UIButton *)button {
    for(int i=0;i<self.searchEngineButtons.count;i++) {
        if([button isEqual:[self.searchEngineButtons objectAtIndex:i]]) {
            [self.urlBar setText:(i==0?@"www.google.com":(i==1?@"www.yahoo.com":(i==2?@"www.bing.com":@"www.duckduckgo.com")))];
            [self.urlBar textFieldDidChange];
            break;
        }
    }
}

/*
 Simply forwarding this along to our URL bar, which
 is in charge of the go block
 */
- (void)setGoButtonBlock:(void (^)(NSString *))goButtonBlock {
    [self.urlBar setGoButtonBlock:goButtonBlock];
}

@end
