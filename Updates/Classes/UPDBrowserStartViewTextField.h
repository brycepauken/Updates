//
//  UPDBrowserStartViewTextField.h
//  Updates
//
//  Created by Bryce Pauken on 5/17/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDBrowserStartViewTextField : UITextField

@property (nonatomic, retain) UIButton *button;
@property (nonatomic, copy) void (^goBlock)(NSString *url);

@end
