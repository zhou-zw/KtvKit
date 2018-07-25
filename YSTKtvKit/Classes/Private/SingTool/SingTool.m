//
//  SingTool.m
//  YSTKtvKit
//
//  Created by 周朕威 on 2018/6/19.
//
#define OUTPUTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

#import "SingTool.h"
#import <AVFoundation/AVFoundation.h>
#import "AVMediaUtil.h"
#import "MyRecord.h"

@interface SingTool()<AVAudioRecorderDelegate>
@property (nonatomic,strong) AVAudioRecorder *recoder;

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

@property (nonatomic,strong) NSString *filePath;

@end

@implementation SingTool

- (void)startSing {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [self Recorder];
    [self.recoder record];
}

- (void)stopSing {
    [self.recoder stop];
}

- (void)Recorder
{
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    NSDictionary *audioDic = [self audioRecordingSettings];
    NSLog(@"%@\r audioDic=%@",url,audioDic);
    self.recoder = [[AVAudioRecorder alloc]initWithURL:url settings:audioDic error:&error];
    self.recoder.delegate = self;
    self.recoder.meteringEnabled = YES;
}

- (NSString *)filePath
{
    if (!_filePath)
    {
        _filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _filePath = [_filePath stringByAppendingPathComponent:@"user"];
        NSFileManager *manage = [NSFileManager defaultManager];
        if ([manage createDirectoryAtPath:_filePath withIntermediateDirectories:YES attributes:nil error:nil])
        {
            _filePath = [_filePath stringByAppendingPathComponent:@"testAudio.aac"];
        }
    }
    
    return _filePath;
}

- (NSString *)directory {
    if (!_filePath)
    {
        _filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _filePath = [_filePath stringByAppendingPathComponent:@"user"];
    }
    
    return _filePath;
}

- (NSDictionary *)audioRecordingSettings{
    
    //设定录制信息
    //录音时所必需的参数设置
    NSDictionary *settings = @{
                               /*这个方法如果设置,一点要和上面的文件路径中的格式一致,否则会有问题
                                */
                               AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                               AVSampleRateKey:@44100,
                               AVNumberOfChannelsKey:@1,
                               AVEncoderAudioQualityKey:@(AVAudioQualityMin),
                               };
    
    return settings;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag)
    {
        NSURL *url = recorder.url;
        NSError *error;
        
        //提取视频中音频，准备合并
        [self getMP3File];
        NSLog(@"%@",url);
    }
    
}

- (void)getMP3File {
    __block NSString *transFileName;
    NSURL *URL = [KtvBundle URLForResource:@"laonanhai" withExtension:@"mp4"];
    [AVMediaUtil changeVideoToAudioWithReadPath:URL name:@"laonanhai" completionHandler:^(successType success, NSString *fileName) {
        if (success == mediaStatus)
        {
            transFileName = fileName;
            NSString *filePath = [OUTPUTPATH stringByAppendingPathComponent:transFileName];
            [self audioAndAudio:filePath];
        }
    }];
}

- (void)audioAndAudio:(NSString *)filePath {
    AVURLAsset *audioAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:self.filePath]];
    
    AVMutableComposition *compostion = [AVMutableComposition composition];
    AVMutableCompositionTrack *video = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [video insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    AVMutableCompositionTrack *audio = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:[audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    
    /*
     批量插入音轨到文件最后
     CMTimeRange range = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
     [video insertTimeRanges:@[[NSValue valueWithCMTimeRange:range],[NSValue valueWithCMTimeRange:range]] ofTracks:@[[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject,[audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject] atTime:kCMTimeZero error:nil];
     */
    
    NSDate *date= [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:compostion presetName:AVAssetExportPresetAppleM4A];
    NSString *outPutFilePath = [[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",[dateformatter stringFromDate:date]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPutFilePath error:nil];
    }
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    session.outputFileType = @"com.apple.m4a-audio";
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath])
        {
            NSLog(@"录制成功！");
            //保存录音文件
            [MyRecord shareInstance].recordArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.filePath stringByDeletingLastPathComponent] error:nil];
        }
        else
        {
            NSLog(@"输出错误");
        }
    }];
}

@end
