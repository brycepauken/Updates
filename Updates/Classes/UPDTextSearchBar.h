//
//  UPDTextSearchBar.h
//  Updates
//
//  Created by Bryce Pauken on 8/2/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDTextSearchBar : UIView <UITextFieldDelegate>

@property (nonatomic, copy) void(^goButtonBlock)(NSString *text);
@property (nonatomic, copy) void(^textChanged)(NSString *text);

@end
