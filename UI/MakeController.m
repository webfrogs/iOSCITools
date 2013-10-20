//
//  MakeController.m
//  PackageTools
//
//  Created by ccf on 10/19/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "MakeController.h"
#import "CommandManager.h"

#define CommandKeyPath          @"outputStr"

@interface MakeController(){
    CommandManager *_commandManager;
}

@property(assign)IBOutlet NSWindow *window;
@property(assign)IBOutlet NSTextView *outputTextView;

@end

@implementation MakeController

- (id)init{
    if (self = [super init]) {
        _commandManager = [CommandManager defaultManager];
    }
    return self;
}

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
    
    [_commandManager addObserver:self forKeyPath:CommandKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [NSApp beginSheet:self.window modalForWindow:[[NSApp delegate] window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:CommandKeyPath]) {
        
        if (change[NSKeyValueChangeNewKey] != [NSNull null]) {
            NSString *outputStr = change[NSKeyValueChangeNewKey];
            self.outputTextView.string = outputStr;
            NSRange range = NSMakeRange(outputStr.length, 0);
            [self.outputTextView scrollRangeToVisible:range];
        }
        
    }
}

#pragma mark - Events
- (IBAction)closeBtnClicked:(id)sender{
    [_commandManager removeObserver:self forKeyPath:CommandKeyPath];
    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
}

- (IBAction)startBtnClicked:(id)sender{
    if (self.projectDir.length == 0) {
        return;
    }
    self.outputTextView.string = @"";
    [_commandManager runMakeAtDirectory:self.projectDir];
}

@end
