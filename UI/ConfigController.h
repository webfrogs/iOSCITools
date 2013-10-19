//
//  ConfigController.h
//  PackageTools
//
//  Created by ccf on 10/17/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MakefileConfig.h"

@interface ConfigController : NSObject

@property(assign)IBOutlet NSWindow *sheet;
@property(assign)IBOutlet NSButton *cancelBtn;

@property(copy)void (^configSavedBlock)(MakefileConfig *config);

- (id)initWithConfig:(MakefileConfig *)config;

- (void)showSheet;

@end
