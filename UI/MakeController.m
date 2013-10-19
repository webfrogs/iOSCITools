//
//  MakeController.m
//  PackageTools
//
//  Created by ccf on 10/19/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "MakeController.h"

@interface MakeController(){
    
}

@property(assign)IBOutlet NSWindow *window;

@end

@implementation MakeController

#pragma mark - Outer methods
- (void)showSheet{
    if(!self.window){
        NSBundle *mainBundle = [NSBundle mainBundle];
        if ([mainBundle respondsToSelector:@selector(loadNibNamed:owner:topLevelObjects:)]) {
            [[NSBundle mainBundle]loadNibNamed:@"MakeSheet" owner:self topLevelObjects:nil];
        }else{
            [NSBundle loadNibNamed:@"MakeSheet" owner:self];
        }
    }
    
    [NSApp beginSheet:self.window modalForWindow:[[NSApp delegate] window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

#pragma mark - Events
- (IBAction)closeBtnClicked:(id)sender{
    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
}

@end
