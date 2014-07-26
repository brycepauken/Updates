//
//  UPDInternalUpdate.h
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDInternalUpdate : NSObject

@property (nonatomic, strong) UIImage *favicon;
@property (nonatomic, strong) NSDictionary *differenceOptions;
@property (nonatomic, strong) NSData *instructions;
@property (nonatomic, strong) NSData *lastReponse;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSManagedObjectID *objectID;

@end
