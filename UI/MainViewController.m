//
//  MainViewController.m
//  PackageTools
//
//  Created by ccf on 10/11/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "MainViewController.h"
#import "MakefileManager.h"
#import "ConfigController.h"
#import "MakeController.h"


#define KVOKeyPath                  @"dataArray"

@interface MainViewController ()<NSTableViewDelegate,NSTableViewDataSource>{
    ConfigController *_configSheet;
    MakeController *_makeSheet;
}

@property (weak) IBOutlet NSTableView *tableView;


@property(nonatomic, strong)NSMutableArray *dataArray;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.dataArray = [NSMutableArray array];
        
        NSString *projectInfoPlistPath = [self getProjectInfoPlistPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:projectInfoPlistPath]) {
            self.dataArray = [NSMutableArray arrayWithContentsOfFile:projectInfoPlistPath];
        }
        
        [self addObserver:self forKeyPath:KVOKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        
//        MakefileConfig *config = [MakefileManager getMakefileConfigFromFilePath:@"/Users/ccf/develop/iOS/iPhoneClient/iPhoneClient/Makefile.cfg"];
//        
//        [config writeToFilePath:@"/Users/ccf/Makefile.cfg"];
//        NSLog(@"%@",config);
    }
    return self;
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:KVOKeyPath];
}

#pragma mark - Outer methods
- (void)addProjectWithPath:(NSString *)projectFilePath{
    
    if (projectFilePath.length == 0) {
        return;
    }
    
    if ([self.dataArray containsObject:projectFilePath]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Project already exist."];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setInformativeText:@"Select other projects"];
        [alert beginSheetModalForWindow:self.view.window
                          modalDelegate:nil didEndSelector:nil contextInfo:nil];
        return;
    }
    
    _configSheet = [[ConfigController alloc] init];
    MakefileConfig *config = [MakefileManager getMakefileConfigFromDirectory:[projectFilePath stringByDeletingLastPathComponent]];
    if (config != nil) {
        [_configSheet setEditModeByConfig:config];
    }
    
    __weak MainViewController *wSelf = self;
    _configSheet.configSavedBlock = ^(MakefileConfig *config){
        [wSelf.dataArray addObject:projectFilePath];
        [wSelf.dataArray writeToFile:[wSelf getProjectInfoPlistPath] atomically:YES];
        wSelf.dataArray = wSelf.dataArray;
        
        NSString *directory = [projectFilePath stringByDeletingLastPathComponent];
        [MakefileManager addMakefileToDirectory:directory];
        [MakefileManager writeConfigToDirectory:config directory:directory];
        
    };
    [_configSheet showSheet];
    
    
}

- (void)deleteSelectedProject{
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow >= 0 && selectedRow < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:selectedRow];
        [self.dataArray writeToFile:[self getProjectInfoPlistPath] atomically:YES];
        [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] withAnimation:NSTableViewAnimationEffectFade];
        
    }
}

- (void)editProjectMakeConfig{
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow >= 0 && selectedRow < self.dataArray.count) {
        NSString *projectPath = self.dataArray[selectedRow];
        NSString *projectDirectory = [projectPath stringByDeletingLastPathComponent];
        MakefileConfig *config = [MakefileManager getMakefileConfigFromDirectory:projectDirectory];
        _configSheet = [[ConfigController alloc] initWithConfig:config];
        _configSheet.configSavedBlock = ^(MakefileConfig *config){
            [MakefileManager writeConfigToDirectory:config directory:projectDirectory];
        };
        [_configSheet showSheet];
    }
}

- (void)runMake{
        
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow >= 0 && selectedRow < self.dataArray.count) {
        NSString *projectPath = self.dataArray[selectedRow];
        
        _makeSheet = [[MakeController alloc] init];
        _makeSheet.projectDir = [projectPath stringByDeletingLastPathComponent];
        [_makeSheet showSheet];
        
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:KVOKeyPath]) {
        [self.tableView reloadData];
    }
}

#pragma mark - NSTableView delegate and datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.dataArray.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if ([tableColumn.identifier isEqualToString:@"ProjectColumn"]) {
        NSURL *fileUrl = [NSURL fileURLWithPath:self.dataArray[row]];
        cellView.textField.stringValue = [fileUrl lastPathComponent];
        
    }
    
    return cellView;
}

#pragma mark - Inner methods
- (NSString *)getProjectInfoPlistPath{
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    return [bundlePath stringByAppendingPathComponent:@"projectInfo.plist"];
}



@end
