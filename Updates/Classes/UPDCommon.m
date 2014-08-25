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

#import <Security/Security.h>
#import "NSData+UPDExtensions.h"
#import "NSString+UPDExtensions.h"
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
const int UPD_NAVIGATION_BAR_BUTTON_SIZE_SETTINGS = 18;
const int UPD_NAVIGATION_BAR_HEIGHT = 64;

/*
 TableView values
 */
const int UPD_TABLEVIEW_CELL_HEIGHT = 80;
const int UPD_TABLEVIEW_CELL_LEFT_BAR_WIDTH = 8;
const int UPD_TABLEVIEW_CELL_LEFT_WIDTH = 60;
const int UPD_TABLEVIEW_CELL_LOCK_SIZE = 16;
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
const int UPD_ALERT_CANCEL_BUTTON_SIZE = 28;
const int UPD_ALERT_PADDING = 20;
const int UPD_ALERT_WIDTH = 280;
const int UPD_BOTTOM_BAR_BUTTON_SIZE = 16;
const int UPD_CONFIRM_BUTTON_SIZE = 140;
const int UPD_CONFIRM_LABEL_WIDTH = 300;
const int UPD_HELPVIEW_HEIGHT = 400;
const int UPD_PREBROWSER_URL_BAR_BUTTON_SIZE = 16;
const int UPD_PREBROWSER_URL_BAR_HEIGHT = 50;
const int UPD_PREBROWSER_URL_BAR_WIDTH = 280;
const int UPD_PROCESSING_BUTTON_HEIGHT = 50;
const int UPD_PROCESSING_BUTTON_WIDTH = 100;
const int UPD_PROCESSING_SCROLLVIEW_SIZE = 280;
const int UPD_PROCESSING_TEXTFIELD_HEIGHT = 50;
const int UPD_SEARCH_ENGINE_ICON_PADDING = 10;
const int UPD_SEARCH_ENGINE_ICON_SIZE = 50;
const int UPD_SETTINGS_BUTTON_HEIGHT = 50;
const int UPD_SETTINGS_BUTTON_WIDTH = 200;
const int UPD_SWITCH_ICON_SIZE = 16;
const int UPD_SWITCH_PADDING = 2;
const int UPD_SWITCH_SIZE_HEIGHT = 32;
const int UPD_SWITCH_SIZE_WIDTH = 60;
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

static NSData *keychainID;

/*
 We'll use this to set any variables that are too tricky for a one-line
 implementation (like UPD_FOLDED_VIEW_GRAVITY)
 */
+ (void)initialize {
    UPD_FOLDED_VIEW_GRAVITY = [[UIScreen mainScreen] bounds].size.height*3;
    
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        const UInt8 KeychainItemIdentifier[] = "com.kingfish.Updates.Master\0";
        keychainID = [NSData dataWithBytes:KeychainItemIdentifier length:strlen((const char *)KeychainItemIdentifier)];
    });
}

+ (void)clearKeychainData {
    NSMutableDictionary *passwordQuery = [[NSMutableDictionary alloc] init];
    [passwordQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [passwordQuery setObject:keychainID forKey:(__bridge id)kSecAttrGeneric];
    SecItemDelete((__bridge CFDictionaryRef)passwordQuery);
}

+ (NSString *)getEncryptedPassword:(void (^)(NSString *encryptedPassword))completionBlock {
    return [self getEncryptedPassword:completionBlock attemptFailed:NO];
}

/*
 Gets the user's chosen password (hashed) for encrypting and decrypting data.
 The password is returned immediately if available (either entered already, or
 saved in the keychain), or passed in the completion block if not.
 */
+ (NSString *)getEncryptedPassword:(void (^)(NSString *encryptedPassword))completionBlock attemptFailed:(BOOL)attemptFailed {
    static NSString *encryptedPassword;
    if(encryptedPassword) {
        return encryptedPassword;
    }
    
    NSString *savedPassword;
    __block BOOL returnPassword = NO;
    NSMutableDictionary *passwordQuery = [[NSMutableDictionary alloc] init];
    [passwordQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [passwordQuery setObject:keychainID forKey:(__bridge id)kSecAttrGeneric];
    [passwordQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [passwordQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    CFMutableDictionaryRef queryDictionary = nil;
    if(SecItemCopyMatching((__bridge CFDictionaryRef)passwordQuery, (CFTypeRef *)&queryDictionary) == noErr) {
        NSMutableDictionary *passwordDictionary = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSMutableDictionary *)queryDictionary];
        [passwordDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
        [passwordDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        CFDataRef passwordData = NULL;
        OSStatus keychainError = noErr;
        keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)passwordDictionary, (CFTypeRef *)&passwordData);
        if(keychainError == noErr) {
            [passwordDictionary removeObjectForKey:(__bridge id)kSecReturnData];
            NSString *password = [[NSString alloc] initWithBytes:[(__bridge_transfer NSData *)passwordData bytes] length:[(__bridge NSData *)passwordData length] encoding:NSUTF8StringEncoding];
            if(password.length) {
                savedPassword = password;
            }
        }
        else {
            if(passwordData) {
                CFRelease(passwordData);
            }
        }
    }
    else {
        if(queryDictionary){
            CFRelease(queryDictionary);
        }
    }
    
    NSManagedObjectContext *context = [((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]) privateObjectContext];
    [context performBlockAndWait:^{
        NSFetchRequest *optionEncryptionCheckRequest = [[NSFetchRequest alloc] initWithEntityName:@"Option"];
        [optionEncryptionCheckRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",@"EncryptionCheck"]];
        NSError *optionEncryptionCheckError;
        CoreDataModelOption *optionEncryptionCheck = [[context executeFetchRequest:optionEncryptionCheckRequest error:&optionEncryptionCheckError] firstObject];
        
        if(optionEncryptionCheck) {
            if(savedPassword) {
                if([[[NSString alloc] initWithData:[NSData decryptData:optionEncryptionCheck.dataValue withKey:savedPassword] encoding:NSUTF8StringEncoding] isEqualToString:@"success"]) {
                    encryptedPassword = savedPassword;
                    returnPassword = YES;
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
                    NSString *hashedString = [text hashedString];
                    if([[[NSString alloc] initWithData:[NSData decryptData:optionEncryptionCheck.dataValue withKey:hashedString] encoding:NSUTF8StringEncoding] isEqualToString:@"success"]) {
                        encryptedPassword = hashedString;
                        if(completionBlock) {
                            completionBlock(encryptedPassword);
                        }
                        return;
                    }
                    else {
                        [self getEncryptedPassword:completionBlock attemptFailed:YES];
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
                            UPDAlertView *savePasswordAlertView = [[UPDAlertView alloc] init];
                            __unsafe_unretained UPDAlertView *weakSavePasswordAlertView = savePasswordAlertView;
                            NSString *hashedText = [text hashedString];
                            void (^finishBlock)() = ^{
                                [weakSavePasswordAlertView dismiss];
                                [context performBlockAndWait:^{
                                    CoreDataModelOption *optionEncryptionCheck = [NSEntityDescription insertNewObjectForEntityForName:@"Option" inManagedObjectContext:context];
                                    [optionEncryptionCheck setDataValue:[NSData encryptData:[@"success" dataUsingEncoding:NSUTF8StringEncoding] withKey:hashedText]];
                                    [optionEncryptionCheck setName:@"EncryptionCheck"];
                                    NSError *saveError;
                                    [context save:&saveError];
                                    encryptedPassword = hashedText;
                                    if(completionBlock) {
                                        completionBlock(encryptedPassword);
                                    }
                                }];
                            };
                            [savePasswordAlertView setTitle:@"Save Password"];
                            [savePasswordAlertView setMessage:@"Would you like to save your password on this device? If not, you'll have to enter your password every time you start this app."];
                            [savePasswordAlertView setFontSize:16];
                            [savePasswordAlertView setMinTextLength:6];
                            [savePasswordAlertView setYesButtonBlock:^{
                                NSMutableDictionary *keychainDictionary = [NSMutableDictionary dictionary];
                                [keychainDictionary setObject:keychainID forKey:(__bridge id)kSecAttrGeneric];
                                [keychainDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
                                [keychainDictionary setObject:[hashedText dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
                                SecItemAdd((__bridge CFDictionaryRef)keychainDictionary,NULL);
                                finishBlock();
                            }];
                            [savePasswordAlertView setNoButtonBlock:^{
                                finishBlock();
                            }];
                            [savePasswordAlertView show];
                        }
                        else {
                            [self getEncryptedPassword:completionBlock attemptFailed:YES];
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
    if(returnPassword) {
        return encryptedPassword;
    }
    return nil;
}

+ (BOOL)passwordSaved {
    NSMutableDictionary *passwordQuery = [[NSMutableDictionary alloc] init];
    [passwordQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [passwordQuery setObject:keychainID forKey:(__bridge id)kSecAttrGeneric];
    [passwordQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [passwordQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    CFMutableDictionaryRef queryDictionary = nil;
    return (SecItemCopyMatching((__bridge CFDictionaryRef)passwordQuery, (CFTypeRef *)&queryDictionary) == noErr);
}

+ (BOOL)passwordSet {
    __block BOOL returnVal;
    NSManagedObjectContext *context = [((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]) privateObjectContext];
    [context performBlockAndWait:^{
        NSFetchRequest *optionEncryptionCheckRequest = [[NSFetchRequest alloc] initWithEntityName:@"Option"];
        [optionEncryptionCheckRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",@"EncryptionCheck"]];
        NSError *optionEncryptionCheckError;
        CoreDataModelOption *optionEncryptionCheck = [[context executeFetchRequest:optionEncryptionCheckRequest error:&optionEncryptionCheckError] firstObject];
        returnVal = !!optionEncryptionCheck;
    }];
    return returnVal;
}

+ (void)saveKeychainDataWithCancelBlock:(void (^)())cancelBlock {
    void (^completionBlock)(NSString *hashedText) = ^(NSString *hashedText) {
        NSMutableDictionary *keychainDictionary = [NSMutableDictionary dictionary];
        [keychainDictionary setObject:keychainID forKey:(__bridge id)kSecAttrGeneric];
        [keychainDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [keychainDictionary setObject:[hashedText dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        SecItemAdd((__bridge CFDictionaryRef)keychainDictionary,NULL);
    };
    NSString *encryptedPassword = [self getEncryptedPassword:^(NSString *encryptedPass) {
        if(encryptedPass.length) {
            completionBlock(encryptedPass);
        }
        else {
            if(cancelBlock) {
                cancelBlock();
            }
        }
    }];
    if(encryptedPassword.length) {
        completionBlock(encryptedPassword);
    }
}

@end