//
//  MakefileConfig.h
//  PackageTools
//
//  Created by ccf on 10/16/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MakefileConfig : NSObject

// compile setting
@property(nonatomic, strong)NSString *configuration;
@property(nonatomic, strong)NSString *appName;

// http setting
@property(nonatomic, strong)NSString *baseURL;

// email setting
@property(nonatomic, strong)NSString *emailDomain;
@property(nonatomic, strong)NSString *mailReceiveList;
@property(nonatomic, strong)NSString *mailGunApiKey;

// iMessage setting
@property(nonatomic, strong)NSString *iMsgList;

// scp setting
@property(nonatomic, strong)NSString *scpHost;
@property(nonatomic, strong)NSString *scpUser;
@property(nonatomic, strong)NSString *scpFilePath;


- (id)initWithFilePath:(NSString *)filePath;

- (void)writeToFilePath:(NSString *)filePath;

- (BOOL)canDoUpload;

- (BOOL)canSendEmail;

- (BOOL)canSendIMsg;

@end
