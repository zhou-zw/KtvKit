//
//  TalkManager.m
//  GCDAsyncSocketDemo
//
//  Created by aipu on 2018/4/16.
//  Copyright © 2018年 XuningZhai All rights reserved.
//

#import "TalkManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AACEncoder.h"
#import "TMAudioPCMPlayer.h"
#import "TMAVConfig.h"
#import "YSTAudioUnit.h"
#import "BBAudioHardEncoder.h"
#import "BBAudioConfig.h"
//#import <YSTLanSDK/YSTSingletonSocket.h>

@interface TalkManager ()<AACSendDelegate,AudioUnitDelegate>
//@property (nonatomic,retain) YSTSingletonSocket *socket;
@property (nonatomic, strong) AACEncoder *aac;
@property(nonatomic, strong) TMAudioPCMPlayer *pcmPalyer;
@property(nonatomic, strong) BBAudioHardEncoder *encoder;
@end

@implementation TalkManager

+ (instancetype)manager {
    return [[[self class] alloc] init];
}

- (instancetype)init {
    if ( self = [super init]) {
        [self initEncoder];
    }
    return self;
}

- (void)initEncoder {
    self.aac = [[AACEncoder alloc] init];
    self.aac.delegate = self;

    //pcm播放器
    _pcmPalyer = [[TMAudioPCMPlayer alloc] initWithConfig:[TMAudioConfig defaultConifg]];
}

- (void)playMusic {
    NSString *head = @"START_PLAY";
//    [self.socket sendMessage:head];
}

- (void)startSing {
//    self.socket.socketPort = 12001;
//    [self.socket socketConHostPrivate:YES];
//    NSString *head = @"RECORD_MSG";
//    [self.socket sendMessage:head];
    
    if (!ystAudio) {
        ystAudio = [[YSTAudioUnit alloc] init];
    }
    ystAudio.delegate = self;
    [ystAudio start];
}

- (void)stopSing {
    ystAudio.delegate = nil;
    [ystAudio stop];
}

- (void)sendProgress:(CGFloat)value {
    NSString *time = [NSString stringWithFormat:@"%f",(float)value];
    NSDictionary *dic = @{@"pos":@([time intValue]*1000)};
    
    NSString *pos = [self DataTOjsonString:dic];
//    [self.socket sendMessage:[NSString stringWithFormat:@"START_PLAY%@",pos]];
}

//dic转string
-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (void)connectSocket {
    [self connectServer:self.ip port:self.port];
}

- (void)disConnect {
//    [self.socket DisconnectSocket];
//    self.socket = nil;
}

- (void)connectServer:(NSString *)hostIP port:(int)hostPort {
//    _socket = [YSTSingletonSocket sharedInstance];
//    _socket.delegate = self;
//    _socket.socketHost = hostIP;
//    _socket.socketPort = hostPort;
//    [_socket socketConHost];
}

/*TCP连接成功*/
- (void)singletonDidConnectSucess:(NSString *)host {
    NSLog(@"connectSuccess");
    if ([self.delegate respondsToSelector:@selector(connectState:)]) {
        [self.delegate connectState:YES];
    }
}
/*TCP断开连接*/
- (void)singletonDidDisconnect:(NSString *)host {
    NSLog(@"disconnect");
    if ([self.delegate respondsToSelector:@selector(connectState:)]) {
        [self.delegate connectState:NO];
    }
}

/*得到数据消息*/
- (void)singletonDidReadTCPData:(NSData *)data {
    
}

#pragma mark - AudioUnitDelegate NSData
- (void)audioUnitPcm:(NSData *)data {
    [_pcmPalyer playPCMData:data];
//    [self.socket sendMessageData:data];
}

#pragma mark - AudioUnitDelegate AudioBufferList
- (void)audioUnitBuffer:(AudioBufferList *)bufferList {
//    self.encoder = [[BBAudioHardEncoder alloc] init];
//    self.encoder.config = [BBAudioConfig defaultConfig];
//    [self.encoder encodeWithBufferList:*bufferList completianBlock:^(NSData *encodedData, NSError *error) {
//        [self.socket sendMessage:encodedData];
//    }];
}

#pragma mark - AACSendDelegate AACData
- (void)sendData:(NSMutableData *)data {
//    [_pcmPalyer playPCMData:data];
//    [self.socket writeData:data withTimeout:-1 tag:0];
}

@end
