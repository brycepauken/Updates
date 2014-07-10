//
//  UPDDocumentParser.m
//  Updates
//
//  Created by Bryce Pauken on 7/10/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDDocumentParser.h"

static const char *_enc;
static int _options;
static const char *_tagInputString;
static const char *_attrNameString;
static const char *_attrValueString;

@implementation UPDDocumentParser

+ (void)initialize {
    CFStringEncoding CFEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef CGEncodingSring = CFStringConvertEncodingToIANACharSetName(CFEncoding);
    _enc = CFStringGetCStringPtr(CGEncodingSring, 0);
    
    _options = HTML_PARSE_RECOVER|HTML_PARSE_NOERROR|HTML_PARSE_NOWARNING;
    
    _tagInputString = [@"input" UTF8String];
    _attrNameString = [@"name" UTF8String];
    _attrValueString = [@"value" UTF8String];
}

- (id)initWithDocumentString:(NSString *)documentString {
    self = [super init];
    if(self) {
        _document = htmlReadDoc((xmlChar *)[documentString UTF8String], NULL, _enc, _options);
    }
    return self;
}

- (NSMutableDictionary *)findInputFields {
    NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] init];
    [self findInputFieldsFromNode:(xmlNode *)_document withReturnDictionary:returnDictionary];
    return returnDictionary;
}

- (void)findInputFieldsFromNode:(xmlNode *)startNode withReturnDictionary:(NSMutableDictionary *)returnDictionary {
    for(xmlNode *node = startNode; node!=NULL; node=node->next) {
        if (node->name && strcmp((char *)node->name, _tagInputString) == 0) {
            NSString *inputName = nil;
            NSString *inputValue = nil;
            for(xmlAttrPtr attr=node->properties; attr!=NULL; attr=attr->next) {
                if (strcmp((char *)attr->name, _attrNameString) == 0 && attr->children!=NULL) {
                    inputName = [NSString stringWithCString:(void*)attr->children->content encoding:NSUTF8StringEncoding];
                }
                else if (strcmp((char *)attr->name, _attrValueString) == 0 && attr->children!=NULL) {
                    inputValue = [NSString stringWithCString:(void*)attr->children->content encoding:NSUTF8StringEncoding];
                }
            }
            if(inputName && inputValue) {
                [returnDictionary setObject:inputValue forKey:inputName];
            }
        }
        [self findInputFieldsFromNode:node->children withReturnDictionary:returnDictionary];
    }
}

@end
