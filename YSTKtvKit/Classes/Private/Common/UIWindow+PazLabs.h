//
//  UIWindow+PazLabs.h
//  HiTV
//
//  Created by yy on 15/8/25.
//  Copyright (c) 2015年 Lanbo Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (PazLabs)

- (void)visibleViewControllerShowController:(UIViewController *)controller;
- (UIViewController *) visibleViewController;

@end
