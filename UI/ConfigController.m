//
//  ConfigController.m
//  PackageTools
//
//  Created by ccf on 10/17/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "ConfigController.h"


@interface ConfigController (){
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



@end

@implementation ConfigController

- (id)init{
    if (self = [super init]) {
        _isEdit = NO;
        
        _config = [[MakefileConfig alloc] init];
        _config.configuration = @"Release";
    }
    return self;
}

- (id)initWithConfig:(MakefileConfig *)config{
    if (config == nil) {
        return [self init];
    }
    
    if (self = [super init]) {
        
        _config = config;
        _isEdit = YES;
    }
    
    return self;
}

#pragma mark - Outer methods
- (void)showSheet{
    if (!self.sheet) {
        [[NSBundle mainBundle]loadNibNamed:@"ConfigSheet" owner:self topLevelObjects:nil];
//        [NSBundle loadNibNamed:@"ConfigSheet" owner:self];
    }
    
    [self updateUI];
    
    [NSApp beginSheet:self.sheet modalForWindow:[[NSApp delegate] window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

#pragma mark - Events
- (IBAction)saveBtnClicked:(id)sender{
    [self hideSheet];
}

- (IBAction)cancelBtnClicked:(id)sender{
    [self hideSheet];
}

#pragma mark - Inner methods
- (void)hideSheet{
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;
}

- (void)updateUI{
    [self.cancelBtn setEnabled:_isEdit];
    
    if (_config.configuration.length > 0) {
        self.configComboBox.stringValue = _config.configuration;
    }
    
    if (_config.appName.length > 0) {
        self.appNameTextField.stringValue = _config.appName;
    }
    
    if (_config.baseURL.length > 0) {
        self.baseURLTextField.stringValue = _config.baseURL;
    }
    
    if (_config.emailDomain.length > 0) {
        self.EmailDomainTextField.stringValue = _config.emailDomain;
    }
    
    if (_config.emailReceiveList.length > 0) {
        self.EmailReceiverTextField.stringValue = _config.emailReceiveList;
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
    
}

@end
