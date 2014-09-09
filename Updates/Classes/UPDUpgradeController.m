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

@property (nonatomic, strong) SKPayment *payment;
@property (nonatomic, strong) SKProductsRequest *request;
@property (nonatomic, strong) UPDUpgradeController *theSelf;

@end

@implementation UPDUpgradeController

static void (^_completionBlock)(UPDUpgradeStatus result);
static BOOL _purchasedUpgrade;

+ (void)initialize {
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        [[SKPaymentQueue defaultQueue] addTransactionObserver:(id<SKPaymentTransactionObserver>)self];
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

+ (BOOL)hasPurchasedUpgrade {
    return _purchasedUpgrade;
}

+ (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    if(_completionBlock) {
        for(SKPaymentTransaction *transaction in transactions) {
            switch (transaction.transactionState) {
                case SKPaymentTransactionStatePurchased: case SKPaymentTransactionStateRestored:
                    _completionBlock(UPDUpgradeStatusSucceeded);
                    _purchasedUpgrade = YES;
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    break;
                default:
                    _completionBlock(UPDUpgradeStatusCanceled);
                    break;
            }
        }
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    SKProduct *upgrade = [response.products firstObject];
    if(!upgrade||![upgrade.productIdentifier isEqualToString:@"com.kingfish.updates.unlimited"]) {
        [self request:request didFailWithError:nil];
    }
    else {
        SKPayment *payment = [SKPayment paymentWithProduct:upgrade];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

+ (void)purchaseUpgrade {
    UPDUpgradeController *upgradeController = [[UPDUpgradeController alloc] init];
    [upgradeController setRequest:[[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"com.kingfish.updates.unlimited"]]];
    [upgradeController.request setDelegate:upgradeController];
    [upgradeController.request start];
    [upgradeController setTheSelf:upgradeController];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if(_completionBlock) {
        _completionBlock(UPDUpgradeStatusError);
    }
}

+ (void)setCompletionBlock:(void (^)(UPDUpgradeStatus result))completionBlock {
    _completionBlock = completionBlock;
}

@end
