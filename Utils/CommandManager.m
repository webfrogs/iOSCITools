//
//  CommandManager.m
//  PackageTools
//
//  Created by ccf on 10/20/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import "CommandManager.h"


static CommandManager *instance;

@interface CommandManager (){
    NSTask *_makeTask;
    NSPipe *_outputPipe;
}


@end

@implementation CommandManager


+ (CommandManager *)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CommandManager alloc] init];
    });
    
    return instance;
}

#pragma mark - Outer methods
- (void)runMakeAtDirectory:(NSString *)directory{
    [self runMakeAtDirectory:directory withParam:nil];
}

#pragma mark - Inner methods
- (void)runMakeAtDirectory:(NSString *)directory withParam:(NSArray *)params{
    NSString *makeQueueTag = @"makeQueue";
    dispatch_queue_t taskQueue = dispatch_queue_create(makeQueueTag.UTF8String, DISPATCH_QUEUE_SERIAL);
    dispatch_async(taskQueue, ^{
        self.isRunning = YES;
        
        @try {
            _makeTask = [[NSTask alloc] init];
            _makeTask.launchPath = @"/usr/bin/make";
            NSMutableArray *arguments = [NSMutableArray arrayWithObjects:@"-C", directory, nil];
            if (params != nil) {
                [arguments addObjectsFromArray:params];
            }
            _makeTask.arguments = arguments;
            
            _outputPipe = [[NSPipe alloc ]init];
            _makeTask.standardOutput = _outputPipe;
            
            [[_outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            
            [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[_outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *note) {
                NSData *output = [_outputPipe fileHandleForReading].availableData;
                NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (self.outputStr == nil) {
                        self.outputStr = outStr;
                    }else{
                        self.outputStr = [self.outputStr stringByAppendingString:[NSString stringWithFormat:@"%@\n",outStr]];
                    }
                    
                });
                [[_outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            }];
            
            [_makeTask launch];
            [_makeTask waitUntilExit];
            
            
        }
        @catch (NSException *exception) {
            NSLog(@"Problem in make task: %@",exception.description);
        }
        @finally {
            self.isRunning = NO;
            
//            [[NSNotificationCenter defaultCenter] removeObject:[_outputPipe fileHandleForReading]];
        }
        
    });
}

@end
