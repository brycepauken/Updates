//
//  UPDTableViewContoller.m
//  Update
//
//  Created by Bryce Pauken on 5/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDTableViewContoller.h"

@interface UPDTableViewContoller ()

@end

@implementation UPDTableViewContoller

- (id)initWithAddBlock:(void (^)())addBlock {
    self = [super init];
    if (self) {
        self.addBlock = addBlock;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"InstructionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    [cell.textLabel setText:@"Create New"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row==0&&self.addBlock) {
        self.addBlock();
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSManagedObjectContext *context = [AppDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityForFetch = [NSEntityDescription entityForName:@"InstructionList" inManagedObjectContext:context];
    [fetchRequest setEntity:entityForFetch];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    return [fetchedObjects count]+1;
}

@end
