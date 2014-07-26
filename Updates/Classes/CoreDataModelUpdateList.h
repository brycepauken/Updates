//
//  UpdateList.h
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreDataModelUpdateList : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *updates;

@end

@interface CoreDataModelUpdateList (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inUpdatesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromUpdatesAtIndex:(NSUInteger)idx;
- (void)insertUpdates:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeUpdatesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInUpdatesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceUpdatesAtIndexes:(NSIndexSet *)indexes withUpdates:(NSArray *)values;
- (void)addUpdatesObject:(NSManagedObject *)value;
- (void)removeUpdatesObject:(NSManagedObject *)value;
- (void)addUpdates:(NSOrderedSet *)values;
- (void)removeUpdates:(NSOrderedSet *)values;
@end
