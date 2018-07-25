//
//  TalkManager.h
//  GCDAsyncSocketDemo
//
//  Created by aipu on 2018/4/16.
//  Copyright © 2018年 XuningZhai All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YSTTalkManagerDelegate <NSObject>
//连接状态
- (void)connectState:(BOOL)state;
@end

@interface TalkManager : NSObject

@property (nonatomic,copy)NSString *ip;
@property (nonatomic,assign)int port;
@property (nonatomic, weak) id<YSTTalkManagerDelegate>delegate;

+ (instancetype)manager;
- (void)connectSocket;      //socket连接
- (void)disConnect;         //socket断开


- (void)playMusic;          //电视播放音乐
- (void)startSing;          //开始唱歌
- (void)stopSing;           //停止唱歌

//发送进度
- (void)sendProgress:(CGFloat)value;

@end
