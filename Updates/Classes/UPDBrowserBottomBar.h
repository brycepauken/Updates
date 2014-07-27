//
//  UPDBrowserBottomBar.h
//  Updates
//
//  Created by Bryce Pauken on 7/17/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDBrowserBottomBar : UIView

- (instancetype)initWithFrame:(CGRect)frame buttonNames:(NSArray *)buttonNames;

- (void)setBlockForButtonWithName:(NSString *)name block:(void (^)())block;
- (void)setButtonEnabledWithName:(NSString *)name enabled:(BOOL)enabled;

@end
