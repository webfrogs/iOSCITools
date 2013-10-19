//
//  MakefileManager.h
//  PackageTools
//
//  Created by ccf on 10/16/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MakefileConfig.h"

@interface MakefileManager : NSObject

+ (void)addMakefileToDirectory:(NSString *)directoryPath;

+ (MakefileConfig *)getMakefileConfigFromDirectory:(NSString *)directoryPath;

+ (void)writeConfigToDirectory:(MakefileConfig *)config directory:(NSString *)directoryPath;
@end
