//
//  CoreDataModelUpdate.h
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CoreDataModelUpdateList;

@interface CoreDataModelUpdate : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSData *differenceOptions;
@property (nonatomic, retain) NSData *favicon;
@property (nonatomic, retain) NSData *instructions;
@property (nonatomic, retain) NSData *lastResponse;
@property (nonatomic, retain) NSDate *lastUpdated;
@property (nonatomic, retain) NSNumber *locked;
@property (nonatomic, retain) NSData *origResponse;
@property (nonatomic, retain) NSDate *origUpdated;
@property (nonatomic, retain) NSNumber *timerResult;
@property (nonatomic, retain) NSNumber *status;
@property (nonatomic, retain) NSData *url;
@property (nonatomic, retain) CoreDataModelUpdateList *parent;

@end
