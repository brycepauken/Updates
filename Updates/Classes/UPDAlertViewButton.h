//
//  UPDAlertViewButton.h
//  Updates
//
//  Created by Bryce Pauken on 7/20/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDAlertViewButton : UIButton

@property (nonatomic, strong) UIColor *disabledBackgroundColor;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
@property (nonatomic, strong) UIColor *normalBackgroundColor;

- (void)setFont:(UIFont *)font;
- (void)setImage:(UIImage *)image;
- (void)setTextColor:(UIColor *)color;
- (void)setTitle:(NSString *)title;

@end
