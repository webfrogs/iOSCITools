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
    NSPipe *_errorPipe;
    
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
- (void)runMakeAtDirectory:(NSString *)directory withOption:(unsigned int)option{
    if (option == 0) {
        return;
    }
    
    self.outputStr = nil;
    
    NSString *suffixStr = @" && ";
    NSString *makeCmdStr = @"";
    if (option & MAKEOPTION_COMPILE) {
        makeCmdStr = [NSString stringWithFormat:@"%@%@%@",makeCmdStr, @"make",suffixStr];
    }
    
    if (option & MAKEOPTION_UPLOAD) {
        makeCmdStr = [NSString stringWithFormat:@"%@%@%@",makeCmdStr,@"make upload",suffixStr];
    }
    
    if (option & MAKEOPTION_SENDEMAIL) {
        makeCmdStr = [NSString stringWithFormat:@"%@%@%@",makeCmdStr,@"make sendEmail",suffixStr];
    }
    
    if (option & MAKEOPTION_SENDIMSG) {
        makeCmdStr = [NSString stringWithFormat:@"%@%@%@",makeCmdStr,@"make sendIMsg",suffixStr];
    }
    
    makeCmdStr = [makeCmdStr substringToIndex:makeCmdStr.length - suffixStr.length];
    
    NSString *makeQueueTag = @"makeQueue";
    dispatch_queue_t taskQueue = dispatch_queue_create(makeQueueTag.UTF8String, DISPATCH_QUEUE_SERIAL);
    dispatch_async(taskQueue, ^{
        self.isRunning = YES;
        
        @try {
            _makeTask = [[NSTask alloc] init];
            _makeTask.launchPath = @"/bin/bash";
            
            NSString *shellCmdStr = [NSString stringWithFormat:@"cd %@\n%@",directory,makeCmdStr];
            
            _makeTask.arguments = @[@"-c",shellCmdStr];
            
            // NSTask standard output
            _outputPipe = [[NSPipe alloc ]init];
            _makeTask.standardOutput = _outputPipe;
            
            [[_outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputNotification:) name:NSFileHandleDataAvailableNotification object:[_outputPipe fileHandleForReading]];
            
            // NSTask standard error
            _errorPipe = [[NSPipe alloc] init];
            _makeTask.standardError = _errorPipe;

            
            [[_errorPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorNotification:) name:NSFileHandleDataAvailableNotification object:[_errorPipe fileHandleForReading]];
            
      
            
            [_makeTask launch];
            [_makeTask waitUntilExit];
            
            
        }
        @catch (NSException *exception) {
            NSLog(@"Problem in make task: %@",exception.description);
        }
        @finally {
            self.isRunning = NO;
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
        }
        
    });
    
}

#pragma mark -
- (void)outputNotification:(NSNotification *)note{
    NSData *output = [_outputPipe fileHandleForReading].availableData;
    NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self addStrToOutputStr:outStr];
    });
    [[_outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
}

- (void)errorNotification:(NSNotification *)note{
    NSData *error = [_errorPipe fileHandleForReading].availableData;
    NSString *errorStr = [[NSString alloc] initWithData:error encoding:NSUTF8StringEncoding];
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"%@",errorStr);
        [self addStrToOutputStr:errorStr];
    });
    
    [[_errorPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
}

#pragma mark - Inner methods
- (void)addStrToOutputStr:(NSString *)str{
    if (self.outputStr == nil) {
        self.outputStr = str;
    }else{
        self.outputStr = [self.outputStr stringByAppendingString:[NSString stringWithFormat:@"%@\n",str]];
    }
}

@end
