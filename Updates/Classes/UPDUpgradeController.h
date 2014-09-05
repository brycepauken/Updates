//
//  UPDUpgradeController.h
//  Updates
//
//  Created by Bryce Pauken on 9/4/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDUpgradeController : NSObject

+ (BOOL)purchasedUpgrade;
+ (void)purchaseUpgradeWithCompletionBlock:(void (^)())completionBlock;

@end
