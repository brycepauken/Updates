//
//  UPDBrowserBottomButton.h
//  Updates
//
//  Created by Bryce Pauken on 7/19/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDBrowserBottomButton : UIButton

@property (nonatomic, strong) UIColor *normalBackgroundColor;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;

- (void)setImage:(UIImage *)image;

@end
