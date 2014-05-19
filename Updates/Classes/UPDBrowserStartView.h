//
//  UPDBrowserStartView.h
//  Updates
//
//  Created by Bryce Pauken on 5/17/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  UPDBrowserStartViewTextField;

@interface UPDBrowserStartView : UIView

@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic, retain) UIView *searchEngineContainer;
@property (nonatomic, retain) UILabel *searchEngineLabel;
@property (nonatomic, retain) UPDBrowserStartViewTextField *textField;

@end
