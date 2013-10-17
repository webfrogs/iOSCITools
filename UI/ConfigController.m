//
//  ConfigController.m
//  PackageTools
//
//  Created by ccf on 10/17/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "ConfigController.h"

@implementation ConfigController

- (void)showSheet{
    if (!self.sheet) {
        [[NSBundle mainBundle]loadNibNamed:@"ConfigSheet" owner:self topLevelObjects:nil];
//        [NSBundle loadNibNamed:@"ConfigSheet" owner:self];
    }
    
    [NSApp beginSheet:self.sheet modalForWindow:[[NSApp delegate] window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (IBAction)closeSheet:(id)sender{
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;
}

@end
