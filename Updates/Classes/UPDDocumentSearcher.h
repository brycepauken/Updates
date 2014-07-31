//
//  UPDDocumentSearcher.h
//  Updates
//
//  Created by Bryce Pauken on 7/30/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDDocumentSearcher : NSObject

+ (NSArray *)document:(NSString *)doc equivilantInputFieldForArray:(NSArray *)input orignalResponse:(NSString *)origDoc;

@end
