//
//  ViewController.m
//  SEBLEPrinter
//
//  Created by Harvey on 16/5/5.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic)  UITableView *tableView;

@property (strong, nonatomic)   NSArray  *deviceArray;  /**< 蓝牙设备个数 */

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *v1=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    v1.backgroundColor=[UIColor whiteColor];
    UILabel *l=[[UILabel alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 40)];
    l.text=@"请点击您想连接的蓝牙设备";
    l.backgroundColor=[UIColor lightGrayColor];
    [v1 addSubview:l];
  
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(10, 100, [UIScreen mainScreen].bounds.size.width-20, 600) style:UITableViewStylePlain];
    self.tableView.layer.cornerRadius=10;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    SEPrinterManager *_manager = [SEPrinterManager sharedInstance];
    [_manager startScanPerpheralTimeout:10 Success:^(NSArray<CBPeripheral *> *perpherals,BOOL isTimeout) {
        NSLog(@"perpherals:%@",perpherals);
        _deviceArray = perpherals;
        [_tableView reloadData];
    } failure:^(SEScanError error) {
         NSLog(@"error:%ld",(long)error);
    }];
      self.tableView.tableHeaderView=v1;

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"deviceId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    CBPeripheral *peripherral = [self.deviceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"名称:%@",peripherral.name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CBPeripheral *peripheral = [self.deviceArray objectAtIndex:indexPath.row];
    dispatch_queue_t queue =  dispatch_queue_create("连接蓝牙直接打印", NULL);
    dispatch_async(queue, ^{
        [[SEPrinterManager sharedInstance] fullOptionPeripheral:peripheral completion:^(SEOptionStage stage, CBPeripheral *perpheral, NSError *error) {
            if (!error) {
                
                NSLog(@"连接设备成功 不一定是打印机");
            }else
            {
                NSLog(@"111%@",error.userInfo.description);
            }
            if (stage == SEOptionStageSeekCharacteristics) {
                [SVProgressHUD showSuccessWithStatus:@"选择正确的打印机设备"];
                NSData *mainData = [self.printer getFinalData];
                [[SEPrinterManager sharedInstance] sendPrintData:mainData completion:^(CBPeripheral *connectPerpheral, BOOL completion, NSString *error)
                 {
                     if (completion) {
                         NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                         NSString *hebeiBank=[idfv stringByAppendingFormat:@"[hebeibank]%@",[[NSBundle mainBundle] bundleIdentifier]];
                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hebeiBank];
                         NSLog(@"ok");
                     }else if (error)
                     {
                         NSLog(@"error====%@",error);
                     }
                 }];
            }else{
                NSLog(@"stage%ld",stage);
                [SVProgressHUD showErrorWithStatus:@"请重新选择设备"];
            }
        }];
    });

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
