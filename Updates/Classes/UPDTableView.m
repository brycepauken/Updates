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

#import "CoreDataModelUpdate.h"
#import "CoreDataModelUpdateList.h"
#import "UPDAppDelegate.h"
#import "UPDInternalUpdate.h"
#import "UPDTableViewCell.h"

@interface UPDTableView()

@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) NSMutableArray *updates;

@end

@implementation UPDTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setDataSource:self];
        [self setDelegate:self];
        
        [self setAllowsMultipleSelectionDuringEditing:NO];
        [self setBackgroundColor:[UIColor UPDLightGreyColor]];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
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
        
        [self registerClass:[UPDTableViewCell class] forCellReuseIdentifier:@"UPDTableViewCell"];
    }
    return self;
}

- (UPDAppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

/*
 We load all updates into memory. This isn't actually as silly
 as it sounds because of the small number of updates. I hope.
 */
- (void)reloadData {
    self.updates = [[NSMutableArray alloc] init];
    NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
    NSFetchRequest *updateListFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UpdateList"];
    NSError *updateListFetchRequestError;
    CoreDataModelUpdateList *updateList = [[context executeFetchRequest:updateListFetchRequest error:&updateListFetchRequestError] firstObject];
    if(updateList) {
        for(CoreDataModelUpdate *update in updateList.updates) {
            UPDInternalUpdate *newUpdate = [[UPDInternalUpdate alloc] init];
            newUpdate.name = update.name;
            newUpdate.favicon = [[UIImage alloc] initWithData:update.favicon];
            newUpdate.lastUpdated = update.lastUpdated;
            newUpdate.instructions = [NSKeyedUnarchiver unarchiveObjectWithData:update.instructions];
            newUpdate.objectID = update.objectID;
            [self.updates insertObject:newUpdate atIndex:0];
        }
    }
    
    [super reloadData];
    BOOL tableFilled = [self numberOfRowsInSection:0]>0;
    [self setScrollEnabled:tableFilled];
    [self.startLabel setHidden:tableFilled];
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
    [cell setName:update.name];
    [cell setFavicon:update.favicon];
    [cell setLastUpdated:update.lastUpdated];
    [cell setDividerHidden:indexPath.row==0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [[self appDelegate] managedObjectContext];
        NSFetchRequest *updateListFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UpdateList"];
        NSError *updateListFetchRequestError;
        CoreDataModelUpdateList *updateList = [[context executeFetchRequest:updateListFetchRequest error:&updateListFetchRequestError] firstObject];
        if(updateList) {
            NSManagedObjectID *objectID = ((UPDInternalUpdate *)[self.updates objectAtIndex:indexPath.row]).objectID;
            NSMutableOrderedSet *updates = [updateList.updates mutableCopy];
            for(int i=0;i<(int)updates.count;i++) {
                if([((UPDInternalUpdate *)[updates objectAtIndex:i]).objectID isEqual:objectID]) {
                    [updates removeObjectAtIndex:i];
                    break;
                }
            }
            [self.updates removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            if(!self.updates.count) {
                [self setScrollEnabled:NO];
                [self.startLabel setHidden:NO];
            }
            
            [updateList setUpdates:updates];
            
            NSError *saveError;
            [context save:&saveError];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UPD_TABLEVIEW_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.updates.count;
}

@end
