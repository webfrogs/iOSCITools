//
//  AppDelegate.m
//  PackageTools
//
//  Created by ccf on 10/11/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@property(nonatomic, strong) MainViewController *mainController;
@property (weak) IBOutlet NSToolbarItem *deleteToolbar;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.mainController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    
    [self.window.contentView addSubview:self.mainController.view];
    self.mainController.view.frame = ((NSView *)self.window.contentView).bounds;
    
}

#pragma mark - ToolBarAction
- (IBAction)addProject:(id)sender {
    NSOpenPanel *filePanel = [NSOpenPanel openPanel];
    [filePanel setCanChooseFiles:YES];
    [filePanel setCanChooseDirectories:NO];
    [filePanel setAllowedFileTypes:@[@"xcodeproj"]];
    if ([filePanel runModal] == NSFileHandlingPanelOKButton) {
        NSURL *fileURL = [filePanel URL];
        if ([fileURL isFileURL]) {
//            NSLog(@"%@",[fileURL path]);
            [self.mainController addProjectWithPath:[fileURL path]];
        }
    }
}

- (IBAction)deleteProject:(id)sender {
    [self.mainController deleteSelectedProject];
}

@end
