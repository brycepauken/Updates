//
//  UPDDocumentComparator.m
//  Updates
//
//  Created by Bryce Pauken on 7/23/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 This class is used by the instruction processor to check if one
 web document is equivilant to another—e.g., to check if the web page
 recieved after repeating a series of instructions is the same as the
 original (rather than, say, a login page, indicating the instructions
 did not work).
 */

#import "UPDDocumentComparator.h"

#import <libxml/HTMLparser.h>

#include <algorithm>
#include <numeric>
#include <vector>

@implementation UPDDocumentComparator

static const char *_enc;
static int _options;

struct ElementCount {
    const char* name;
    int count;
};

+ (void)initialize {
    /*set options used by libxml*/
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        CFStringEncoding CFEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        CFStringRef CGEncodingSring = CFStringConvertEncodingToIANACharSetName(CFEncoding);
        _enc = CFStringGetCStringPtr(CGEncodingSring, 0);
        
        _options = HTML_PARSE_RECOVER|HTML_PARSE_NOERROR|HTML_PARSE_NOWARNING;
    });
}

#pragma mark - Equivilant

/*
 Analyzes the structure of each document, and returns YES if the two should
 be considered the same (specifically, if the cosine similarity between the two
 is greater than 0.8, and the number of nodes varies by less than 20%).
 */
+ (BOOL)document:(NSString *)doc1 isEquivalentToDocument:(NSString *)doc2 {
    std::vector<ElementCount>htmlElementCountsDoc1;
    [self addElementsFromNode:(xmlNode *)htmlReadDoc((xmlChar *)[doc1 UTF8String], NULL, _enc, _options) toCountVector:&htmlElementCountsDoc1 previousCountVector:NULL];
    std::vector<ElementCount>htmlElementCountsDoc2 = htmlElementCountsDoc1;
    for(auto it = htmlElementCountsDoc2.begin(); it != htmlElementCountsDoc2.end(); ++it) {
        (*it).count = 0;
    }
    [self addElementsFromNode:(xmlNode *)htmlReadDoc((xmlChar *)[doc2 UTF8String], NULL, _enc, _options) toCountVector:&htmlElementCountsDoc2 previousCountVector:&htmlElementCountsDoc1];
    
    double dotProduct;
    auto dotProductIt1 = htmlElementCountsDoc1.begin();
    auto dotProductIt2 = htmlElementCountsDoc2.begin();
    while(dotProductIt1!=htmlElementCountsDoc1.end()) {
        dotProduct += ((*dotProductIt1).count)*((*dotProductIt2).count);
        dotProductIt1++;
        dotProductIt2++;
    }
    double magnitude1 = 0;
    int sum1 = 0;
    for(auto it = htmlElementCountsDoc1.begin(); it != htmlElementCountsDoc1.end(); ++it) {
        magnitude1 += ((*it).count)*((*it).count);
        sum1 += (*it).count;
    }
    magnitude1 = sqrt(magnitude1);
    double magnitude2 = 0;
    int sum2 = 0;
    for(auto it = htmlElementCountsDoc2.begin(); it != htmlElementCountsDoc2.end(); ++it) {
        magnitude2 += ((*it).count)*((*it).count);
        sum2 += (*it).count;
    }
    magnitude2 = sqrt(magnitude2);
    double cosSimilarity = dotProduct/(magnitude1*magnitude2);
    sum1 += 50;
    sum2 += 50;
    return (cosSimilarity>=0.8 && sum2>sum1*0.8 && sum2<sum1*1.2);
}

/*
 Iterates through the document and adds elements to the count vector
 if they aren't already present, incrementing the count otherwise.
 If a previous count vector is provided, elements found that are missing from
 that count are added in with a count of '0'.
 */
+ (void)addElementsFromNode:(xmlNode *)startNode toCountVector:(std::vector<ElementCount> *)htmlElementCounts previousCountVector:(std::vector<ElementCount> *)prevHtmlElementCounts {
    for(xmlNode *node = startNode; node!=NULL; node=node->next) {
        if(node->name && strcmp((char *)node->name, "text")!=0) {
            struct elementCountComparison {
                elementCountComparison(char * compareTo) : compareTo(compareTo) {}
                bool operator()(ElementCount el) const {return  strcmp(el.name, compareTo)==0;}
            private:
                char * compareTo;
            };
            auto existingStruct = std::find_if((*htmlElementCounts).begin(), (*htmlElementCounts).end(),elementCountComparison((char *)node->name));
            if(existingStruct != std::end(*htmlElementCounts)) {
                (*existingStruct).count++;
                if(prevHtmlElementCounts == NULL) {
                    while(existingStruct != std::begin(*htmlElementCounts) && (*existingStruct).count>(*(existingStruct-1)).count) {
                        iter_swap(existingStruct, existingStruct-1);
                        existingStruct--;
                    }
                }
            }
            else {
                ElementCount newElement = {.name = (char *)node->name, .count = 1};
                (*htmlElementCounts).push_back(newElement);
                if(prevHtmlElementCounts != NULL) {
                    ElementCount newElementPrev = {.name = (char *)node->name, .count = 0};
                    (*prevHtmlElementCounts).push_back(newElementPrev);
                }
            }
        }
        [self addElementsFromNode:node->children toCountVector:htmlElementCounts previousCountVector:prevHtmlElementCounts];
    }
}

#pragma mark - Visible Text Equal

+ (BOOL)document:(NSString *)doc1 visibleTextIsEqualToDocument:(NSString *)doc2 {
    return [self document:doc1 visibleTextIsEqualToDocument:doc2 highlightChanges:NO];
}

+ (BOOL)document:(NSString *)doc1 visibleTextIsEqualToDocument:(NSString *)doc2 highlightChanges:(BOOL)highlight {
    htmlDocPtr origDoc = htmlReadDoc((xmlChar *)[doc1 UTF8String], NULL, _enc, _options);;
    xmlNode *currentNode1 = (xmlNode *)origDoc;
    xmlNode *currentNode2 = (xmlNode *)htmlReadDoc((xmlChar *)[doc2 UTF8String], NULL, _enc, _options);
    
    while(true) {
        if(currentNode1->name && strcmp((char *)currentNode1->name, "text")==0) {
            bool stringIsWhiteSpace = true;
            char *s = (char *)currentNode1->content;
            while(*s != '\0') {
                if(!isspace(*s)) {
                    stringIsWhiteSpace = false;
                    break;
                }
                s++;
            }
            if(!stringIsWhiteSpace) {
                while(true) {
                    BOOL breakNotContinue = false;
                    if(currentNode2->name && strcmp((char *)currentNode2->name, "text")==0) {
                        bool stringIsWhiteSpace2 = true;
                        char *s2 = (char *)currentNode2->content;
                        while(*s2 != '\0') {
                            if(!isspace(*s2)) {
                                stringIsWhiteSpace2 = false;
                                break;
                            }
                            s2++;
                        }
                        if(!stringIsWhiteSpace2) {
                            if(strcmp((char *)currentNode1->content, (char *)currentNode2->content)!=0) {
                                if(highlight) {
                                    xmlNodeSetContent(currentNode1, (xmlChar *)"hello world");
                                }
                                else {
                                    return NO;
                                }
                            }
                            breakNotContinue = true;
                        }
                    }
                    
                    if(currentNode2->children != NULL) {
                        currentNode2 = currentNode2->children;
                        if(breakNotContinue) {
                            break;
                        }
                        else {
                            continue;
                        }
                    }
                    if(currentNode2->next != NULL) {
                        currentNode2 = currentNode2->next;
                        if(breakNotContinue) {
                            break;
                        }
                        else {
                            continue;
                        }
                    }
                    while(currentNode2->parent != NULL && currentNode2->parent->next == NULL) {
                        currentNode2 = currentNode2->parent;
                    }
                    if(currentNode2->parent != NULL && currentNode2->parent->next != NULL) {
                        currentNode2 = currentNode2->parent->next;
                        if(breakNotContinue) {
                            break;
                        }
                        else {
                            continue;
                        }
                    }
                    break;
                }
            }
        }
        
        if(currentNode1->children != NULL) {
            currentNode1 = currentNode1->children;
            continue;
        }
        if(currentNode1->next != NULL) {
            currentNode1 = currentNode1->next;
            continue;
        }
        while(currentNode1->parent != NULL && currentNode1->parent->next == NULL) {
            currentNode1 = currentNode1->parent;
        }
        if(currentNode1->parent != NULL && currentNode1->parent->next != NULL) {
            currentNode1 = currentNode1->parent->next;
            continue;
        }
        break;
    }
    
    if(highlight) {
        xmlSaveFileEnc("-", origDoc, "UTF-8");
        
    }
    
    return YES;
}

@end
