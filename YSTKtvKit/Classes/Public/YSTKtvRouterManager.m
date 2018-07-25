//
//  YSTKtvRouterManager.m
//  YSTKtvKit
//
//  Created by 周朕威 on 2018/6/19.
//

#import "YSTKtvRouterManager.h"
#import "YSTKtvViewController.h"

@implementation YSTKtvRouterManager
+ (instancetype)sharedInstance {
    static YSTKtvRouterManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YSTKtvRouterManager alloc] init];
        
        [instance registOpenKtv];
        
    });
    return instance;
}

- (void)registOpenKtv{
    [MGJRouter registerURLPattern:OpenKtv_URL
                        toHandler:^(NSDictionary *routerParameters) {
                            YSTKtvViewController *vc = [[YSTKtvViewController alloc]init];
                            UIViewController *activecontroller = [APPDELEGATE.window visibleViewController];
                            [activecontroller.navigationController pushViewController:vc animated:YES];
                        }];
}

@end
