//
//  UPDInterface.m
//  Updates
//
//  Created by Bryce Pauken on 7/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 The interface view contains a single scrollview used to move around
 the application for a paging effect. This scollview houses both
 the main table view and the web view.
 */

#import "UPDInterface.h"

#import "CoreDataModelUpdate.h"
#import "CoreDataModelUpdateList.h"
#import "NSData+UPDExtensions.h"
#import "QuartzCore/CALayer.h"
#import "UPDAppDelegate.h"
#import "UPDBrowserView.h"
#import "UPDChangesView.h"
#import "UPDInternalInstruction.h"
#import "UPDNavigationBar.h"
#import "UPDPreBrowserView.h"
#import "UPDPreProcessingView.h"
#import "UPDProcessingView.h"
#import "UPDSettingsView.h"
#import "UPDTableView.h"

@interface UPDInterface ()

@property (nonatomic, strong) UPDBrowserView *browserView;
@property (nonatomic, strong) UPDChangesView *changesView;
@property (nonatomic, strong) UPDNavigationBar *navigationBar;
@property (nonatomic, strong) UPDPreBrowserView *preBrowserView;
@property (nonatomic, strong) UPDPreProcessingView *preProcessingView;
@property (nonatomic, strong) UPDProcessingView *processingView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UPDTableView *tableView;

@end

@implementation UPDInterface

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width*3, 0)];
        [self.scrollView setScrollEnabled:NO];
        [self.scrollView setScrollsToTop:NO];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self.scrollView setTag:0];
        [self addSubview:self.scrollView];
        
        __unsafe_unretained UPDInterface *weakSelf = self;
        self.navigationBar = [[UPDNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, UPD_NAVIGATION_BAR_HEIGHT)];
        [self.navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.navigationBar setAddButtonBlock:^{
            [weakSelf.preBrowserView reset];
            [weakSelf.scrollView setTag:1];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
               [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.scrollView.bounds.size.width, 0)];
            }];
        }];
        [self.navigationBar setSettingsButtonBlock:^{
            UPDSettingsView *settingsView = [[UPDSettingsView alloc] init];
            __unsafe_unretained UPDSettingsView *weakSettingsView = settingsView;
            [settingsView setCloseButtonBlock:^{
                [weakSettingsView dismiss];
            }];
            [settingsView show];
        }];
        [self.scrollView addSubview:self.navigationBar];
        
        self.tableView = [[UPDTableView alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height-UPD_NAVIGATION_BAR_HEIGHT)];
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.tableView setUpdateSelected:^(UPDInternalUpdate *update){
            [weakSelf.changesView showUpdate:update];
            [weakSelf.tableView setUserInteractionEnabled:NO];
            [weakSelf.changesView setHidden:NO];
            [weakSelf.scrollView setTag:1];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.scrollView.bounds.size.width, 0)];
            } completion:^(BOOL finished) {
                [weakSelf.tableView setUserInteractionEnabled:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.tableView updateWasOpened:update];
                });
            }];
        }];
        [self.scrollView addSubview:self.tableView];
        
        self.preBrowserView = [[UPDPreBrowserView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        [self.preBrowserView setBackButtonBlock:^{
            [weakSelf.scrollView setTag:0];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.scrollView setContentOffset:CGPointZero];
            }];
        }];
        [self.preBrowserView setGoButtonBlock:^(NSString *url){
            [weakSelf.browserView beginSession];
            [weakSelf.browserView loadURL:url];
            [weakSelf.scrollView setTag:2];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.scrollView.bounds.size.width*2, 0)];
            }];
        }];
        
        [self.scrollView addSubview:self.preBrowserView];
        
        self.browserView = [[UPDBrowserView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.size.width*2, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        [self.browserView setTag:2]; /*what page of the scollview the browser should be on*/
        [self.browserView setCancelSessionBlock:^{
            /*move browser view over for a more seamless animation*/
            [weakSelf.browserView setTag:1];
            [weakSelf.browserView setFrame:CGRectMake(weakSelf.scrollView.bounds.size.width, 0, weakSelf.scrollView.bounds.size.width, weakSelf.scrollView.bounds.size.height)];
            [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.scrollView.bounds.size.width, 0)];
            
            [weakSelf.scrollView setTag:0];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.scrollView setContentOffset:CGPointZero];
            } completion:^(BOOL finsished) {
                [weakSelf.browserView setTag:2];
                [weakSelf.browserView setFrame:CGRectMake(weakSelf.scrollView.bounds.size.width*2, 0, weakSelf.scrollView.bounds.size.width, weakSelf.scrollView.bounds.size.height)];
            }];
        }];
        [self.browserView setConfirmBlock:^(UIImage *browserImage, NSArray *instructions, NSString *url, NSTimeInterval timerResult, NSDate *origDate) {
            [weakSelf.preProcessingView setHidden:NO];
            [weakSelf.preProcessingView beginPreProcessingWithBrowserImage:browserImage];
            [weakSelf.processingView processInstructions:instructions forURL:url withTimerResult:timerResult withOrigDate:origDate];
        }];
        [self.scrollView addSubview:self.browserView];
        
        self.preProcessingView = [[UPDPreProcessingView alloc] initWithFrame:self.bounds];
        [self.preProcessingView setHidden:YES];
        [self.preProcessingView setCompletionBlock:^{
            [weakSelf.processingView setHidden:NO];
            [weakSelf.processingView beginProcessingAnimation];
        }];
        
        [self.scrollView addSubview:self.preProcessingView];
        
        self.processingView = [[UPDProcessingView alloc] initWithFrame:self.bounds];
        [self.processingView setHidden:YES];
        [self.processingView setTag:2]; /*what page of the scollview the browser should be on*/
        [self.processingView setCompletionBlock:^(NSString *name, NSURL *url, NSArray *instructions, UIImage *favicon, NSString *lastResponse, NSDictionary *differenceOptions, NSTimeInterval timerResult, NSDate *origDate, BOOL locked) {
            void (^saveUpdate)(NSString *encryptionKey) = ^(NSString *encryptionKey){
                [weakSelf saveUpdateWithName:name url:url instructions:instructions favicon:favicon lastResponse:lastResponse differenceOptions:differenceOptions timerResult:timerResult origDate:origDate locked:locked encryptionKey:encryptionKey];
            };
            if(locked) {
                NSString *encryptedPassword = [UPDCommon getEncryptedPassword:nil];
                if(encryptedPassword.length) {
                    saveUpdate(encryptedPassword);
                }
                else {
                    /*this should never happen, since the user entered their password earlier—but we'll be safe*/
                    saveUpdate(nil);
                }
            }
            else {
                saveUpdate(nil);
            }
            
            [weakSelf.tableView reloadData];
            
            /*move browser view over for a more seamless animation*/
            [weakSelf.processingView setTag:1];
            [weakSelf.processingView setFrame:CGRectMake(weakSelf.scrollView.bounds.size.width, 0, weakSelf.scrollView.bounds.size.width, weakSelf.scrollView.bounds.size.height)];
            [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.scrollView.bounds.size.width, 0)];
            
            [weakSelf.scrollView setTag:0];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.scrollView setContentOffset:CGPointZero];
            } completion:^(BOOL finsished) {
                [weakSelf.processingView setTag:2];
                [weakSelf.processingView setFrame:CGRectMake(weakSelf.scrollView.bounds.size.width*2, 0, weakSelf.scrollView.bounds.size.width, weakSelf.scrollView.bounds.size.height)];
                
                [weakSelf.preProcessingView setHidden:YES];
                [weakSelf.processingView setHidden:YES];
            }];
        }];
        [self.scrollView addSubview:self.processingView];
        
        self.changesView = [[UPDChangesView alloc] initWithFrame:self.bounds];
        [self.changesView setHidden:YES];
        [self.changesView setBackButtonBlock:^(UPDInternalUpdate *update){
            [weakSelf.tableView updateWasOpened:update];
            [weakSelf.changesView setUserInteractionEnabled:NO];
            [weakSelf.scrollView setTag:0];
            [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
                [weakSelf.scrollView setContentOffset:CGPointZero];
            } completion:^(BOOL finished) {
                [weakSelf.changesView setHidden:YES];
                [weakSelf.changesView setUserInteractionEnabled:YES];
            }];
        }];
        [self.scrollView addSubview:self.changesView];
        
        [self setNeedsDisplay];
    }
    return self;
}

- (UPDAppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (void)layoutSubviews {
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width*3, 0)];
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*self.scrollView.tag, 0)];
    [self.preBrowserView setFrame:CGRectMake(self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    [self.browserView setFrame:CGRectMake(self.scrollView.bounds.size.width*self.browserView.tag, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    [self.preProcessingView setFrame:CGRectMake(self.scrollView.bounds.size.width*2, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    [self.processingView setFrame:CGRectMake(self.scrollView.bounds.size.width*self.browserView.tag, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    [self.changesView setFrame:CGRectMake(self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
}

- (void)saveUpdateWithName:(NSString *)name url:(NSURL *)url instructions:(NSArray *)instructions favicon:(UIImage *)favicon lastResponse:(NSString *)lastResponse differenceOptions:(NSDictionary *)differenceOptions timerResult:(NSTimeInterval)timerResult origDate:(NSDate *)origDate locked:(BOOL)locked encryptionKey:(NSString *)encryptionKey {
    NSManagedObjectContext *context = [[self appDelegate] privateObjectContext];
    
    [context performBlock:^{
        /*get existing updates list*/
        NSFetchRequest *updateListFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UpdateList"];
        NSError *updateListFetchRequestError;
        CoreDataModelUpdateList *updateList = [[context executeFetchRequest:updateListFetchRequest error:&updateListFetchRequestError] firstObject];
        if(!updateList) {
            updateList = [NSEntityDescription insertNewObjectForEntityForName:@"UpdateList" inManagedObjectContext:context];
            [updateList setUpdates:[[NSOrderedSet alloc] init]];
        }
        
        CoreDataModelUpdate *update = [NSEntityDescription insertNewObjectForEntityForName:@"Update" inManagedObjectContext:context];
        [update setName:name];
        [update setFavicon:UIImagePNGRepresentation(favicon)];
        [update setOrigUpdated:origDate];
        [update setLastUpdated:[NSDate dateWithTimeIntervalSince1970:0]];
        [update setTimerResult:@(timerResult)];
        [update setStatus:@(0)];
        [update setParent:updateList];
        [update setLocked:@(locked)];
        if(locked) {
            [update setUrl:[NSData encryptData:[NSKeyedArchiver archivedDataWithRootObject:url] withKey:encryptionKey]];
            [update setDifferenceOptions:[NSData encryptData:[NSKeyedArchiver archivedDataWithRootObject:differenceOptions] withKey:encryptionKey]];
            [update setInstructions:[NSData encryptData:[NSKeyedArchiver archivedDataWithRootObject:instructions] withKey:encryptionKey]];
            [update setOrigResponse:[NSData encryptData:[NSKeyedArchiver archivedDataWithRootObject:lastResponse] withKey:encryptionKey]];
        }
        else {
            [update setUrl:[NSKeyedArchiver archivedDataWithRootObject:url]];
            [update setDifferenceOptions:[NSKeyedArchiver archivedDataWithRootObject:differenceOptions]];
            [update setInstructions:[NSKeyedArchiver archivedDataWithRootObject:instructions]];
            [update setOrigResponse:[NSKeyedArchiver archivedDataWithRootObject:lastResponse]];
        }
        
        NSMutableOrderedSet *updates = [updateList.updates mutableCopy];
        [updates addObject:update];
        
        NSError *saveError;
        [context save:&saveError];
    }];
}

@end
