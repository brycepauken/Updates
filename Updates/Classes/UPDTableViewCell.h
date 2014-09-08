//
//  UPDTableViewCell.h
//  Updates
//
//  Created by Bryce Pauken on 7/26/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (nonatomic, copy) void(^cellTapped)();

- (void)hideSpinnerWithContactBlock:(void (^)())contactBlock;
- (void)setCircleColor:(UIColor *)color animate:(BOOL)animate;
- (void)setDividerHidden:(BOOL)hidden;
- (void)setFavicon:(UIImage *)favicon;
- (void)setLastUpdated:(NSDate *)lastUpdated;
- (void)setLoadingCircleProgress:(CGFloat)progress;
- (void)setLockIconHidden:(BOOL)hidden;
- (void)setName:(NSString *)name;
- (void)showSpinner;

@end
