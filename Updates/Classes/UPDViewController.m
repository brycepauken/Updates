//
//  UPDViewController.m
//  Updates
//
//  Created by Bryce Pauken on 7/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDViewController.h"

@interface UPDViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation UPDViewController

- (void)viewDidLoad {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleSize];
    [self.scrollView setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:self.scrollView];
}

@end
