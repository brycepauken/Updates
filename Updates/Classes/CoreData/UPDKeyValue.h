//
//  KeyValue.h
//  Updates
//
//  Created by Bryce Pauken on 5/19/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UPDInstruction;

@interface UPDKeyValue : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) UPDInstruction *headersParent;
@property (nonatomic, retain) UPDInstruction *postParent;
@property (nonatomic, retain) UPDInstruction *getParent;

@end
