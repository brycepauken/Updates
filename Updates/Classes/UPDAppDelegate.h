//
//  UPDAppDelegate.h
//  Updates
//
//  Created by Bryce Pauken on 7/14/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class UPDViewController;

@interface UPDAppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, nonatomic, strong) UPDViewController *viewController;
@property (nonatomic, strong) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

@end

