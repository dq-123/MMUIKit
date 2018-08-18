//
//  MMKitWebViewController.h
//  MMKit
//
//  Created by Dwang on 2018/5/5.
//  Copyright © 2018年 CoderDwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMKitWebViewController : UIViewController

- (instancetype)initWithUrlString:(NSString *)urlString autoHiddenToolBar:(BOOL)autoHiddenToolBar saveImage:(BOOL)saveImage;

- (instancetype)initWithExitUrlString:(NSString *)urlString autoHiddenToolBar:(BOOL)autoHiddenToolBar saveImage:(BOOL)saveImage;

@end
