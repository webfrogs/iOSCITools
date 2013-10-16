//
//  MainViewController.h
//  PackageTools
//
//  Created by ccf on 10/11/13.
//  Copyright (c) 2013 ccf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController

- (void)addProjectWithPath:(NSString *)projectFilePath;
- (void)deleteSelectedProject;

@end
