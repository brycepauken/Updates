//
//  UPDInstructionProcessor.m
//  Updates
//
//  Created by Bryce Pauken on 7/22/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 This object goes through a list of UPDInternalInstruction's and
 attempts to recreate the actions given by those instructions, making
 optimizations if possible.
 
 The general steps involed in this process are:
 1) Figure out where a request URL came from
    a) First URL is given, no need for processing
    b) If exact URL shows up on previous reponse page, use that one in the future
    c) If exact URL doesn't show up, check if base url shows up as GET form action, and use that
 2) Figure out where parameters came from (GET and POST)
    a) Check input forms in prevoius response page for data—use field in the future if possible
 3) Try the entire instruction list again, checking if end page is the same or equivalent
 
 */

#import "UPDInstructionProcessor.h"

#import <libxml/HTMLparser.h>
#import "UPDInternalInstruction.h"

@implementation UPDInstructionProcessor

static const char *_enc;
static int _options;

- (void)beginProcessing {
    static dispatch_once_t dispatchOnceToken;
    dispatch_once(&dispatchOnceToken, ^{
        CFStringEncoding CFEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        CFStringRef CGEncodingSring = CFStringConvertEncodingToIANACharSetName(CFEncoding);
        _enc = CFStringGetCStringPtr(CGEncodingSring, 0);
        
        _options = HTML_PARSE_RECOVER|HTML_PARSE_NOERROR|HTML_PARSE_NOWARNING;
    });
    
    NSMutableArray *workingInstructions = [self.instructions mutableCopy];
    
    UPDInternalInstruction *previousInstruction;
    for(UPDInternalInstruction *instruction in workingInstructions) {
        if(previousInstruction) {
            /*look for anything pointing to (NSString *)instruction.fullURL*/
            [self findLinkForURL:instruction.fullURL inDocument:previousInstruction.response];
        }
        previousInstruction = instruction;
    }
}

/*
 Begin searching for the given link in the given document.
 See -findLinkForURL:fromNode: below.
 */
- (void)findLinkForURL:(NSString *)url inDocument:(NSString *)document {
    if([url isEqualToString:@"http://www.bcp.org/news/index.aspx"])
    [self findLinkForURL:url fromNode:(xmlNode *)htmlReadDoc((xmlChar *)[document UTF8String], NULL, _enc, _options)];
}

/*
 Search the given node for the link corresponding to the url
 */
- (void)findLinkForURL:(NSString *)url fromNode:(xmlNode *)startNode {
    
    /*any HTML tag attributes that might contain the link we're looking for*/
    //static const char *attributesWithLink[] = {"href", "action"};
    //static const int numberOfAttributes = 2;
    
    /*for each sibling node...*/
    for(xmlNode *node = startNode; node!=NULL; node=node->next) {
        if(node->name) {
            printf("StartNode: %s\n",node->name);
        }
        
        /*for(xmlAttrPtr attr=node->properties; attr!=NULL; attr=attr->next) {
            for(int attributeIndex = 0; attributeIndex < numberOfAttributes; attributeIndex++) {
                printf("Attr: %s\n",(char *)attr->name);
                if (strcmp((char *)attr->name, attributesWithLink[attributeIndex]) == 0 && attr->children!=NULL) {
                    NSString *link = [NSString stringWithCString:(void*)attr->children->content encoding:NSUTF8StringEncoding];
                    NSLog(@"%@",link);
                }
            }
        }*/
        
        /*search for the url within the node's children*/
        [self findLinkForURL:url fromNode:node->children];
    }
}

@end
