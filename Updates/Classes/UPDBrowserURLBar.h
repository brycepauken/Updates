//
//  UPDBrowserURLBar.h
//  Updates
//
//  Created by Bryce Pauken on 5/18/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDBrowserURLBar : UITextField <UITextFieldDelegate>

@property (nonatomic, copy) void (^goBlock)(NSString *url);
@property (nonatomic, copy) void (^startEditingBlock)();

@end
