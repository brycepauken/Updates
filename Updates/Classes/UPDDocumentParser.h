//
//  UPDDocumentParser.h
//  Updates
//
//  Created by Bryce Pauken on 7/10/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <libxml/HTMLparser.h>

@interface UPDDocumentParser : NSObject

@property (nonatomic) htmlDocPtr document;

- (id)initWithDocumentString:(NSString *)documentString;
- (NSMutableDictionary *)findInputFields;

@end
