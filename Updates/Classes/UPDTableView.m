//
//  UPDTableView.m
//  Updates
//
//  Created by Bryce Pauken on 7/16/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

/*
 Our custom tableview is its own datasource and delegate (this feels
 like bad practice—whoops.
 */

#import "UPDTableView.h"

@interface UPDTableView()

@property (nonatomic, strong) UILabel *startLabel;

@end

@implementation UPDTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setDataSource:self];
        [self setDelegate:self];
        
        [self setBackgroundColor:[UIColor UPDLightGreyColor]];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        self.startLabel = [[UILabel alloc] init];
        [self.startLabel setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.startLabel setFont:[UIFont systemFontOfSize:18]];
        [self.startLabel setHidden:YES];
        [self.startLabel setNumberOfLines:0];
        [self.startLabel setTextAlignment:NSTextAlignmentCenter];
        [self.startLabel setText:@"You don't have any\nupdates to check yet.\n\nTap the add icon\nabove to get started."];
        [self.startLabel setTextColor:[UIColor lightGrayColor]];
        CGSize startLabelSize = [self.startLabel.text boundingRectWithSize:CGSizeMake(UPD_START_LABEL_WIDTH, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.startLabel.font} context:nil].size;
        startLabelSize.height = ceilf(startLabelSize.height);
        startLabelSize.width = ceilf(startLabelSize.width);
        [self.startLabel setFrame:CGRectMake((self.bounds.size.width-startLabelSize.width)/2, (self.bounds.size.height-startLabelSize.height)/2, startLabelSize.width, startLabelSize.height)];
        [self addSubview:self.startLabel];
    }
    return self;
}

- (void)reloadData {
    BOOL tableFilled = [self numberOfRowsInSection:0]>0;
    [self setScrollEnabled:tableFilled];
    [self.startLabel setHidden:tableFilled];
    [super reloadData];
}

#pragma mark - Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
