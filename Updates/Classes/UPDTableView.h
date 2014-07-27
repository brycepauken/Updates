//
//  UPDTableView.h
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UPDInternalUpdate;

@interface UPDTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) void(^updateSelected)(UPDInternalUpdate *update);

@end
