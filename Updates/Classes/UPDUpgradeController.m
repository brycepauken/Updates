//
//  UPDUpgradeController.m
//  Updates
//
//  Created by Bryce Pauken on 9/4/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDUpgradeController.h"

#import "CoreDataModelOption.h"
#import "UPDAppDelegate.h"

#import <StoreKit/StoreKit.h>

@interface UPDUpgradeController() <SKProductsRequestDelegate>

@property (nonatomic, copy) void (^completionBlock)();
@property (nonatomic, strong) SKPayment *payment;
@property (nonatomic, strong) SKProductsRequest *request;
@property (nonatomic, strong) UPDUpgradeController *theSelf;

@end

@implementation UPDUpgradeController

static BOOL _purchasedUpgrade;

+ (void)initialize {
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        __block BOOL returnValue = NO;
        NSManagedObjectContext *context = [((UPDAppDelegate *)[[UIApplication sharedApplication] delegate]) privateObjectContext];
        [context performBlockAndWait:^{
            NSFetchRequest *optionPurchasedUpgradeRequest = [[NSFetchRequest alloc] initWithEntityName:@"Option"];
            [optionPurchasedUpgradeRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",@"PurchasedUpgrade"]];
            NSError *optionPurchasedUpgradeError;
            CoreDataModelOption *optionPurchasedUpgrade = [[context executeFetchRequest:optionPurchasedUpgradeRequest error:&optionPurchasedUpgradeError] firstObject];
            
            if(optionPurchasedUpgrade&&optionPurchasedUpgrade.boolValue.boolValue==YES) {
                returnValue = YES;
            }
        }];
        _purchasedUpgrade = returnValue;
    });
}

- (instancetype)initWithCompletionBlock:(void (^)())completionBlock {
    self = [super init];
    if(self) {
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"yay: a: %@ b: %@",response.products,response.invalidProductIdentifiers);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"nay");
}

+ (BOOL)purchasedUpgrade {
    return _purchasedUpgrade;
}

+ (void)purchaseUpgradeWithCompletionBlock:(void (^)())completionBlock {
    UPDUpgradeController *upgradeController = [[UPDUpgradeController alloc] initWithCompletionBlock:completionBlock];
    [upgradeController setRequest:[[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"com.kingfish.updates.unlimited"]]];
    [upgradeController.request setDelegate:upgradeController];
    [upgradeController.request start];
    [upgradeController setTheSelf:upgradeController];
}

@end
