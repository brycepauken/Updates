//
//  UPDBrowserView.m
//  Updates
//
//  Created by Bryce Pauken on 5/17/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDBrowserView.h"

#import "UPDBrowserBottomBar.h"
#import "UPDBrowserNavigationBar.h"
#import "UPDBrowserStartView.h"
#import "UPDBrowserStartViewTextField.h"
#import "UPDBrowserURLBar.h"
#import "UPDDocumentParser.h"
#import "UPDInstruction.h"
#import "UPDInstructionList.h"
#import "UPDKeyValue.h"

/*
 Instructions:
 
 @dynamic instructionNumber;
 @dynamic url;
 @dynamic anchor;
 @dynamic response;
 @dynamic parentList;
 @dynamic headers;
 @dynamic post;
 @dynamic get;
 */

@implementation UPDBrowserView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        __weak UPDBrowserView *weakSelf = self;
        
        self.instructionList = [NSEntityDescription insertNewObjectForEntityForName:@"InstructionList" inManagedObjectContext:AppDelegate.temporaryObjectContext];
        [AppDelegate setAddInstruction:^(NSString *url, NSString *post, NSString *response, NSDictionary *headers, NSString *redirectURL) {
            UPDInstruction *instruction = [NSEntityDescription insertNewObjectForEntityForName:@"Instruction" inManagedObjectContext:AppDelegate.temporaryObjectContext];
            instruction.instructionNumber = @(self.instructionList.instructions.count);
            [instruction setInstructionNumber:@(self.instructionList.instructions.count)];
            [instruction setParentList:self.instructionList];
            
            [instruction setResponse:response];
            [instruction setRedirectURL:redirectURL];
            [instruction setUrl:([url rangeOfString:@"?" options:NSBackwardsSearch].location==NSNotFound?url:[url substringToIndex:[url rangeOfString:@"?" options:NSBackwardsSearch].location])];
            NSURL *tempURL = [NSURL URLWithString:url];
            for(int getOrPost=0;getOrPost<2;getOrPost++) {
                NSString *targetString = (getOrPost?post:tempURL.query);
                if(targetString.length) {
                    NSMutableSet *params = [[NSMutableSet alloc] init];
                    for(NSString *param in [targetString componentsSeparatedByString:@"&"]) {
                        NSArray *elements = [param componentsSeparatedByString:@"="];
                        if(elements.count==2) {
                            UPDKeyValue *keyValue = [NSEntityDescription insertNewObjectForEntityForName:@"KeyValue" inManagedObjectContext:AppDelegate.temporaryObjectContext];
                            [keyValue setKey:[elements objectAtIndex:0]];
                            [keyValue setValue:[elements objectAtIndex:1]];
                            if(getOrPost==0) {
                                [keyValue setGetParent:instruction];
                            }
                            else {
                                [keyValue setPostParent:instruction];
                            }
                            [params addObject:keyValue];
                        }
                    }
                    if(getOrPost==0) {
                        [instruction setGet:params];
                    }
                    else {
                        [instruction setPost:params];
                    }
                }
            }
            
            NSMutableSet *instructions = [self.instructionList.instructions mutableCopy];
            [instructions addObject:instruction];
            [self.instructionList setInstructions:instructions];
        }];
        
        CGFloat navigationBarHeight = UPD_NAVIGATION_BAR_HEIGHT+([UPDCommon isIOS7]?20:0);
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.bounds.size.width, self.bounds.size.height-navigationBarHeight-UPD_NAVIGATION_BAR_HEIGHT)];
        [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.webView setDelegate:self];
        [self addSubview:self.webView];
        
        self.webViewOverlay = [[UIView alloc] initWithFrame:self.webView.frame];
        [self.webViewOverlay setAlpha:0];
        [self.webViewOverlay setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.webViewOverlay setBackgroundColor:[UIColor blackColor]];
        [self addSubview:self.webViewOverlay];
        UITapGestureRecognizer *webViewOverlayTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webViewOverlayTapped)];
        [webViewOverlayTapRecognizer setDelegate:self];
        [self.webViewOverlay addGestureRecognizer:webViewOverlayTapRecognizer];
        
        self.navigationBar = [[UPDBrowserNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, navigationBarHeight)];
        [self.navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.navigationBar.urlBar setStartEditingBlock:^{
            [weakSelf.webViewOverlay setTag:1];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.webViewOverlay setAlpha:0.5];
            }];
        }];
        [self.navigationBar.urlBar setGoBlock:^(NSString *url){
            [weakSelf.webViewOverlay setTag:0];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.webViewOverlay setAlpha:0];
            }];
            [weakSelf loadURL:url];
        }];
        [self addSubview:self.navigationBar];
        
        self.bottomBar = [[UPDBrowserBottomBar alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-UPD_NAVIGATION_BAR_HEIGHT, self.bounds.size.width, UPD_NAVIGATION_BAR_HEIGHT)];
        [self.bottomBar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [self.bottomBar setFinishButtonBlock:^{
            NSMutableString *output = [[NSMutableString alloc] init];
            for(UPDInstruction *instruction in weakSelf.instructionList.instructions) {
                [output appendString:@"****************\n"];
                [output appendString:[NSString stringWithFormat:@"%i: %@\n",instruction.instructionNumber.intValue,instruction.url]];
                [output appendString:@"****************\n"];
                if(instruction.post.count) {
                    [output appendString:@"    Post Data:\n"];
                    for(UPDKeyValue *keyValue in instruction.post) {
                        [output appendString:[NSString stringWithFormat:@"        %@: %@\n",[[keyValue.key stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[keyValue.value stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    }
                }
                if(instruction.response) {
                    /*[output appendString:@"    Response:\n"];
                    [output appendString:instruction.response];
                    [output appendString:@"\n"];*/
                    [output appendString:@"    Response Input Fields:\n"];
                    
                    UPDDocumentParser *documentParser = [[UPDDocumentParser alloc] initWithDocumentString:instruction.response];
                    NSDictionary *inputFields = [documentParser findInputFields];
                    for(NSString *inputName in [inputFields allKeys]) {
                        [output appendString:[NSString stringWithFormat:@"        %@ -> %@\n",inputName,[inputFields objectForKey:inputName]]];
                    }
                }
            }
            NSLog(@"%@",output);
        }];
        [self addSubview:self.bottomBar];
        
        self.startView = [[UPDBrowserStartView alloc] initWithFrame:self.bounds];
        [self.startView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.startView.textField setGoBlock:^(NSString *url) {
            [weakSelf.navigationBar.urlBar setText:url];
            [weakSelf clearCookies];
            [weakSelf loadURL:url];
            
            POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
            anim.completionBlock = ^(POPAnimation *a, BOOL finished) {
                [weakSelf.startView removeFromSuperview];
            };
            anim.toValue = @(-weakSelf.startView.bounds.size.width);
            anim.velocity = @(200);
            [weakSelf.startView.layer pop_addAnimation:anim forKey:@"disappear"];
            
            [AppDelegate.viewController setHideStatusBar:YES];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION/2.0f animations:^{
                [AppDelegate.viewController setNeedsStatusBarAppearanceUpdate];
            } completion:^(BOOL finished) {
                [AppDelegate.viewController setHideStatusBar:NO];
                [AppDelegate.viewController setLightStatusBarContent:NO];
                [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                    [AppDelegate.viewController setNeedsStatusBarAppearanceUpdate];
                }];
            }];
        }];
        
        [self addSubview:self.startView];
    }
    return self;
}

- (void)clearCookies {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(gestureRecognizer.view==self.webViewOverlay&&self.webViewOverlay.tag==0) {
        return NO;
    }
    return YES;
}

- (void)loadURL:(NSString *)url {
    [self.navigationBar resetProgressBarWithFade:NO];
    [self.navigationBar progressBarAnimateToWidth:0.9 withDuration:5 onCompletion:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(!self.navigationBar.progressBarVisible) {
        [self.navigationBar progressBarAnimateToWidth:0.9 withDuration:5 onCompletion:nil];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.navigationBar.urlBar setText:webView.request.mainDocumentURL.absoluteString];
    [self.navigationBar progressBarAnimateToWidth:1 withDuration:0.3 onCompletion:^(BOOL finished) {
        [self.navigationBar performSelector:@selector(resetProgressBar) withObject:nil afterDelay:0.5];
    }];
}

- (void)webViewOverlayTapped {
    [self.webViewOverlay setTag:0];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
        [self.webViewOverlay setAlpha:0];
    }];
    [self.navigationBar.urlBar resignFirstResponder];
}

@end
