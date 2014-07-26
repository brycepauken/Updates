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

@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) NSString *refreshLabelFontSize;
@property (nonatomic, strong) NSString *refreshLabelFormat;
@property (nonatomic, strong) UIView *refreshView;
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
        [self setRefreshLabelFormat:@"You've saved %@ so far\nPull to save more!"];
        [self updateRefreshLabel];
        
        [self registerClass:[UPDTableViewCell class] forCellReuseIdentifier:@"UPDTableViewCell"];
    }
    return self;
}

- (UPDAppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (void)beginRefresh {
    
}

- (void)endRefresh {
    [self.refreshView setTag:0];
    [self setRefreshLabelFormat:@"You've saved %@ so far\nPull to save more!"];
    [self updateRefreshLabel];
    [UIView animateWithDuration:UPD_TRANSITION_DURATION animations:^{
       [self setContentInset:UIEdgeInsetsZero]; 
    }];
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
            newUpdate.differenceOptions = [NSKeyedUnarchiver unarchiveObjectWithData:update.differenceOptions];
            newUpdate.favicon = [[UIImage alloc] initWithData:update.favicon];
            newUpdate.lastReponse = update.lastResponse;
            newUpdate.lastUpdated = update.lastUpdated;
            newUpdate.instructions = update.instructions;
            newUpdate.objectID = update.objectID;
            [self.updates insertObject:newUpdate atIndex:0];
        }
    }
    
    [super reloadData];
    BOOL tableFilled = [self numberOfRowsInSection:0]>0;
    [self setScrollEnabled:tableFilled];
    [self.startLabel setHidden:tableFilled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(scrollView.contentOffset.y<=-UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT && self.refreshView.tag<2) {
        [self.refreshView setTag:2];
        [self setRefreshLabelFormat:@"You've saved %@ so far"];
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
            [self setRefreshLabelFormat:@"You've saved %@ so far\nRelease to save more!"];
            [self updateRefreshLabel];
        }
        else if(scrollView.contentOffset.y>-UPD_TABLEVIEW_REFRESH_VIEW_HEIGHT && self.refreshView.tag==1) {
            [self.refreshView setTag:0];
            [self setRefreshLabelFormat:@"You've saved %@ so far\nPull to save more!"];
            [self updateRefreshLabel];
        }
    }
}

- (void)updateRefreshLabel {
    NSString *timeText = @"0 seconds";
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:self.refreshLabelFormat,timeText]];
    NSUInteger timeTextLocation = [self.refreshLabelFormat rangeOfString:@"%@"].location;
    [newText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, timeTextLocation)];
    [newText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(timeTextLocation, timeText.length)];
    [newText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(timeTextLocation+timeText.length, self.refreshLabelFormat.length-(timeTextLocation+timeText.length))];
    [self.refreshLabel setAttributedText:newText];
    [self.refreshLabel sizeToFit];
    [self.refreshLabel setFrame:CGRectMake((self.refreshView.bounds.size.width-self.refreshLabel.bounds.size.width)/2, (self.refreshView.bounds.size.height-self.refreshLabel.bounds.size.height)/2, self.refreshLabel.bounds.size.width, self.refreshLabel.bounds.size.height)];
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
