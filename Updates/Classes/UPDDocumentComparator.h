//
//  UPDDocumentComparator.h
//  Updates
//
//  Created by Bryce Pauken on 7/23/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPDDocumentComparator : NSObject

+ (BOOL)document:(NSString *)doc1 isEquivalentToDocument:(NSString *)doc2;
+ (BOOL)document:(NSString *)doc1 visibleTextIsEqualToDocument:(NSString *)doc2;
+ (id)document:(NSString *)doc1 compareTextWithDocument:(NSString *)doc2 highlightChanges:(BOOL)highlight;

@end
