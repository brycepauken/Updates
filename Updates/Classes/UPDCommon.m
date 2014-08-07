//
//  UPDCommon.m
//  Updates
//
//  Created by Bryce Pauken on 7/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 Pieces of data (constants, inclusions, etc.) that are automatically
 included in every header file
 */

#import "UPDCommon.h"

#import "NSData+UPDExtensions.h"
#import "UPDAlertView.h"
#import "UPDAppDelegate.h"
#import "CoreDataModelOption.h"

/*
 Two UIViewAutoresizing constants, one for all-around flexible
 sizing and one for all-around flexible margins, two common combinations.
 */
const UIViewAutoresizing UIViewAutoresizingFlexibleMargins = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
const UIViewAutoresizing UIViewAutoresizingFlexibleSize = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

/*
 General values
 */
const CGFloat UPD_DOUBLE_FOLD_CHANCE = (1/3.0);
const NSTimeInterval UPD_PROCESSING_ANIMATION_DURATION = 1;
const NSTimeInterval UPD_TRANSITION_DELAY = 0.15;
const NSTimeInterval UPD_TRANSITION_DURATION = 0.25;
const NSTimeInterval UPD_TRANSITION_DURATION_FAST = 0.15;
const NSTimeInterval UPD_TRANSITION_DURATION_SLOW = 0.4;

/*
 Navigation bar values
 */
const int UPD_NAVIGATION_BAR_BUTTON_PADDING = 20;
const int UPD_NAVIGATION_BAR_BUTTON_SIZE = 16;
const int UPD_NAVIGATION_BAR_HEIGHT = 64;

/*
 TableView values
 */
const int UPD_TABLEVIEW_CELL_HEIGHT = 80;
const int UPD_TABLEVIEW_CELL_LEFT_BAR_WIDTH = 8;
const int UPD_TABLEVIEW_CELL_LEFT_WIDTH = 60;
const int UPD_TABLEVIEW_CIRCLE_SIZE = 12;
const int UPD_TABLEVIEW_FAVICON_SIZE = 20;
const int UPD_TABLEVIEW_LABEL_WIDTH = 300;
const int UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT = 80;

/*
 General UI
 */
const int UPD_ALERT_BUTTON_HEIGHT = 50;
const int UPD_ALERT_BUTTON_ICON_SIZE = 24;
const int UPD_ALERT_BUTTON_PADDING = 4;
const int UPD_ALERT_CANCEL_BUTTON_SIZE = 30;
const int UPD_ALERT_PADDING = 20;
const int UPD_ALERT_WIDTH = 280;
const int UPD_BOTTOM_BAR_BUTTON_SIZE = 16;
const int UPD_CONFIRM_BUTTON_SIZE = 140;
const int UPD_CONFIRM_LABEL_WIDTH = 300;
const int UPD_PREBROWSER_URL_BAR_BUTTON_SIZE = 16;
const int UPD_PREBROWSER_URL_BAR_HEIGHT = 50;
const int UPD_PREBROWSER_URL_BAR_WIDTH = 280;
const int UPD_PROCESSING_BUTTON_HEIGHT = 50;
const int UPD_PROCESSING_BUTTON_WIDTH = 100;
const int UPD_PROCESSING_SCROLLVIEW_SIZE = 280;
const int UPD_PROCESSING_TEXTFIELD_HEIGHT = 50;
const int UPD_SEARCH_ENGINE_ICON_PADDING = 10;
const int UPD_SEARCH_ENGINE_ICON_SIZE = 50;
const int UPD_TEXT_SEARCH_BAR_BUTTON_SIZE = 16;
const int UPD_TEXT_SEARCH_BAR_HEIGHT = 50;
const int UPD_URL_BAR_HEIGHT = 32;
const int UPD_URL_BAR_PADDING = 10;
const CGFloat UPD_BROWSER_IMAGE_OPACITY = 0.25;
const CGFloat UPD_BROWSER_IMAGE_SCALE = 0.8;

/*
 Browser vertical animation values—for flipping the folded
 browser image into the checkmark upon confirmation
 */
const NSTimeInterval UPD_FOLDED_VIEW_ANIMATION_TIME = UPD_TRANSITION_DURATION*4;
CGFloat UPD_FOLDED_VIEW_GRAVITY;

@implementation UPDCommon

/*
 We'll use this to set any variables that are too tricky for a one-line
 implementation (like UPD_FOLDED_VIEW_GRAVITY)
 */
+ (void)initialize {
    UPD_FOLDED_VIEW_GRAVITY = [[UIScreen mainScreen] bounds].size.height*3;
}

+ (void)getMasterPassword:(void (^)(NSString *masterPassword))completionBlock {
    [self getMasterPassword:completionBlock attemptFailed:NO];
}

/*
 Returns the user's chosen password for encrypting and decrypting data,
 or prompts them to create one if it doesn't exist yet.
 */
+ (void)getMasterPassword:(void (^)(NSString *masterPassword))completionBlock attemptFailed:(BOOL)attemptFailed {
    static NSString *masterPassword;
    if(masterPassword) {
        if(completionBlock) {
            completionBlock(masterPassword);
        }
        return;
    }
    
    NSManagedObjectContext *context = [((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]) privateObjectContext];
    
    [context performBlock:^{
        NSFetchRequest *optionEncryptionCheckRequest = [[NSFetchRequest alloc] initWithEntityName:@"Option"];
        [optionEncryptionCheckRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",@"EncryptionCheck"]];
        NSError *optionEncryptionCheckError;
        CoreDataModelOption *optionEncryptionCheck = [[context executeFetchRequest:optionEncryptionCheckRequest error:&optionEncryptionCheckError] firstObject];
        
        if(optionEncryptionCheck) {
            if(masterPassword) {
                if([[[NSString alloc] initWithData:[NSData decryptData:optionEncryptionCheck.dataValue withKey:masterPassword] encoding:NSUTF8StringEncoding] isEqualToString:@"success"]) {
                    if(completionBlock) {
                        completionBlock(masterPassword);
                    }
                    return;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                UPDAlertView *alertView = [[UPDAlertView alloc] init];
                __unsafe_unretained UPDAlertView *weakAlertView = alertView;
                [alertView setTitle:!attemptFailed?@"Enter Password":@"Incorrect Password"];
                [alertView setMessage:!attemptFailed?@"Please enter your password to continue.":@"The password you entered was incorrect. Please try again."];
                [alertView setFontSize:16];
                [alertView setMinTextLength:6];
                [alertView setTextSubmitBlock:^(NSString *text){
                    [weakAlertView dismiss];
                    if([[[NSString alloc] initWithData:[NSData decryptData:optionEncryptionCheck.dataValue withKey:text] encoding:NSUTF8StringEncoding] isEqualToString:@"success"]) {
                        masterPassword = text;
                        if(completionBlock) {
                            completionBlock(masterPassword);
                        }
                        return;
                    }
                    else {
                        [self getMasterPassword:completionBlock attemptFailed:YES];
                    }
                }];
                [alertView setCancelButtonBlock:^{
                    [weakAlertView dismiss];
                    if(completionBlock) {
                        completionBlock(nil);
                    }
                }];
                [alertView show];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UPDAlertView *alertView = [[UPDAlertView alloc] init];
                __unsafe_unretained UPDAlertView *weakAlertView = alertView;
                [alertView setTitle:!attemptFailed?@"Create a Password":@"Passwords Different"];
                [alertView setMessage:!attemptFailed?@"Enter a password to encrypt\nyour locked instructions\nand keep them safe.":@"Please enter your password again, and make sure the confirmation matches!"];
                [alertView setFontSize:16];
                [alertView setMinTextLength:6];
                [alertView setTextSubmitBlock:^(NSString *text){
                    [weakAlertView dismiss];
                    
                    UPDAlertView *confirmAlertView = [[UPDAlertView alloc] init];
                    __unsafe_unretained UPDAlertView *weakConfirmAlertView = confirmAlertView;
                    [confirmAlertView setTitle:@"Confirm Password"];
                    [confirmAlertView setMessage:@"Please enter your password\nagain, just to make sure."];
                    [confirmAlertView setFontSize:16];
                    [confirmAlertView setMinTextLength:6];
                    [confirmAlertView setTextSubmitBlock:^(NSString *confirmText){
                        [weakConfirmAlertView dismiss];
                        
                        if([text isEqualToString:confirmText]) {
                            [context performBlock:^{
                                CoreDataModelOption *optionEncryptionCheck = [NSEntityDescription insertNewObjectForEntityForName:@"Option" inManagedObjectContext:context];
                                [optionEncryptionCheck setDataValue:[NSData encryptData:[@"success" dataUsingEncoding:NSUTF8StringEncoding] withKey:text]];
                                [optionEncryptionCheck setName:@"EncryptionCheck"];
                                NSError *saveError;
                                [context save:&saveError];
                                masterPassword = text;
                                [self getMasterPassword:completionBlock attemptFailed:NO];
                            }];
                        }
                        else {
                            [self getMasterPassword:completionBlock attemptFailed:YES];
                        }
                    }];
                    [confirmAlertView setCancelButtonBlock:^{
                        [weakConfirmAlertView dismiss];
                        if(completionBlock) {
                            completionBlock(nil);
                        }
                    }];
                    [confirmAlertView show];
                }];
                [alertView setCancelButtonBlock:^{
                    [weakAlertView dismiss];
                    if(completionBlock) {
                        completionBlock(nil);
                    }
                }];
                [alertView show];
            });
        }
    }];
}

@end