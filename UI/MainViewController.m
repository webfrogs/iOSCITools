//
//  MainViewController.m
//  PackageTools
//
//  Created by ccf on 10/11/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "MainViewController.h"
#import "MakefileManager.h"


#define KVOKeyPath                  @"dataArray"

@interface MainViewController ()<NSTableViewDelegate,NSTableViewDataSource>

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
        
        MakefileConfig *config = [MakefileManager getMakefileConfigFromFilePath:@"/Users/ccf/develop/github/CCMakefile4iOS/Makefile.cfg"];
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
    
    [self.dataArray addObject:projectFilePath];
    [self.dataArray writeToFile:[self getProjectInfoPlistPath] atomically:YES];
    self.dataArray = self.dataArray;
    
    [MakefileManager addMakefileToDirectory:[projectFilePath stringByDeletingLastPathComponent]];
    
}

- (void)deleteSelectedProject{
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow >= 0 && selectedRow < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:selectedRow];
        [self.dataArray writeToFile:[self getProjectInfoPlistPath] atomically:YES];
        [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] withAnimation:NSTableViewAnimationEffectFade];
        
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
