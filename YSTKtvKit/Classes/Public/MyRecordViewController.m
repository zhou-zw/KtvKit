//
//  MyRecordViewController.m
//  YSTKtvKit
//
//  Created by 周朕威 on 2018/6/19.
//

#import "MyRecordViewController.h"
#import "MyRecord.h"
#import "SingTool.h"
#import <AVFoundation/AVFoundation.h>

@interface MyRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *recordArray;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@end

@implementation MyRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MyRecord shareInstance].recordArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[SingTool alloc].directory error:nil];
    
    self.recordArray = [NSMutableArray arrayWithArray:[MyRecord shareInstance].recordArray];
    
    [self.recordArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[self.recordArray[idx] description] containsString:@".aac"]) {
            [self.recordArray removeObjectAtIndex:idx];
        }
    }];
    
    _table = [[UITableView alloc] init];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundColor = [UIColor clearColor];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:_table];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recordArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"MyRecordCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [self.recordArray[indexPath.row] description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = [self.recordArray[indexPath.row] description];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:[[SingTool alloc].directory stringByAppendingPathComponent:name]];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc]initWithData:data error:&error];
    [self.audioPlayer play];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *name = [self.recordArray[indexPath.row] description];
        
        [[NSFileManager defaultManager] removeItemAtPath:[[SingTool alloc].directory stringByAppendingPathComponent:name] error:nil];
        [self.recordArray removeObjectAtIndex:indexPath.row];
        
        [self.table reloadData];
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
