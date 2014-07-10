//
//  UPDAppDelegate.h
//  Update
//
//  Created by Bryce Pauken on 5/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UPDViewController.h"

@interface UPDAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, copy) void(^addInstruction)(NSString *url, NSString *post, NSString *response, NSDictionary *headers, NSString *redirectURL);

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *temporaryObjectContext;
@property (nonatomic, retain) UPDViewController *viewController;
@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;
- (void)resetTemporaryObjectContext;
- (void)saveContext;

@end
