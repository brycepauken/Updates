//
//  UPDAppDelegate.m
//  Updates
//
//  Created by Bryce Pauken on 7/14/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 The starting point of the application.
 Essentially just creates our UPDViewController, then handles
 a few Core Data releated functions.
 */

#import "UPDAppDelegate.h"

#import "UPDTimer.h"
#import "UPDViewController.h"

@implementation UPDAppDelegate
            
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

/*
 Creates our View Controller and gets our app going!
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UPDCommon initialize];
    
    /*preload the keyboard*/
    UITextField *field = [UITextField new];
    [[[[UIApplication sharedApplication] windows] lastObject] addSubview:field];
    [field becomeFirstResponder];
    [field resignFirstResponder];
    [field removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock:^(NSNotification* notification){
        NSManagedObjectContext *context = self.managedObjectContext;
        if(notification.object != context) {
            [context performBlock:^(){
                [context mergeChangesFromContextDidSaveNotification:notification];
            }];
        };
    }];

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_window setBackgroundColor:[UIColor blackColor]];
    
    _viewController = [[UPDViewController alloc] init];
    [_window setRootViewController:_viewController];
    
    [self.window makeKeyAndVisible];
    return YES;
}

/*
 Pause the browser's timer (if it's running)
 */
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [UPDTimer stopTimer];
}

/*
 Pause the browser's timer (if it's running)
 */
- (void)applicationWillEnterBackground:(UIApplication *)application {
    [UPDTimer pauseTimer];
}

/*
 Resume the browser's timer (if it's running)
 */
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [UPDTimer resumeTimer];
}

#pragma mark - Core Data Related Methods

/*
 Returns the app's documents directory
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/*
 Return (or create and return) the main managed object context
 */
- (NSManagedObjectContext *)managedObjectContext {
    if(_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/*
 Return (or create and return) the app-wide managed object model
 */
- (NSManagedObjectModel *)managedObjectModel {
    if(_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Updates" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/*
 Return (or create and return) the app-wide perseistent store coordinator
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if(_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Updates.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

/*
 Return (or create and return) the main managed object context
 */
- (NSManagedObjectContext *)privateObjectContext {
    if(_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/*
 Saves the app's managed object context (self.managedObjectContext) to disk
 */
- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if(managedObjectContext != nil) {
        if([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
