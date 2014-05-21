//
//  InstructionList.h
//  Updates
//
//  Created by Bryce Pauken on 5/19/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UPDInstruction;

@interface UPDInstructionList : NSManagedObject

@property (nonatomic, retain) NSSet *instructions;
@end

@interface UPDInstructionList (CoreDataGeneratedAccessors)

- (void)addInstructionsObject:(UPDInstruction *)value;
- (void)removeInstructionsObject:(UPDInstruction *)value;
- (void)addInstructions:(NSSet *)values;
- (void)removeInstructions:(NSSet *)values;

@end
