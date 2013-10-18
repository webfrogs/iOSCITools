//
//  ConfigController.h
//  PackageTools
//
//  Created by ccf on 10/17/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigController : NSObject

@property(assign)IBOutlet NSWindow *sheet;
@property(assign)IBOutlet NSButton *cancelBtn;

- (void)showSheet;

@end
