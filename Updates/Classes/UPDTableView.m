//
//  UPDTableView.m
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 Our custom tableview is its own datasource and delegate (this feels
 like bad practice—whoops.
 */

#import "UPDTableView.h"

#import "CoreDataModelOption.h"
#import "CoreDataModelUpdate.h"
#import "CoreDataModelUpdateList.h"
#import "NSData+UPDExtensions.h"
#import "UPDAlertView.h"
#import "UPDAppDelegate.h"
#import "UPDInstructionRunner.h"
#import "UPDInternalUpdate.h"
#import "UPDTableViewCell.h"

@interface UPDTableView()

@property (nonatomic) int currentlyRefreshing;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) NSString *refreshLabelFontSize;
@property (nonatomic, strong) NSString *refreshLabelFormat;
@property (nonatomic, strong) NSMutableArray *refreshQueue;
@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic) double timeSaved;
@property (nonatomic, strong) NSMutableArray *updates;

@end

@implementation UPDTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setDataSource:self];
        [self setDelegate:self];
        
        [self setBackgroundColor:[UIColor UPDLightGreyColor]];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.currentlyRefreshing = -1;
        
        self.startLabel = [[UILabel alloc] init];
        [self.startLabel setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.startLabel setFont:[UIFont systemFontOfSize:18]];
        [self.startLabel setHidden:YES];
        [self.startLabel setNumberOfLines:0];
        [self.startLabel setTextAlignment:NSTextAlignmentCenter];
        [self.startLabel setText:@"You don't have any\nupdates to check yet.\n\nTap the add icon\nabove to get started."];
        [self.startLabel setTextColor:[UIColor lightGrayColor]];
        CGSize startLabelSize = [self.startLabel.text boundingRectWithSize:CGSizeMake(UPD_TABLEVIEW_LABEL_WIDTH, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.startLabel.font} context:nil].size;
        startLabelSize.height = ceilf(startLabelSize.height);
        startLabelSize.width = ceilf(startLabelSize.width);
        [self.startLabel setFrame:CGRectMake((self.bounds.size.width-startLabelSize.width)/2, (self.bounds.size.height-startLabelSize.height)/2, startLabelSize.width, startLabelSize.height)];
        [self addSubview:self.startLabel];
        
        self.refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, -UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT, self.bounds.size.width, UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT)];
        [self.refreshView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:self.refreshView];
        
        self.refreshLabel = [[UILabel alloc] init];
        [self.refreshLabel setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.refreshLabel setFont:[UIFont systemFontOfSize:18]];
        [self.refreshLabel setNumberOfLines:0];
        [self.refreshLabel setTextAlignment:NSTextAlignmentCenter];
        [self.refreshLabel setTextColor:[UIColor lightGrayColor]];
        [self.refreshView addSubview:self.refreshLabel];
        [self setRefreshLabelFormat:@"You've saved %@ so far.\nPull to save more!"];
        [self updateRefreshLabel];
        
        [self registerClass:[UPDTableViewCell class] forCellReuseIdentifier:@"UPDTableViewCell"];
    }
    return self;
}

- (UPDAppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (void)beginRefresh {
    if(self.currentlyRefreshing==-1) {
        self.refreshQueue = [NSMutableArray array];
    }
    int requestPassword = 0;
    for(int i=0;i<[self numberOfRowsInSection:0];i++) {
        if(self.currentlyRefreshing==i) {
            continue;
        }
        if(![[self.updates objectAtIndex:i] locked].boolValue) {
            [self.refreshQueue addObject:@(i)];
        }
        else {
            if(requestPassword==0) {
                NSString *encryptedPassword = [UPDCommon getEncryptedPassword:^(NSString *text) {
                    if(text.length) {
                        BOOL needsRestart = NO;
                        for(int j=0;j<[self numberOfRowsInSection:0];j++) {
                            if([[self.updates objectAtIndex:j] locked].boolValue) {
                                if(self.currentlyRefreshing==-1) {
                                    self.currentlyRefreshing = j;
                                    self.refreshQueue = [NSMutableArray array];
                                    needsRestart = YES;
                                }
                                int insertionIndex = 0;
                                while(insertionIndex<self.refreshQueue.count&&((NSNumber *)[self.refreshQueue objectAtIndex:insertionIndex]).intValue<j) {
                                    insertionIndex++;
                                }
                                [self.refreshQueue insertObject:@(j) atIndex:insertionIndex];
                            }
                        }
                        if(needsRestart) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.refreshView setTag:2];
                                [self setRefreshLabelFormat:@"You've saved %@ so far."];
                                [self updateRefreshLabel];
                                [UIView animateWithDuration:UPD_TRANSITION_DURATION_FAST delay:UPD_TRANSITION_DELAY options:0 animations:^{
                                    [self setContentInset:UIEdgeInsetsMake(UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT, 0, 0, 0)];
                                } completion:nil];
                            });
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UPD_TRANSITION_DURATION*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                [self refreshRowWithFirstRequest:YES];
                            });
                        }
                    }
                }];
                requestPassword = (encryptedPassword.length?1:2);
            }
            if(requestPassword==1) {
                [self.refreshQueue addObject:@(i)];
            }
        }
    }
    if(self.refreshQueue.count) {
        self.currentlyRefreshing = ((NSNumber *)[self.refreshQueue firstObject]).intValue;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UPD_TRANSITION_DURATION*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self refreshRowWithFirstRequest:YES];
        });
    }
    else {
        self.refreshQueue = nil;
    }
}

- (void)cellSelected:(int)row {
    [self deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO];
    if(self.updateSelected) {
        self.updateSelected([self.updates objectAtIndex:row]);
    }
}

- (void)deleteRow:(int)row {
    NSManagedObjectID *objectID = ((UPDInternalUpdate *)[self.updates objectAtIndex:row]).objectID;
    [self.updates removeObjectAtIndex:row];
    [self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    if(!self.updates.count) {
        [self setScrollEnabled:NO];
        [self.startLabel setHidden:NO];
    }
    
    NSManagedObjectContext *context = [[self appDelegate] privateObjectContext];
    
    [context performBlock:^{
        NSFetchRequest *updateListFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UpdateList"];
        NSError *updateListFetchRequestError;
        CoreDataModelUpdateList *updateList = [[context executeFetchRequest:updateListFetchRequest error:&updateListFetchRequestError] firstObject];
        if(updateList) {
            NSMutableOrderedSet *updates = [updateList.updates mutableCopy];
            for(int i=0;i<(int)updates.count;i++) {
                if([((UPDInternalUpdate *)[updates objectAtIndex:i]).objectID isEqual:objectID]) {
                    [updates removeObjectAtIndex:i];
                    break;
                }
            }
            
            [updateList setUpdates:updates];
            
            NSError *saveError;
            [context save:&saveError];
        }
    }];
}

- (void)endRefresh {
    self.currentlyRefreshing = -1;
    self.refreshQueue = nil;
    [self.refreshView setTag:0];
    [self setRefreshLabelFormat:@"You've saved %@ so far.\nPull to save more!"];
    [self updateRefreshLabel];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
       [self setContentInset:UIEdgeInsetsZero]; 
    }];
}

- (void)refreshRowWithFirstRequest:(BOOL)firstRequest {
    int row = ((NSNumber *)[self.refreshQueue firstObject]).intValue;
    [self.refreshQueue removeObjectAtIndex:0];
    if(row<[self numberOfRowsInSection:0]) {
        UPDTableViewCell *cell = (UPDTableViewCell *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        if(firstRequest) {
            [cell showSpinner];
        }
        UPDInternalUpdate *update = [self.updates objectAtIndex:row];
        NSDate *startDate = [NSDate date];
        void (^completionBlock)(UPDInstructionRunnerResult result, NSString *newResponse, NSDictionary *newDifferenceOptions) = ^(UPDInstructionRunnerResult result, NSString *newResponse, NSDictionary *newDifferenceOptions) {
            [cell hideSpinnerWithContactBlock:^{
                [cell setLoadingCircleProgress:0];
                [cell setLastUpdated:[NSDate date]];
                if(result>update.status.intValue) {
                    if(result==1) {
                        [cell setCircleColor:[UIColor UPDBrightBlueColor] animate:YES];
                    }
                }
                [self saveUpdateWithObjectID:update.objectID newResponse:newResponse newDifferenceOptions:newDifferenceOptions newStatus:result updateDuration:[[NSDate date] timeIntervalSinceDate:startDate]];
                if(self.refreshQueue.count) {
                    UPDTableViewCell *nextCell = (UPDTableViewCell *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:((NSNumber *)[self.refreshQueue firstObject]).intValue inSection:0]];
                    [nextCell showSpinner];
                    [self refreshRowWithFirstRequest:firstRequest];
                }
                else {
                    [self endRefresh];
                }
            }];
        };
        void (^progressBlock)(CGFloat progress) = ^(CGFloat progress) {
            [cell setLoadingCircleProgress:progress];
        };
        if(update.locked.boolValue) {
            NSString *key = [UPDCommon getEncryptedPassword:nil];
            [UPDInstructionRunner pageFromInstructions:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData decryptData:update.instructions withKey:key]] differsFromPage:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData decryptData:update.origResponse withKey:key]] differenceOptions:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData decryptData:update.differenceOptions withKey:key]] progressBlock:progressBlock completionBlock:completionBlock];
        }
        else {
            [UPDInstructionRunner pageFromInstructions:[NSKeyedUnarchiver unarchiveObjectWithData:update.instructions] differsFromPage:[NSKeyedUnarchiver unarchiveObjectWithData:update.origResponse] differenceOptions:[NSKeyedUnarchiver unarchiveObjectWithData:update.differenceOptions] progressBlock:progressBlock completionBlock:completionBlock];
        }
    }
}

/*
 We load all updates into memory. This isn't actually as silly
 as it sounds because of the small number of updates. I hope.
 */
- (void)reloadData {
    self.updates = [[NSMutableArray alloc] init];
    NSManagedObjectContext *context = [[self appDelegate] privateObjectContext];
    
    [context performBlockAndWait:^{
        NSFetchRequest *optionTimeSavedRequest = [[NSFetchRequest alloc] initWithEntityName:@"Option"];
        [optionTimeSavedRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",@"TimeSaved"]];
        NSError *optionTimeSavedRequestError;
        CoreDataModelOption *optionTimeSaved = [[context executeFetchRequest:optionTimeSavedRequest error:&optionTimeSavedRequestError] firstObject];
        if(optionTimeSaved) {
            self.timeSaved = optionTimeSaved.doubleValue.doubleValue;
            [self updateRefreshLabel];
        }
        else {
            self.timeSaved = 0;
            [self saveUpdateWithObjectID:nil newResponse:nil newDifferenceOptions:nil newStatus:0 updateDuration:0];
        }
        
        NSFetchRequest *updateListFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UpdateList"];
        NSError *updateListFetchRequestError;
        CoreDataModelUpdateList *updateList = [[context executeFetchRequest:updateListFetchRequest error:&updateListFetchRequestError] firstObject];
        if(updateList) {
            for(CoreDataModelUpdate *update in updateList.updates) {
                UPDInternalUpdate *newUpdate = [[UPDInternalUpdate alloc] init];
                newUpdate.name = update.name;
                newUpdate.differenceOptions = update.differenceOptions;
                newUpdate.favicon = [[UIImage alloc] initWithData:update.favicon];
                newUpdate.lastResponse = update.lastResponse;
                newUpdate.lastUpdated = update.lastUpdated;
                newUpdate.origResponse = update.origResponse;
                newUpdate.origUpdated = update.origUpdated;
                newUpdate.instructions = update.instructions;
                newUpdate.status = update.status;
                newUpdate.timerResult = update.timerResult;
                newUpdate.url = update.url;
                newUpdate.locked = update.locked;
                newUpdate.objectID = update.objectID;
                [self.updates insertObject:newUpdate atIndex:0];
            }
        }
    }];
    
    [super reloadData];
    BOOL tableFilled = [self numberOfRowsInSection:0]>0;
    [self setScrollEnabled:tableFilled];
    [self.startLabel setHidden:tableFilled];
}

/*
 Updates the given object's "last updated" field, along with
 updating the total amount of time saved
 */
- (void)saveUpdateWithObjectID:(NSManagedObjectID *)objectID newResponse:(NSString *)newResponse newDifferenceOptions:(NSDictionary *)newDifferenceOptions newStatus:(int)status updateDuration:(NSTimeInterval)duration {
    NSManagedObjectContext *context = [[self appDelegate] privateObjectContext];
    
    [context performBlock:^{
        NSDate *updatedDate = [NSDate date];
        if(objectID) {
            for(UPDInternalUpdate *update in self.updates) {
                if([update.objectID isEqual:objectID]) {
                    if(status>update.status.intValue) {
                        [update setStatus:@(status)];
                    }
                    if(update.locked.boolValue) {
                        void (^passwordBlock)(NSString *pass) = ^(NSString *pass) {
                            if(newDifferenceOptions) {
                                [update setDifferenceOptions:[NSData encryptData:[NSKeyedArchiver archivedDataWithRootObject:newDifferenceOptions] withKey:pass]];
                            }
                            [update setLastResponse:[NSData encryptData:[NSKeyedArchiver archivedDataWithRootObject:newResponse] withKey:pass]];
                        };
                        NSString *encryptedPassword = [UPDCommon getEncryptedPassword:^(NSString *encryptedPass){
                            if(encryptedPass.length) {
                                passwordBlock(encryptedPass);
                            }
                        }];
                        if(encryptedPassword.length) {
                            passwordBlock(encryptedPassword);
                        }
                    }
                    else {
                        if(newDifferenceOptions) {
                            [update setDifferenceOptions:[NSKeyedArchiver archivedDataWithRootObject:newDifferenceOptions]];
                        }
                        [update setLastResponse:[NSKeyedArchiver archivedDataWithRootObject:newResponse]];
                    }
                    [update setLastUpdated:updatedDate];
                }
            }
            
            NSFetchRequest *updateListFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UpdateList"];
            NSError *updateListFetchRequestError;
            CoreDataModelUpdateList *updateList = [[context executeFetchRequest:updateListFetchRequest error:&updateListFetchRequestError] firstObject];
            if(updateList) {
                for(CoreDataModelUpdate *update in updateList.updates) {
                    if([update.objectID isEqual:objectID]) {
                        if(status>update.status.intValue) {
                            [update setStatus:@(status)];
                        }
                        if(update.locked.boolValue) {
                            void (^passwordBlock)(NSString *pass) = ^(NSString *pass){
                                if(newDifferenceOptions) {
                                    [update setDifferenceOptions:[NSData encryptData:[NSKeyedArchiver archivedDataWithRootObject:newDifferenceOptions] withKey:pass]];
                                }
                                [update setLastResponse:[NSData encryptData:[NSKeyedArchiver archivedDataWithRootObject:newResponse] withKey:pass]];
                            };
                            NSString *encryptedPassword = [UPDCommon getEncryptedPassword:^(NSString *encryptedPass){
                                if(encryptedPass.length) {
                                    passwordBlock(encryptedPass);
                                }
                            }];
                            if(encryptedPassword.length) {
                                passwordBlock(encryptedPassword);
                            }
                        }
                        else {
                            if(newDifferenceOptions) {
                                [update setDifferenceOptions:[NSKeyedArchiver archivedDataWithRootObject:newDifferenceOptions]];
                            }
                            [update setLastResponse:[NSKeyedArchiver archivedDataWithRootObject:newResponse]];
                        }
                        [update setLastUpdated:updatedDate];
                        CGFloat timeJustSaved = update.timerResult.doubleValue - duration;
                        self.timeSaved += timeJustSaved>0?timeJustSaved:0;
                    }
                }
            }
        }
        
        NSFetchRequest *optionTimeSavedRequest = [[NSFetchRequest alloc] initWithEntityName:@"Option"];
        [optionTimeSavedRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",@"TimeSaved"]];
        NSError *optionTimeSavedRequestError;
        CoreDataModelOption *optionTimeSaved = [[context executeFetchRequest:optionTimeSavedRequest error:&optionTimeSavedRequestError] firstObject];
        if(optionTimeSaved) {
            [optionTimeSaved setDoubleValue:@(self.timeSaved)];
        }
        else {
            optionTimeSaved = [NSEntityDescription insertNewObjectForEntityForName:@"Option" inManagedObjectContext:context];
            [optionTimeSaved setName:@"TimeSaved"];
            [optionTimeSaved setDoubleValue:@(0)];
        }
        
        NSError *saveError;
        [context save:&saveError];
        [self updateRefreshLabel];
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(scrollView.contentOffset.y<=-UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT && self.refreshView.tag<2) {
        [self.refreshView setTag:2];
        [self setRefreshLabelFormat:@"You've saved %@ so far."];
        [self updateRefreshLabel];
        [self beginRefresh];
        [UIView animateWithDuration:UPD_TRANSITION_DURATION_FAST delay:UPD_TRANSITION_DELAY options:0 animations:^{
            [self setContentInset:UIEdgeInsetsMake(UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT, 0, 0, 0)];
        } completion:nil];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.refreshView.tag==2) {
        if(scrollView.contentOffset.y > 0) {
            [scrollView setContentInset:UIEdgeInsetsZero];
        }
        else if(scrollView.contentOffset.y>=-UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT) {
            [scrollView setContentInset:UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)];
        }
    }
    else {
        if(scrollView.contentOffset.y<=-UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT && self.refreshView.tag==0) {
            [self.refreshView setTag:1];
            [self setRefreshLabelFormat:@"You've saved %@ so far.\nRelease to save more!"];
            [self updateRefreshLabel];
        }
        else if(scrollView.contentOffset.y>-UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT && self.refreshView.tag==1) {
            [self.refreshView setTag:0];
            [self setRefreshLabelFormat:@"You've saved %@ so far.\nPull to save more!"];
            [self updateRefreshLabel];
        }
    }
}

- (void)updateRefreshLabel {
    NSString *timeText;
    int timeSaved = (int)floor(self.timeSaved);
    if(timeSaved<=0) {
        timeText = [NSString stringWithFormat:@"0 seconds"];
    }
    else if(timeSaved<60) {
        timeText = [NSString stringWithFormat:@"%i second%@",timeSaved,timeSaved==1?@"":@"s"];
    }
    else if(timeSaved<60*60) {
        timeSaved/=60;
        timeText = [NSString stringWithFormat:@"%i minute%@",timeSaved,timeSaved==1?@"":@"s"];
    }
    else if(timeSaved<60*60*24) {
        timeSaved/=(60*60);
        timeText = [NSString stringWithFormat:@"%i hour%@",timeSaved,timeSaved==1?@"":@"s"];
    }
    else if(timeSaved<60*60*24*31) {
        timeSaved/=(60*60*24);
        timeText = [NSString stringWithFormat:@"%i day%@",timeSaved,timeSaved==1?@"":@"s"];
    }
    else if(timeSaved<60*60*24*31*365) {
        timeSaved/=(60*60*24*31);
        timeText = [NSString stringWithFormat:@"%i month%@",timeSaved,timeSaved==1?@"":@"s"];
    }
    else {
        timeSaved/=(60*60*24*31*365);
        timeText = [NSString stringWithFormat:@"%i year%@",timeSaved,timeSaved==1?@"":@"s"];
    }
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:self.refreshLabelFormat,timeText]];
    NSUInteger timeTextLocation = [self.refreshLabelFormat rangeOfString:@"%@"].location;
    [newText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, timeTextLocation)];
    [newText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(timeTextLocation, timeText.length)];
    [newText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(timeTextLocation+timeText.length, self.refreshLabelFormat.length-2-timeTextLocation)];
    [self.refreshLabel setAttributedText:newText];
    [self.refreshLabel setFrame:self.refreshView.bounds];
}

- (void)updateWasOpened:(UPDInternalUpdate *)openedUpdate {
    NSManagedObjectContext *context = [[self appDelegate] privateObjectContext];
    
    if(openedUpdate.lastResponse) {
        int updateIndex = 0;
        for(UPDInternalUpdate *update in self.updates) {
            if([update.objectID isEqual:openedUpdate.objectID]) {
                if(!update.lastResponse) {
                    /*this method could've been called twice (and often is). no need to do anything*/
                    return;
                }
                [update setStatus:@(0)];
                [update setOrigResponse:update.lastResponse];
                [update setOrigUpdated:update.lastUpdated];
                [update setLastResponse:nil];
                [update setLastUpdated:[NSDate dateWithTimeIntervalSince1970:0]];
                [(UPDTableViewCell *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:updateIndex inSection:0]] setCircleColor:nil animate:NO];
            }
            updateIndex++;
        }
        
        [context performBlock:^{
            NSFetchRequest *updateListFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UpdateList"];
            NSError *updateListFetchRequestError;
            CoreDataModelUpdateList *updateList = [[context executeFetchRequest:updateListFetchRequest error:&updateListFetchRequestError] firstObject];
            if(updateList) {
                for(CoreDataModelUpdate *update in updateList.updates) {
                    if([update.objectID isEqual:openedUpdate.objectID]) {
                        [update setStatus:@(0)];
                        [update setOrigResponse:update.lastResponse];
                        [update setOrigUpdated:update.lastUpdated];
                        [update setLastResponse:nil];
                    }
                }
            }
            
            NSError *saveError;
            [context save:&saveError];
            [self updateRefreshLabel];
        }];
    }
}

#pragma mark - Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UPDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UPDTableViewCell"];
    if(!cell) {
        cell = [[UPDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UPDTableViewCell"];
    }
    UPDInternalUpdate *update = [self.updates objectAtIndex:indexPath.row];
    switch(update.status.intValue) {
        case 1:
            [cell setCircleColor:[UIColor UPDBrightBlueColor] animate:NO];
            break;
        default:
            [cell setCircleColor:nil animate:NO];
            break;
    }
    [cell setName:update.name];
    [cell setFavicon:update.favicon];
    [cell setLastUpdated:update.lastUpdated];
    [cell setLockIconHidden:!update.locked.boolValue];
    [cell setDividerHidden:indexPath.row==0];
    
    __unsafe_unretained UPDTableView *weakSelf = self;
    [cell setCellTapped:^{
        [weakSelf cellSelected:(int)indexPath.row];
    }];
    [cell setDeleteCell:^{
        UPDAlertView *alertView = [[UPDAlertView alloc] init];
        __unsafe_unretained UPDAlertView *weakAlertView = alertView;
        [alertView setTitle:@"Delete"];
        [alertView setMessage:@"Are you sure you want to delete this update? You won't be able to recover it later."];
        [alertView setNoButtonBlock:^{
            [weakAlertView dismiss];
        }];
        [alertView setYesButtonBlock:^{
            [weakAlertView dismiss];
            [weakSelf deleteRow:(int)indexPath.row];
        }];
        [alertView show];
    }];
    [cell setRequestRefresh:^{
        if(self.currentlyRefreshing>-1) {
            [self.refreshQueue insertObject:@((int)indexPath.row) atIndex:0];
        }
        else {
            self.currentlyRefreshing = (int)indexPath.row;
            self.refreshQueue = [NSMutableArray array];
            [self.refreshQueue insertObject:@((int)indexPath.row) atIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshView setTag:2];
                [self setRefreshLabelFormat:@"You've saved %@ so far."];
                [self updateRefreshLabel];
                [UIView animateWithDuration:UPD_TRANSITION_DURATION_FAST delay:UPD_TRANSITION_DELAY options:0 animations:^{
                    [self setContentInset:UIEdgeInsetsMake(UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT, 0, 0, 0)];
                } completion:nil];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UPD_TRANSITION_DURATION*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self refreshRowWithFirstRequest:YES];
            });
        }
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UPD_TABLEVIEW_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.updates.count;
}

@end
