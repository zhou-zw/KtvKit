//
//  YSTKtvDefine.h
//  YSTKtvKit
//
//  Created by 周朕威 on 2018/6/13.
//

#ifndef YSTKtvDefine_h
#define YSTKtvDefine_h

#define bundlePath [[NSBundle bundleForClass:[self class]] pathForResource:@"YSTKtvKit" ofType:@"bundle"]

#define KtvBundle [NSBundle bundleWithPath:bundlePath]

#define APPDELEGATE [UIApplication sharedApplication].delegate

#endif /* YSTKtvDefine_h */
