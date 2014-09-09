//
//  UPDUpgradeController.h
//  Updates
//
//  Created by Bryce Pauken on 9/4/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, UPDUpgradeStatus) {
    UPDUpgradeStatusSucceeded,
    UPDUpgradeStatusCanceled,
    UPDUpgradeStatusError
};

@interface UPDUpgradeController : NSObject

+ (BOOL)hasPurchasedUpgrade;
+ (void)purchaseUpgrade;
+ (void)setCompletionBlock:(void (^)(UPDUpgradeStatus result))completionBlock;

@end
