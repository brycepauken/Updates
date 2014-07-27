//
//  UPDBrowserBottomBar.m
//  Updates
//
//  Created by Bryce Pauken on 7/17/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDBrowserBottomBar.h"

#import "UPDBrowserBottomButton.h"

@interface UPDBrowserBottomBar()

@property (nonatomic, retain) NSMutableArray *buttonBlocks;
@property (nonatomic, retain) NSArray *buttonNames;
@property (nonatomic, retain) NSMutableArray *buttons;

@end

@implementation UPDBrowserBottomBar

- (instancetype)initWithFrame:(CGRect)frame buttonNames:(NSArray *)buttonNames {
    self = [super initWithFrame:frame];
    if(self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        self.buttonNames = buttonNames;
        self.buttons = [[NSMutableArray alloc] initWithCapacity:self.buttonNames.count];
        self.buttonBlocks = [[NSMutableArray alloc] initWithCapacity:self.buttonNames.count];
        
        CGFloat buttonWidth = self.bounds.size.width/((CGFloat)self.buttonNames.count);
        for(int i=0;i<self.buttonNames.count;i++) {
            UPDBrowserBottomButton *button = [[UPDBrowserBottomButton alloc] initWithFrame:CGRectMake(buttonWidth*i, 0, buttonWidth, self.bounds.size.height)];
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
            if([[self.buttonNames objectAtIndex:i] isEqualToString:@"Back"] || [[self.buttonNames objectAtIndex:i] isEqualToString:@"Forward"]) {
                /*Back and Forward buttons disabled at start*/
                [button setEnabled:NO];
            }
            [button setImage:[UIImage imageNamed:[self.buttonNames objectAtIndex:i]]];
            [button setTag:i];
            [self addSubview:button];
            [self.buttons addObject:button];
            [self.buttonBlocks addObject:[NSNull null]];
        }
    }
    return self;
}

- (void)buttonTapped:(UIButton *)sender {
    id buttonBlock = [self.buttonBlocks objectAtIndex:sender.tag];
    if(![buttonBlock isEqual:[NSNull null]]) {
        ((void (^)())buttonBlock)();
    }
}

- (void)setBlockForButtonWithName:(NSString *)name block:(void (^)())block {
    for(int i=0;i<self.buttonNames.count;i++) {
        if([[self.buttonNames objectAtIndex:i] isEqualToString:name]) {
            [self.buttonBlocks replaceObjectAtIndex:i withObject:[block copy]];
        }
    }
}

- (void)setButtonEnabledWithName:(NSString *)name enabled:(BOOL)enabled {
    for(int i=0;i<self.buttonNames.count;i++) {
        if([[self.buttonNames objectAtIndex:i] isEqualToString:name]) {
            [[self.buttons objectAtIndex:i] setEnabled:enabled];
        }
    }
}

@end
