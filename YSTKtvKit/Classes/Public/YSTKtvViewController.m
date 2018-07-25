//
//  YSTViewController.m
//  YSTKtvKit
//
//  Created by kuqiqi on 06/12/2018.
//  Copyright (c) 2018 kuqiqi. All rights reserved.
//

#import "YSTKtvViewController.h"
#import "TalkManager.h"
//#import <YSTPlayer/YSTPlayer.H>
#import "SingTool.h"
#import "MyRecordViewController.h"
//#import <YSTLanSDK/YSTLanManager.h>
//#import "NSString+Empty.h"

@interface YSTKtvViewController ()<YSTTalkManagerDelegate>
@property (nonatomic,strong)TalkManager *manager;
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UIView *contentView;
//@property(nonatomic,strong) YSTPlayerModel *playerModel;
//@property (nonatomic, strong) YSTVideoPlayer *player;
@property(nonatomic,strong) UIView *playerFatherView;
@property(nonatomic,strong) SingTool *singTool;
//@property(nonatomic,strong) YSTLanManager *lanManager;
@property(nonatomic,assign) BOOL connectState;
@end

@implementation YSTKtvViewController

- (instancetype)init {
    return [super initWithNibName:@"YSTViewController" bundle:KtvBundle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initManager];
    [self setUpUI];
    [self bindViewModel];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)initManager {
    _manager = [TalkManager manager];
    _manager.delegate = self;
    
//    self.lanManager = [YSTLanManager sharedInstance];
//    self.lanManager.delegate = self;
    
    [_connectBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUpUI{
//    if (!self.lanManager.defaultTVHost) {
//        [self.lanManager startToShowLanSDKUI];
//    }
    self.ipTextField.text = @"";
    self.portTextField.text = @"8999";
    [self.contentView addSubview:self.playerFatherView];
    self.playerFatherView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

#pragma mark 播放器控制
/**
 事件绑定
 */
- (void)bindViewModel{
    /**
     拿到播放地址
     */
    NSString *filePath = [KtvBundle pathForResource:@"laonanhai" ofType:@"mp4"];
    
    NSURL *sourceMovieURL = [NSURL fileURLWithPath:filePath];
//    self.playerModel.videoURL = sourceMovieURL;
//    self.player = [YSTVideoPlayer videoPlayerWithView:self.playerFatherView delegate:self playerModel:self.playerModel];
//    self.player.portraitControlView.topImgView.hidden = YES;
//    self.player.portraitControlView.exitFullScreenBtn.hidden = YES;
//    self.player.playerControlView.panRecognizer.enabled = NO;
//    self.player.coverControlView.hidden = YES;
//    [self.player autoPlayTheVideo];
}

#pragma mark - getter
//- (YSTPlayerModel *)playerModel{
//    if (!_playerModel) {
//        _playerModel = [[YSTPlayerModel alloc] init];
//        _playerModel.playerOtherModel.disableRoating = NO;
//    }
//    return _playerModel;
//}

- (UIView *)playerFatherView {
    if (!_playerFatherView) {
        _playerFatherView = [[UIView alloc] init];
    }
    return _playerFatherView;
}

//拖动进度条回调
- (void)progressSliderEndDragSecond:(CGFloat)value progress:(CGFloat)progress {
    [_manager sendProgress:value];
}

- (void)start {
    if (self.ipTextField.text.length<=0 || self.portTextField.text.length<=0) {
        NSLog(@"请输入正确的ip和端口！");
        return;
    }
    _manager.ip = self.ipTextField.text;
    _manager.port = [self.portTextField.text intValue];
    if (self.connectState) {
        [_manager disConnect];
    }else {
        [_manager connectSocket];
    }
}

- (IBAction)playMusic:(UIButton *)sender {
    if (!self.connectState) {
        NSLog(@"请先连接电视！");
        return;
    }
    [_manager playMusic];
}

- (IBAction)startSing:(UIButton *)sender {
    [_manager startSing];
}

- (IBAction)stopSing:(UIButton *)sender {
    [_manager stopSing];
}

- (IBAction)startRecord:(UIButton *)sender {
//    [self.player autoPlayTheVideo];

    self.singTool = [[SingTool alloc] init];
    [self.singTool startSing];
}

- (IBAction)stopRecord:(UIButton *)sender {
//    [self.player stopVideo];

    [self.singTool stopSing];
}

- (IBAction)seeRecord:(UIButton *)sender {
    MyRecordViewController *vc = [[MyRecordViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)getDevice:(UIButton *)sender {
//    [self.lanManager startToShowLanSDKUI];
}

#pragma YSTTalkManagerDelegate
- (void)connectState:(BOOL)state {
    if (state) {
        self.connectState = YES;
        [_connectBtn setTitle:@"已连接，点击断开" forState:UIControlStateNormal];
    }else {
        self.connectState = NO;
        [_connectBtn setTitle:@"已断开，点击连接" forState:UIControlStateNormal];
    }
}

# pragma YSTLanManagerDelegate
- (void)lanSDKUIDidConnectClient:(NSString *)host {
    self.ipTextField.text = host;
    self.manager.ip = self.ipTextField.text;
    self.manager.port = [self.portTextField.text intValue];
    [self.manager connectSocket];
}

//- (void)didReceiveUDPData:(YSTClientModel *)model {
//    
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end

