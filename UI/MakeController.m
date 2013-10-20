//
//  MakeController.m
//  PackageTools
//
//  Created by ccf on 10/19/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "MakeController.h"
#import "CommandManager.h"
#import "MakefileManager.h"

#define CommandOutputKVOPath            @"outputStr"
#define CommandRunningKVOPath           @"isRunning"

@interface MakeController(){
    CommandManager *_commandManager;
}

@property(assign)IBOutlet NSWindow *window;
@property(assign)IBOutlet NSTextView *outputTextView;
@property(assign)IBOutlet NSProgressIndicator *spinner;
@property(assign)IBOutlet NSButton *compileCheckBox;
@property(assign)IBOutlet NSButton *uploadCheckBox;
@property(assign)IBOutlet NSButton *emailCheckBox;
@property(assign)IBOutlet NSButton *iMsgCheckBox;

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
    
    [_commandManager addObserver:self forKeyPath:CommandOutputKVOPath options:NSKeyValueObservingOptionNew context:nil];
    [_commandManager addObserver:self forKeyPath:CommandRunningKVOPath options:NSKeyValueObservingOptionNew context:nil];
    
    
    [self updateUIStatusBeforeShown];
    [NSApp beginSheet:self.window modalForWindow:[[NSApp delegate] window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:CommandOutputKVOPath]) {
        
        if (change[NSKeyValueChangeNewKey] != [NSNull null]) {
            NSString *outputStr = change[NSKeyValueChangeNewKey];
            self.outputTextView.string = outputStr;
            NSRange range = NSMakeRange(outputStr.length, 0);
            [self.outputTextView scrollRangeToVisible:range];
        }
        
    }else if([keyPath isEqualToString:CommandRunningKVOPath]){
        if (change[NSKeyValueChangeNewKey] != [NSNull null]) {
            NSNumber *running = change[NSKeyValueChangeNewKey];
            BOOL isRunning = running.boolValue;
            [self.spinner setHidden:!isRunning];
            if (isRunning) {
                [self.spinner startAnimation:nil];
            }else{
                [self.spinner stopAnimation:nil];
            }
            
        }
        
    }
}

#pragma mark - Events
- (IBAction)closeBtnClicked:(id)sender{
    [_commandManager removeObserver:self forKeyPath:CommandOutputKVOPath];
    [_commandManager removeObserver:self forKeyPath:CommandRunningKVOPath];
    [NSApp endSheet:self.window];
    [self.window close];
    self.window = nil;
}

- (IBAction)startBtnClicked:(id)sender{
    if (self.projectDir.length == 0) {
        return;
    }
    self.outputTextView.string = @"";
    
    unsigned int makeOption = 0;
    
    if (self.compileCheckBox.state == NSOnState) {
        makeOption |= MAKEOPTION_COMPILE;
    }
    if (self.uploadCheckBox.state == NSOnState) {
        makeOption |= MAKEOPTION_UPLOAD;
    }
    if (self.emailCheckBox.state == NSOnState) {
        makeOption |= MAKEOPTION_SENDEMAIL;
    }
    if (self.iMsgCheckBox.state == NSOnState) {
        makeOption |= MAKEOPTION_SENDIMSG;
    }
    
    [_commandManager runMakeAtDirectory:self.projectDir withOption:makeOption];
}

#pragma mark - Inner methods
- (void)updateUIStatusBeforeShown{
    [self.spinner setHidden:YES];
    
    MakefileConfig *config = [MakefileManager getMakefileConfigFromDirectory:self.projectDir];
    
    
    [self.uploadCheckBox setEnabled:[config canDoUpload]];
    [self.emailCheckBox setEnabled:[config canSendEmail]];
    [self.iMsgCheckBox setEnabled:[config canSendIMsg]];
    
    
}

@end
