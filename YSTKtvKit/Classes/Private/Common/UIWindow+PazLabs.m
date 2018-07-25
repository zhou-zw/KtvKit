//
//  UIWindow+PazLabs.m
//  HiTV
//
//  Created by yy on 15/8/25.
//  Copyright (c) 2015年 Lanbo Zhang. All rights reserved.
//

#import "UIWindow+PazLabs.h"

@implementation UIWindow (PazLabs)

- (void)visibleViewControllerShowController:(UIViewController *)controller
{
    UIViewController *vC = [self visibleViewController];
    //判断controller类型，显示约片邀请controller
    if ([vC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vC;
        [nav pushViewController:controller animated:YES];
    }
    else{
        if (vC.navigationController != nil) {
            [vC.navigationController pushViewController:controller animated:YES];
        }
        else{
            [vC presentViewController:controller animated:YES completion:nil];
        }
    }
}

- (UIViewController *)visibleViewController
{
    UIViewController *rootViewController = self.rootViewController;
    return [UIWindow getVisibleViewControllerFrom:rootViewController];
}

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc
{
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [UIWindow getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}


@end
