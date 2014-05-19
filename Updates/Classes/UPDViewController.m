//
//  UPDViewController.m
//  Update
//
//  Created by Bryce Pauken on 5/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDViewController.h"

#import "UPDInterface.h"

@interface UPDViewController ()

@end

@implementation UPDViewController

- (id)init {
    self = [super init];
    if(self) {
        self.hideStatusBar = NO;
        self.lightStatusBarContent = NO;
        
        [self.view setClipsToBounds:YES];
        
        self.interface = [[UPDInterface alloc] initWithFrame:self.view.bounds];
        [self.interface setAutoresizingMask:UIViewAutoresizingFlexibleSize];
        [self.view addSubview:self.interface];
        
        UITextField *field = [UITextField new];
        [[[[UIApplication sharedApplication] windows] lastObject] addSubview:field];
        [field becomeFirstResponder];
        [field resignFirstResponder];
        [field removeFromSuperview];
        
        
        /*
        //test
        NSManagedObjectContext *context = [AppDelegate managedObjectContext];
        NSManagedObject *newInstructionList = [NSEntityDescription insertNewObjectForEntityForName:@"InstructionList" inManagedObjectContext:context];
        NSMutableSet *instructions = [newInstructionList mutableSetValueForKey:@"instructions"];
        NSManagedObject *newInstruction = [NSEntityDescription insertNewObjectForEntityForName:@"Instruction" inManagedObjectContext:context];
        [newInstruction setValue:@"http://google.com/" forKey:@"url"];
        [newInstruction setValue:@([instructions count]) forKey:@"instructionNumber"];
        [instructions addObject:newInstruction];
        [newInstructionList setValue:instructions forKey:@"instructions"];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityForFetch = [NSEntityDescription entityForName:@"InstructionList" inManagedObjectContext:context];
        [fetchRequest setEntity:entityForFetch];
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        for (NSManagedObject *info in fetchedObjects) {
            NSLog(@"%@",info);
        }
        */
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return self.hideStatusBar;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return self.lightStatusBarContent?UIStatusBarStyleLightContent:UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([UPDCommon isIOS7]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

@end
