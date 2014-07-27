//
//  NSDate+UPDExtensions.m
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "NSDate+UPDExtensions.h"

@implementation NSDate (UPDExtensions)

- (NSString *)relativeDateFromDate:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond|NSCalendarUnitMinute|NSCalendarUnitHour|NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:self toDate:date options:0];
    if(components.year>0) {
        return [NSString stringWithFormat:@"%i year%@ ago",(int)components.year,components.year==1?@"":@"s"];
    }
    else if(components.month>0) {
        return [NSString stringWithFormat:@"%i month%@ ago",(int)components.month,components.month==1?@"":@"s"];
    }
    else if(components.day==1) {
        return @"yesterday";
    }
    else if(components.day>0) {
        return [NSString stringWithFormat:@"%i day%@ ago",(int)components.day,components.day==1?@"":@"s"];
    }
    else if(components.hour>0) {
        return [NSString stringWithFormat:@"%i hour%@ ago",(int)components.hour,components.hour==1?@"":@"s"];
    }
    else if(components.minute>0) {
        return [NSString stringWithFormat:@"%i minute%@ ago",(int)components.minute,components.minute==1?@"":@"s"];
    }
    else if(components.second>=30) {
        return @"30 seconds ago";
    }
    else {
        return @"a few seconds ago";
    }
}

@end
