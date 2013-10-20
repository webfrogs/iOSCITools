//
//  MakefileManager.m
//  PackageTools
//
//  Created by ccf on 10/16/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "MakefileManager.h"

#define MakefileName                @"Makefile"
#define MakefileCfgName             @"Makefile.cfg"


@implementation MakefileManager

+ (void)addMakefileToDirectory:(NSString *)directoryPath{
    BOOL isDirectory = NO;
    
    NSString *makefilePath = [directoryPath stringByAppendingPathComponent:MakefileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDirectory] && isDirectory) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:makefilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:makefilePath error:nil];
        }
        
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:MakefileName]  toPath:makefilePath error:&error];
        
//        NSLog(@"%@",error);

    }
}

+ (MakefileConfig *)getMakefileConfigFromDirectory:(NSString *)directoryPath{
    return [[MakefileConfig alloc] initWithFilePath:[directoryPath stringByAppendingPathComponent:MakefileCfgName]];
}

+ (void)writeConfigToDirectory:(MakefileConfig *)config directory:(NSString *)directoryPath{
    [config writeToFilePath:[directoryPath stringByAppendingPathComponent:MakefileCfgName]];
}

@end
