//
//  UPDCommon.h
//  Updates
//
//  Created by Bryce Pauken on 7/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Security/Security.h>
#import "UIColor+UPDColors.h"

@interface UPDCommon : NSObject

+ (void)clearKeychainData;
+ (NSString *)getEncryptedPassword:(void (^)(NSString *encryptedPassword))completionBlock;
+ (BOOL)passwordSaved;
+ (BOOL)passwordSet;
+ (void)saveKeychainDataWithCancelBlock:(void (^)())cancelBlock;

@end

extern const UIViewAutoresizing UIViewAutoresizingFlexibleMargins;
extern const UIViewAutoresizing UIViewAutoresizingFlexibleSize;

extern const CGFloat UPD_DOUBLE_FOLD_CHANCE;
extern const NSTimeInterval UPD_PROCESSING_ANIMATION_DURATION;
extern const NSTimeInterval UPD_TRANSITION_DELAY;
extern const NSTimeInterval UPD_TRANSITION_DURATION;
extern const NSTimeInterval UPD_TRANSITION_DURATION_FAST;
extern const NSTimeInterval UPD_TRANSITION_DURATION_SLOW;

extern const int UPD_NAVIGATION_BAR_BUTTON_PADDING;
extern const int UPD_NAVIGATION_BAR_BUTTON_SIZE;
extern const int UPD_NAVIGATION_BAR_BUTTON_SIZE_SETTINGS;
extern const int UPD_NAVIGATION_BAR_HEIGHT;

extern const int UPD_TABLEVIEW_CELL_HEIGHT;
extern const int UPD_TABLEVIEW_CELL_LEFT_BAR_WIDTH;
extern const int UPD_TABLEVIEW_CELL_LEFT_WIDTH;
extern const int UPD_TABLEVIEW_CELL_LOCK_SIZE;
extern const int UPD_TABLEVIEW_CIRCLE_SIZE;
extern const int UPD_TABLEVIEW_FAVICON_SIZE;
extern const int UPD_TABLEVIEW_LABEL_WIDTH;
extern const int UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT;

extern const int UPD_ALERT_BUTTON_HEIGHT;
extern const int UPD_ALERT_BUTTON_ICON_SIZE;
extern const int UPD_ALERT_BUTTON_PADDING;
extern const int UPD_ALERT_CANCEL_BUTTON_SIZE;
extern const int UPD_ALERT_PADDING;
extern const int UPD_ALERT_WIDTH;
extern const int UPD_BOTTOM_BAR_BUTTON_SIZE;
extern const int UPD_CONFIRM_BUTTON_SIZE;
extern const int UPD_CONFIRM_LABEL_WIDTH;
extern const int UPD_HELPVIEW_CELL_FONT_SIZE;
extern const int UPD_HELPVIEW_HEIGHT;
extern const int UPD_PREBROWSER_URL_BAR_BUTTON_SIZE;
extern const int UPD_PREBROWSER_URL_BAR_HEIGHT;
extern const int UPD_PREBROWSER_URL_BAR_WIDTH;
extern const int UPD_PROCESSING_BUTTON_HEIGHT;
extern const int UPD_PROCESSING_BUTTON_WIDTH;
extern const int UPD_PROCESSING_SCROLLVIEW_SIZE;
extern const int UPD_PROCESSING_TEXTFIELD_HEIGHT;
extern const int UPD_SEARCH_ENGINE_ICON_PADDING;
extern const int UPD_SEARCH_ENGINE_ICON_SIZE;
extern const int UPD_SETTINGS_BUTTON_HEIGHT;
extern const int UPD_SETTINGS_BUTTON_WIDTH;
extern const int UPD_SWITCH_ICON_SIZE;
extern const int UPD_SWITCH_PADDING;
extern const int UPD_SWITCH_SIZE_HEIGHT;
extern const int UPD_SWITCH_SIZE_WIDTH;
extern const int UPD_TEXT_SEARCH_BAR_BUTTON_SIZE;
extern const int UPD_TEXT_SEARCH_BAR_HEIGHT;
extern const int UPD_UPGRADE_SPINNER_SIZE;
extern const int UPD_URL_BAR_HEIGHT;
extern const int UPD_URL_BAR_PADDING;
extern const CGFloat UPD_BROWSER_IMAGE_OPACITY;
extern const CGFloat UPD_BROWSER_IMAGE_SCALE;

extern const NSTimeInterval UPD_FOLDED_VIEW_ANIMATION_TIME;
extern CGFloat UPD_FOLDED_VIEW_GRAVITY;