//
//  MyRecord.m
//  YSTKtvKit
//
//  Created by 周朕威 on 2018/6/19.
//

#import "MyRecord.h"

@implementation MyRecord

static MyRecord *_instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    }) ;
    return _instance ;
}

@end
