//
//  UPDDocumentSearcher.m
//  Updates
//
//  Created by Bryce Pauken on 7/30/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDDocumentSearcher.h"

#import <libxml/HTMLparser.h>

@implementation UPDDocumentSearcher

static const char *_enc;
static int _options;

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

#pragma mark - New Input Searcher

/*
 Given an array containing name/value pairs for an input field
 (i.e., @[@"viewState",@"123456789"]) and the original response,
 this method returns an array containing the new name/value pairs
 that should be sent with a new request.
 */
+ (NSArray *)document:(NSString *)doc equivilantInputFieldForArray:(NSArray *)input orignalResponse:(NSString *)origDoc {
    xmlNode *currentNode = (xmlNode *)htmlReadDoc((xmlChar *)[[doc stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"] UTF8String], NULL, _enc, _options);
    xmlNode *origCurrentNode = (xmlNode *)htmlReadDoc((xmlChar *)[[origDoc stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"] UTF8String], NULL, _enc, _options);
    
    NSMutableArray *mutableInput = [input mutableCopy];
    NSMutableArray *returnInput = [input mutableCopy];
    for(int i=0;i<returnInput.count;i++) {
        [returnInput replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithObjects:[[[returnInput objectAtIndex:i] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"],[[[returnInput objectAtIndex:i] objectAtIndex:1] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"],nil]];
    }
    
    while(currentNode != NULL && origCurrentNode != NULL) {
        [self iterateToNextTextNode:&currentNode];
        [self iterateToNextTextNode:&origCurrentNode];
        
        if(currentNode != NULL && origCurrentNode != NULL) {
            NSString *origName = [NSString stringWithUTF8String:(const char*)xmlGetProp(origCurrentNode, (xmlChar *)"name")];
            NSString *origValue = [NSString stringWithUTF8String:(const char*)xmlGetProp(origCurrentNode, (xmlChar *)"value")];
            for(int i=0;i<mutableInput.count;i++) {
                if(![[mutableInput objectAtIndex:i] isEqual:[NSNull null]]) {
                    if([[[mutableInput objectAtIndex:i] objectAtIndex:0] isEqualToString:origName] && [[[mutableInput objectAtIndex:i] objectAtIndex:1] isEqualToString:origValue]) {
                        [returnInput replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithObjects:[NSString stringWithUTF8String:(const char*)xmlGetProp(currentNode, (xmlChar *)"name")],[NSString stringWithUTF8String:(const char*)xmlGetProp(currentNode, (xmlChar *)"value")],nil]];
                        [mutableInput replaceObjectAtIndex:i withObject:[NSNull null]];
                    }
                }
            }
            
            [self stepNode:&currentNode];
            [self stepNode:&origCurrentNode];
        }
    }
    
    for(int i=0;i<returnInput.count;i++) {
        [returnInput replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithObjects:[[[returnInput objectAtIndex:i] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"],[[[returnInput objectAtIndex:i] objectAtIndex:1] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"],nil]];
    }
    return returnInput;
    
    return nil;
}

/*
 Takes a given node and uses it to iterate through the document
 (check children, then sibling node, then parent's next sibling, etc.)
 until the node represents an input field with a name/value. 'node' will
 be NULL if the document has iterated completely.
 */
+ (void)iterateToNextTextNode:(xmlNode **)node {
    while(true) {
        if((*node)->name && strcmp((char *)(*node)->name, "input")==0) {
            const char *name = (const char*)xmlGetProp((*node), (xmlChar *)"name");
            const char *value = (const char*)xmlGetProp((*node), (xmlChar *)"value");
            if(name && name[0]!='\0' && value && value[0]!='\0' ) {
                break;
            }
        }
        if(![self stepNode:node]) {
            break;
        }
    }
}

/*
 Advances the iteration described in iterateToNextTextNode by one step.
 Returns NO if there is nothing left to iterate.
 */
+ (BOOL)stepNode:(xmlNode **)node {
    if((*node)->children != NULL) {
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
