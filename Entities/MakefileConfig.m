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

#pragma mark - overwrite
- (NSString *)description{
    NSMutableString *result = [NSMutableString stringWithString:@""];
    
    if (self.configuration.length > 0 || self.appName.length > 0) {
        [result appendString:@"#------Compile setting-------start\n"];
        if (self.configuration.length > 0) {
            [result appendString:@"#The configuration of project.(default is Release)\n"];
            [result appendString:[NSString stringWithFormat:@"Configuration = %@\n\n",self.configuration]];
        }
        
        if (self.appName.length > 0) {
            [result appendString:@"#Name of app.(default value is CFBundleDisplayName of Info.plist)\n"];
            [result appendString:[NSString stringWithFormat:@"AppName = %@\n\n",self.appName]];
        }
        
        [result appendString:@"#------Compile setting-------end\n"];
        [result appendString:@"\n\n\n"];
    }
    
    if (self.baseURL.length > 0) {
        [result appendString:@"#------Http setting------start\n"];
        [result appendString:[NSString stringWithFormat:@"BaseURL = %@\n",self.baseURL]];
        [result appendString:@"#------Http setting------end\n"];
        [result appendString:@"\n\n\n"];
    }
    
    if (self.emailDomain.length > 0 ||
        self.emailReceiveList.length > 0 ||
        self.mailGunApiKey.length > 0) {
        [result appendString:@"#------E-mail setting------start\n"];
        
        if (self.emailDomain.length > 0) {
            [result appendString:[NSString stringWithFormat:@"EmailDomain = %@\n",self.emailDomain]];
        }
        
        if (self.emailReceiveList.length > 0) {
            [result appendString:[NSString stringWithFormat:@"MailReceiveList = %@\n",self.emailReceiveList]];
        }
        
        if (self.mailGunApiKey.length > 0) {
            [result appendString:[NSString stringWithFormat:@"MailGunApiKey = %@\n",self.mailGunApiKey]];
        }
        
        [result appendString:@"#------E-mail setting------end\n"];
        [result appendString:@"\n\n\n"];
    }
    
    if (self.iMsgList.length > 0) {
        [result appendString:@"#------iMessage setting------start\n"];
        [result appendString:@"#Receiver address list(seperated with white space)\n"];
        
        [result appendString:[NSString stringWithFormat:@"IMsgList = %@\n",self.iMsgList]];
        
        [result appendString:@"#------iMessage setting------end\n"];
        [result appendString:@"\n\n\n"];
    }
    
    if (self.scpHost.length > 0 ||
        self.scpUser.length > 0 ||
        self.scpFilePath.length > 0) {
        [result appendString:@"#------scp setting------start\n"];
        
        if (self.scpHost.length > 0) {
            [result appendString:[NSString stringWithFormat:@"ScpHost = %@\n",self.scpHost]];
        }
        
        if (self.scpUser.length > 0) {
            [result appendString:[NSString stringWithFormat:@"ScpUser = %@\n",self.scpUser]];
        }
        
        if (self.scpFilePath.length > 0) {
            [result appendString:[NSString stringWithFormat:@"ScpFilePath = %@\n",self.scpFilePath]];
        }
        
        [result appendString:@"#------scp setting------end\n"];
        [result appendString:@"\n\n\n"];

    }
    
    return result;
}

@end
