//
//  UPDTableViewContoller.h
//  Update
//
//  Created by Bryce Pauken on 5/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPDTableViewContoller : UITableViewController

@property (nonatomic, copy) void (^addBlock)();

- (id)initWithAddBlock:(void (^)())addBlock;

@end
