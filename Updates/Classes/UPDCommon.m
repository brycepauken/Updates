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
 General UI
 */
const int UPD_ALERT_BUTTON_HEIGHT = 50;
const int UPD_ALERT_BUTTON_ICON_SIZE = 16;
const int UPD_ALERT_PADDING = 20;
const int UPD_ALERT_WIDTH = 280;
const int UPD_BOTTOM_BAR_BUTTON_SIZE = 16;
const int UPD_CONFIRM_BUTTON_SIZE = 140;
const int UPD_CONFIRM_LABEL_WIDTH = 300;
const int UPD_PREBROWSER_URL_BAR_BUTTON_SIZE = 16; /*this is just the size of the button image, the button itself is a square based on the bar's height*/
const int UPD_PREBROWSER_URL_BAR_HEIGHT = 50;
const int UPD_PREBROWSER_URL_BAR_WIDTH = 280;
const int UPD_PROCESSING_SCROLLVIEW_SIZE = 280;
const int UPD_SEARCH_ENGINE_ICON_PADDING = 10;
const int UPD_SEARCH_ENGINE_ICON_SIZE = 50;
const int UPD_START_LABEL_WIDTH = 300;
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

@end