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
#import "UPDUpgradeSpinner.h"

#import <StoreKit/StoreKit.h>

@interface UPDUpgradeController() <SKRequestDelegate, SKProductsRequestDelegate>

@property (nonatomic) BOOL isRestore;
@property (nonatomic, strong) SKPayment *payment;
@property (nonatomic) id request;
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
            switch(transaction.transactionState) {
                case SKPaymentTransactionStatePurchasing:
                    [UPDUpgradeSpinner show];
                    break;
                case SKPaymentTransactionStatePurchased: case SKPaymentTransactionStateRestored:
                    [UPDUpgradeSpinner hide];
                    _completionBlock(UPDUpgradeStatusSucceeded);
                    _purchasedUpgrade = YES;
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    break;
                default:
                    [UPDUpgradeSpinner hide];
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
    [UPDUpgradeSpinner show];
    UPDUpgradeController *upgradeController = [[UPDUpgradeController alloc] init];
    [upgradeController setIsRestore:NO];
    [upgradeController setTheSelf:upgradeController];
    [upgradeController setRequest:[[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"com.kingfish.updates.unlimited"]]];
    [(SKProductsRequest *)upgradeController.request setDelegate:upgradeController];
    [upgradeController.request start];
}

- (void)requestDidFinish:(SKRequest *)request {
    if(self.isRestore) {
        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
        if(receipt) {
            NSError *error;
            NSDictionary *requestContents = @{@"receipt-data": [receipt base64EncodedStringWithOptions:0]};
            NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
            if(!requestData) {
                [UPDUpgradeSpinner hide];
                _completionBlock(UPDUpgradeStatusError);
            }
            else {
                NSURL *storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
                NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
                [storeRequest setHTTPMethod:@"POST"];
                [storeRequest setHTTPBody:requestData];
                
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if(!connectionError) {
                        NSError *error;
                        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                        if(jsonResponse) {
                            BOOL notPurchased = YES;
                            NSDictionary *receiptJSON = [jsonResponse objectForKey:@"receipt"];
                            if(receiptJSON) {
                                NSArray *inAppArray = [receiptJSON objectForKey:@"in_app"];
                                if(inAppArray) {
                                    for(NSDictionary *inApp in inAppArray) {
                                        if([inApp objectForKey:@"product_id"]) {
                                            notPurchased = NO;
                                        }
                                    }
                                }
                            }
                            if(notPurchased) {
                                [UPDUpgradeSpinner hide];
                                _completionBlock(UPDUpgradeStatusNotPurchased);
                            }
                            else {
                                [UPDUpgradeSpinner hide];
                                _completionBlock(UPDUpgradeStatusSucceededAlert);
                                _purchasedUpgrade = YES;
                            }
                        }
                        else {
                            [UPDUpgradeSpinner hide];
                            _completionBlock(UPDUpgradeStatusError);
                        }
                    }
                    else {
                        [UPDUpgradeSpinner hide];
                        _completionBlock(UPDUpgradeStatusError);
                    }
                }];
            }
        }
        else {
            [UPDUpgradeSpinner hide];
            _completionBlock(UPDUpgradeStatusError);
        }
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [UPDUpgradeSpinner hide];
    if(_completionBlock) {
        _completionBlock(UPDUpgradeStatusError);
    }
}

+ (void)restoreUpgrade {
    [UPDUpgradeSpinner show];
    UPDUpgradeController *upgradeController = [[UPDUpgradeController alloc] init];
    [upgradeController setIsRestore:YES];
    [upgradeController setTheSelf:upgradeController];
    [upgradeController setRequest:[[SKReceiptRefreshRequest alloc] init]];
    [(SKReceiptRefreshRequest *)upgradeController.request setDelegate:upgradeController];
    [upgradeController.request start];
}

+ (void)setCompletionBlock:(void (^)(UPDUpgradeStatus result))completionBlock {
    _completionBlock = completionBlock;
}

@end
