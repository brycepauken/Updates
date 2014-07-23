//
//  UPDPreProcessingView.h
//  Updates
//
//  Created by Bryce Pauken on 7/21/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDPreProcessingView : UIView

@property (nonatomic, copy) void(^completionBlock)();

- (void)beginPreProcessingWithBrowserImage:(UIImage *)browserImage;

@end
