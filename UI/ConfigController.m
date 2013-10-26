//
//  ConfigController.m
//  PackageTools
//
//  Created by ccf on 10/17/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "ConfigController.h"

#define KVOPath                 @"iMsgListArray"

@interface ConfigController ()<NSTableViewDelegate,NSTableViewDataSource,NSTabViewDelegate>{
    MakefileConfig *_config;
    BOOL _isEdit;
}

@property(assign)IBOutlet NSComboBox *configComboBox;
@property(assign)IBOutlet NSTextField *appNameTextField;
@property(assign)IBOutlet NSTextField *baseURLTextField;
@property(assign)IBOutlet NSTextField *EmailDomainTextField;
@property(assign)IBOutlet NSTextField *EmailReceiverTextField;
@property(assign)IBOutlet NSTextField *MailGunAPITextField;
@property(assign)IBOutlet NSTextField *addIMsgTextField;
@property(assign)IBOutlet NSTextField *scpHostTextField;
@property(assign)IBOutlet NSTextField *scpUserTextFild;
@property(assign)IBOutlet NSTextField *scpFilePathTextField;
@property(assign)IBOutlet NSTextField *ftpHostTextField;
@property(assign)IBOutlet NSTextField *ftpUserTextFild;
@property(assign)IBOutlet NSTextField *ftpPasswordTextField;
@property(assign)IBOutlet NSTableView *iMsgListTableView;
@property(assign)IBOutlet NSTabView *uploadTabView;
@property(assign)IBOutlet NSButton *iMsgDeleteBtn;

@property(strong)NSArray *iMsgListArray;


@end

@implementation ConfigController

- (id)init{
    if (self = [super init]) {
        _isEdit = NO;
        
        _config = [[MakefileConfig alloc] init];
        _config.configuration = @"Release";
        
        [self addObserver:self forKeyPath:KVOPath options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}


- (void)dealloc{
    [self removeObserver:self forKeyPath:KVOPath];
}

#pragma mark - Outer methods
- (void)showSheet{
    if (!self.sheet) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        if ([mainBundle respondsToSelector:@selector(loadNibNamed:owner:topLevelObjects:)]) {
            [[NSBundle mainBundle]loadNibNamed:@"ConfigSheet" owner:self topLevelObjects:nil];
        }else{
            [NSBundle loadNibNamed:@"ConfigSheet" owner:self];
        }
        
    }
    
    [self handleConfigToUI];
    
    [NSApp beginSheet:self.sheet modalForWindow:[[NSApp delegate] window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    
}

- (void)setEditModeByConfig:(MakefileConfig *)config{
    if (config == nil) {
        return;
    }
    
    _isEdit = YES;
    _config = config;
}

#pragma mark - NSTableView delegate and datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.iMsgListArray.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if ([cellView.identifier isEqualToString:@"iMsgCol"]) {
        cellView.textField.stringValue = self.iMsgListArray[row];
        
    }
    
    return cellView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    [self.iMsgDeleteBtn setEnabled:YES];
}

#pragma mark - NSTabViewDelegate
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem{
    NSInteger index = [tabView.tabViewItems indexOfObject:tabViewItem];
    NSLog(@"%ld",(long)index);
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:KVOPath]) {
        [self.iMsgListTableView reloadData];
    }
}

#pragma mark - Events
- (IBAction)saveBtnClicked:(id)sender{
    [self hideSheet];
    
    [self handleConfigFromUI];
    
    if (self.configSavedBlock) {
        self.configSavedBlock(_config);
    }
    
    
}

- (IBAction)cancelBtnClicked:(id)sender{
    [self hideSheet];
}

- (IBAction)iMsgAddBtnClicked:(id)sender{
    NSString *inputIMsg = self.addIMsgTextField.stringValue;
    if (inputIMsg.length > 0) {
        NSMutableArray *iMsgArray = [[NSMutableArray alloc] initWithArray:self.iMsgListArray];
        [iMsgArray addObject:inputIMsg];
        self.iMsgListArray = iMsgArray;
        
        self.addIMsgTextField.stringValue = @"";
        
        NSInteger newRowIndex = self.iMsgListArray.count -1;

        [self.iMsgListTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] byExtendingSelection:NO];
        [self.iMsgListTableView scrollRowToVisible:newRowIndex];
    }
}

- (IBAction)iMsgDeleteBtnClicked:(id)sender{
    NSInteger selectedRow = self.iMsgListTableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < self.iMsgListArray.count) {
        NSMutableArray *iMsgArray = [[NSMutableArray alloc] initWithArray:self.iMsgListArray];
        [iMsgArray removeObjectAtIndex:selectedRow];
        self.iMsgListArray = iMsgArray;
        
        if (selectedRow < self.iMsgListArray.count) {
            [self.iMsgListTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
        }
        

    }
}

#pragma mark - Inner methods
- (void)hideSheet{
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;
}

- (void)convertIMsgListFromObject{
    self.iMsgListArray = nil;
    if (_config.iMsgList.length > 0) {
        NSArray *iMsgList = [_config.iMsgList componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.iMsgListArray = [NSMutableArray arrayWithArray:iMsgList];
    }
}

- (void)convertIMsgListToObject{
    _config.iMsgList = nil;
    if (self.iMsgListArray.count > 0) {
        NSMutableString *iMsgListStr = [[NSMutableString alloc]init];
        for (NSString *iMsg in self.iMsgListArray) {
            [iMsgListStr appendString:[NSString stringWithFormat:@"%@ ",iMsg]];
        }
        _config.iMsgList = [iMsgListStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

- (void)handleConfigToUI{
    [self.cancelBtn setHidden:!_isEdit];
    [self.iMsgDeleteBtn setEnabled:NO];
    [self convertIMsgListFromObject];
    
    if (_isEdit &&
        (_config.ftpHost.length > 0 ||
         _config.ftpUser.length > 0 ||
         _config.ftpPassword.length > 0)) {
        [self.uploadTabView selectTabViewItemAtIndex:0];
    }else{
        [self.uploadTabView selectTabViewItemAtIndex:1];
    }
    
    if (_config.configuration.length > 0) {
        self.configComboBox.stringValue = _config.configuration;
    }
    
    if (_config.appName.length > 0) {
        self.appNameTextField.stringValue = _config.appName;
    }
    
    if (_config.baseURL.length > 0) {
        self.baseURLTextField.stringValue = _config.baseURL;
    }
    
    if (_config.mailGunDomain.length > 0) {
        self.EmailDomainTextField.stringValue = _config.mailGunDomain;
    }
    
    if (_config.mailGunReceiveList.length > 0) {
        self.EmailReceiverTextField.stringValue = _config.mailGunReceiveList;
    }
    
    if (_config.mailGunApiKey.length > 0) {
        self.MailGunAPITextField.stringValue = _config.mailGunApiKey;
    }
    
    if (_config.scpHost.length > 0) {
        self.scpHostTextField.stringValue = _config.scpHost;
    }
    
    if (_config.scpUser.length > 0) {
        self.scpUserTextFild.stringValue = _config.scpUser;
    }
    
    if (_config.scpFilePath.length > 0) {
        self.scpFilePathTextField.stringValue = _config.scpFilePath;
    }
    
    if (_config.ftpHost.length > 0) {
        self.ftpHostTextField.stringValue = _config.ftpHost;
    }
    
    if (_config.ftpUser.length > 0) {
        self.ftpUserTextFild.stringValue = _config.ftpUser;
    }
    
    if (_config.ftpPassword.length > 0) {
        self.ftpPasswordTextField.stringValue = _config.ftpPassword;
    }
    
}

- (void)handleConfigFromUI{
    [self convertIMsgListToObject];
    
    _config.configuration = self.configComboBox.stringValue;
    _config.appName = self.appNameTextField.stringValue;
    _config.baseURL = self.baseURLTextField.stringValue;
    _config.mailGunDomain = self.EmailDomainTextField.stringValue;
    _config.mailGunReceiveList = self.EmailReceiverTextField.stringValue;
    _config.mailGunApiKey = self.MailGunAPITextField.stringValue;
    _config.scpHost = self.scpHostTextField.stringValue;
    _config.scpUser = self.scpUserTextFild.stringValue;
    _config.scpFilePath = self.scpFilePathTextField.stringValue;
    _config.ftpHost = self.ftpHostTextField.stringValue;
    _config.ftpUser = self.ftpUserTextFild.stringValue;
    _config.ftpPassword = self.ftpPasswordTextField.stringValue;
}

@end
