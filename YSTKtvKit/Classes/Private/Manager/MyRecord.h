//
//  MyRecord.h
//  YSTKtvKit
//
//  Created by 周朕威 on 2018/6/19.
//

#import <Foundation/Foundation.h>

@interface MyRecord : NSObject

+ (instancetype)shareInstance;

@property (nonatomic ,strong) NSArray *recordArray;

@end
