//
//  CommandManager.h
//  PackageTools
//
//  Created by ccf on 10/20/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandManager : NSObject

@property(assign)BOOL isRunning;
@property(strong)NSString *outputStr;

+ (CommandManager *)defaultManager;

- (void)runMakeAtDirectory:(NSString *)directory withOption:(unsigned int)option;

- (void)stopCommand;

@end
