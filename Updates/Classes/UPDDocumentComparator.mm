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
#import <libxml/xmlsave.h>

#include <algorithm>
#include <numeric>
#include <string>
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
    return [[self document:doc1 compareTextWithDocument:doc2 highlightChanges:NO] boolValue];
}

/*
 Returns an NSString object representing the page with differences
 highlighted if 'highlight' is true; otherwise returns an NSNumber BOOL
 representing whether or not the pages are equal
 */
+ (id)document:(NSString *)doc1 compareTextWithDocument:(NSString *)doc2 highlightChanges:(BOOL)highlight {
    htmlDocPtr origDoc = htmlReadDoc((xmlChar *)[doc1 UTF8String], NULL, _enc, _options);;
    xmlNode *currentNode1 = (xmlNode *)origDoc;
    xmlNode *currentNode2 = (xmlNode *)htmlReadDoc((xmlChar *)[doc2 UTF8String], NULL, _enc, _options);
    
    while(currentNode1 != NULL && currentNode2 != NULL) {
        [self iterateToNextTextNode:&currentNode1];
        [self iterateToNextTextNode:&currentNode2];
        if(currentNode1 != NULL && currentNode2 != NULL) {
            if(strcmp((char *)currentNode1->content, (char *)currentNode2->content)!=0) {
                if(!highlight) {
                    return @(NO);
                }
                else {
                    std::string prevContent((const char *)currentNode1->content);
                    xmlNodeSetContent(currentNode1, (xmlChar *)"");
                    xmlNodePtr spanNode = xmlNewNode(0, (xmlChar*)"span");
                    xmlNewProp(spanNode, (xmlChar*)"style", (xmlChar*)"margin: -2px !important; padding: 2px !important; background: #f8f388 !important; border-radius: 2px !important; -moz-border-radius: 2px !important; -webkit-border-radius: 2px !important;");
                    xmlNodeAddContent(spanNode, (xmlChar*)prevContent.c_str());
                    xmlAddChild(currentNode1->parent, spanNode);
                    
                    /*add a node to the second doc, just to keep iteration the same*/
                    xmlNodePtr spanNode2 = xmlNewNode(0, (xmlChar*)"span");
                    xmlNodeSetContent(spanNode2, (xmlChar*)"");
                    xmlAddChild(currentNode2->parent, spanNode2);
                    
                    currentNode1 = currentNode1->parent;
                    currentNode2 = currentNode2->parent;
                    [self stepNode:&currentNode1 skipChildren:YES];
                    [self stepNode:&currentNode2 skipChildren:YES];
                }
            }
            [self stepNode:&currentNode1 skipChildren:NO];
            [self stepNode:&currentNode2 skipChildren:NO];
        }
    }
    if(!highlight) {
        return @(YES);
    }
    else {
        xmlBufferPtr buffer = xmlBufferCreate();
        xmlSaveCtxtPtr savePointer = xmlSaveToBuffer(buffer, "UTF-8", 0);
        xmlSaveDoc(savePointer, origDoc);
        xmlSaveFlush(savePointer);
        xmlSaveClose(savePointer);
        return [[NSString alloc] initWithCString:(const char *)buffer->content encoding:NSUTF8StringEncoding];
    }
}

/*
 Takes a given node and uses it to iterate through the document
 (check children, then sibling node, then parent's next sibling, etc.)
 until the node represents a non-empty piece of text. 'node' will be NULL
 if the document has completed.
 */
+ (void)iterateToNextTextNode:(xmlNode **)node {
    while(true) {
        if((*node)->name && strcmp((char *)(*node)->name, "text")==0) {
            bool stringIsWhiteSpace = true;
            char *s = (char *)(*node)->content;
            while(*s != '\0') {
                if(!isspace(*s)) {
                    stringIsWhiteSpace = false;
                    break;
                }
                s++;
            }
            if(!stringIsWhiteSpace) {
                break;
            }
        }
        if(![self stepNode:node skipChildren:NO]) {
            break;
        }
    }
}

/*
 Advances the iteration described in iterateToNextTextNode by one step.
 Returns NO if there is nothing left to iterate.
 */
+ (BOOL)stepNode:(xmlNode **)node skipChildren:(BOOL)skipChildren {
    if(!skipChildren && (*node)->children != NULL) {
        (*node) = (*node)->children;
        return YES;
    }
    if((*node)->next != NULL) {
        (*node) = (*node)->next;
        return YES;
    }
    while((*node)->parent != NULL && (*node)->parent->next == NULL) {
        (*node) = (*node)->parent;
    }
    if((*node)->parent != NULL && (*node)->parent->next != NULL) {
        (*node) = (*node)->parent->next;
        return YES;
    }
    (*node) = NULL;
    return NO;
}

@end
