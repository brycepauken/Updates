//
//  Instruction.h
//  Updates
//
//  Created by Bryce Pauken on 5/19/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UPDInstruction : NSManagedObject

@property (nonatomic, retain) NSNumber * instructionNumber;
@property (nonatomic, retain) NSString * baseURL;
@property (nonatomic, retain) NSString * fullURL;
@property (nonatomic, retain) NSString * anchor;
@property (nonatomic, retain) NSString * response;
@property (nonatomic, retain) NSManagedObject *parentList;
@property (nonatomic, retain) NSSet *headers;
@property (nonatomic, retain) NSSet *post;
@property (nonatomic, retain) NSSet *get;
@end

@interface UPDInstruction (CoreDataGeneratedAccessors)

- (void)addHeadersObject:(NSManagedObject *)value;
- (void)removeHeadersObject:(NSManagedObject *)value;
- (void)addHeaders:(NSSet *)values;
- (void)removeHeaders:(NSSet *)values;

- (void)addPostObject:(NSManagedObject *)value;
- (void)removePostObject:(NSManagedObject *)value;
- (void)addPost:(NSSet *)values;
- (void)removePost:(NSSet *)values;

- (void)addGetObject:(NSManagedObject *)value;
- (void)removeGetObject:(NSManagedObject *)value;
- (void)addGet:(NSSet *)values;
- (void)removeGet:(NSSet *)values;

@end
