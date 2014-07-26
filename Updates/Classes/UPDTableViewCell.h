//
//  UPDTableViewCell.h
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDTableViewCell : UITableViewCell <UIScrollViewDelegate>

- (void)setDividerHidden:(BOOL)hidden;
- (void)setFavicon:(UIImage *)favicon;
- (void)setLastUpdated:(NSDate *)lastUpdated;
- (void)setName:(NSString *)name;

@end
