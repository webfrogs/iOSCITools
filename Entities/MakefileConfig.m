//
//  MakefileConfig.m
//  PackageTools
//
//  Created by ccf on 10/16/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "MakefileConfig.h"

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
                
                NSString *selectorName = [NSString stringWithFormat:@"set%@",[configName capitalizedString]];
                SEL selector = NSSelectorFromString(selectorName);
                if ([self respondsToSelector:selector]) {
                    
                }
            }
        }
    }
    
    return self;
}

@end
