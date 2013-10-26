//
//  MakefileConfig.m
//  PackageTools
//
//  Created by ccf on 10/16/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "MakefileConfig.h"
#import <objc/message.h>

@implementation MakefileConfig

- (id)initWithFilePath:(NSString *)filePath{
    if (filePath.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
    if (self = [super init]) {
        NSError *error = nil;
        NSString *totalStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        if (error == nil) {
            NSArray *lineArray =[totalStr componentsSeparatedByString:@"\n"];
            for (NSString *lineStr in lineArray) {
                NSString *trimStr = [lineStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([trimStr hasPrefix:@"#"]) {
                    continue;
                }
                
                NSRange seperatorRange = [trimStr rangeOfString:@"="];
                if (seperatorRange.location == NSNotFound) {
                    continue;
                }
                
                NSString *configName = [[trimStr substringToIndex:seperatorRange.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *configValue = [[trimStr substringFromIndex:seperatorRange.location + seperatorRange.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if (configValue.length == 0) {
                    continue;
                }
                
                NSString *selectorName = [NSString stringWithFormat:@"set%@%@:",[[configName substringToIndex:1] uppercaseString],[configName substringFromIndex:1]];
                SEL selector = NSSelectorFromString(selectorName);
                if ([self respondsToSelector:selector]) {
                    objc_msgSend(self, selector,configValue);
                }
            }
        }
    }
    
    return self;
}

#pragma mark - Outer methods
- (void)writeToFilePath:(NSString *)filePath{
    NSString *str = [self description];
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL)canDoUpload{
    BOOL result = NO;
    
    if (self.scpHost.length > 0 ||
        self.scpUser.length > 0 ||
        self.scpFilePath.length > 0) {
        result = YES;
    }
    
    if (self.ftpHost.length > 0 &&
        self.ftpUser.length > 0 &&
        self.ftpPassword.length > 0) {
        result = YES;
    }
    
    return result;
}

- (BOOL)canSendEmail{
    BOOL result = YES;
    
    if (self.mailGunDomain.length == 0 ||
        self.mailGunReceiveList.length == 0 ||
        self.mailGunApiKey.length == 0) {
        result = NO;
    }
    
    return result;
}

- (BOOL)canSendIMsg{
    BOOL result = YES;
    
    if (self.iMsgList.length == 0) {
        result = NO;
    }
    
    return result;
}

#pragma mark - overwrite
- (NSString *)description{
    NSMutableString *result = [NSMutableString stringWithString:@""];
    
    [result appendString:@"#------Compile setting-------start\n"];
    [result appendString:@"#The configuration of project.(default is Release)\n"];
    [result appendString:[self combineConfigItemToString:@"Configuration"]];
    [result appendString:@"\n"];
    [result appendString:@"#Name of app.(default value is CFBundleDisplayName of Info.plist)\n"];
    [result appendString:[self combineConfigItemToString:@"AppName"]];
    [result appendString:@"#------Compile setting-------end\n"];
    [result appendString:@"\n\n\n"];
    
    
    [result appendString:@"#------Http setting------start\n"];
    [result appendString:[self combineConfigItemToString:@"BaseURL"]];
    [result appendString:@"#------Http setting------end\n"];
    [result appendString:@"\n\n\n"];
    
    
    [result appendString:@"#------MailGun setting------start\n"];
    [result appendString:@"#use MailGun to send emails. (http://www.mailgun.com/)\n"];
    [result appendString:[self combineConfigItemToString:@"MailGunDomain"]];
    [result appendString:[self combineConfigItemToString:@"MailGunReceiveList"]];
    [result appendString:[self combineConfigItemToString:@"MailGunApiKey"]];
    [result appendString:@"#------MailGun setting------end\n"];
    [result appendString:@"\n\n\n"];
    
    
    [result appendString:@"#------iMessage setting------start\n"];
    [result appendString:@"#Receiver address list(seperated with white space)\n"];
    [result appendString:[self combineConfigItemToString:@"IMsgList"]];
    [result appendString:@"#------iMessage setting------end\n"];
    [result appendString:@"\n\n\n"];
    
    
    [result appendString:@"#------scp setting------start\n"];
    [result appendString:[self combineConfigItemToString:@"ScpHost"]];
    [result appendString:[self combineConfigItemToString:@"ScpUser"]];
    [result appendString:[self combineConfigItemToString:@"ScpFilePath"]];
    [result appendString:@"#------scp setting------end\n"];
    [result appendString:@"\n\n\n"];
    
    
    [result appendString:@"#------ftp setting------start\n"];
    [result appendString:[self combineConfigItemToString:@"FtpHost"]];
    [result appendString:[self combineConfigItemToString:@"FtpUser"]];
    [result appendString:[self combineConfigItemToString:@"FtpPassword"]];
    [result appendString:@"#------ftp setting------end\n"];
    
    
    return result;
}

#pragma mark - Inner methods
- (NSString *)combineConfigItemToString:(NSString *)configItem{
    NSString *selectorName = [NSString stringWithFormat:@"%@%@",[[configItem substringToIndex:1] lowercaseString],[configItem substringFromIndex:1]];
    SEL selector = NSSelectorFromString(selectorName);
    NSString *itemValue = nil;
    if ([self respondsToSelector:selector]) {
        itemValue = objc_msgSend(self, selector);
    }
    
    NSString *resultStr = @"";
    if (itemValue.length > 0) {
        resultStr = [NSString stringWithFormat:@"%@ = %@\n",configItem,itemValue];
    }else{
        resultStr = [NSString stringWithFormat:@"#%@ = \n",configItem];
    }
    
    
    return resultStr;
}

@end
