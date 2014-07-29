//
//  Option.h
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreDataModelOption : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *boolValue;
@property (nonatomic, retain) NSNumber *doubleValue;
@property (nonatomic, retain) NSNumber *intValue;

@end
