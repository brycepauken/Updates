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

@implementation UPDCommon

@end

/*
 Two UIViewAutoresizing constants, one for all-around flexible
 sizing and one for all-around flexible margins, two common combinations.
 */
const UIViewAutoresizing UIViewAutoresizingFlexibleMargins = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
const UIViewAutoresizing UIViewAutoresizingFlexibleSize = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

/*
 General values
 */
const NSTimeInterval UPD_TRANSITION_DURATION = 0.25;
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
const int UPD_PREBROWSER_URL_BAR_BUTTON_SIZE = 16; /*this is just the size of the button image, the button itself is square*/
const int UPD_PREBROWSER_URL_BAR_HEIGHT = 50;
const int UPD_PREBROWSER_URL_BAR_WIDTH = 280;
const int UPD_SEARCH_ENGINE_ICON_PADDING = 10;
const int UPD_SEARCH_ENGINE_ICON_SIZE = 50;
const int UPD_START_LABEL_WIDTH = 300;