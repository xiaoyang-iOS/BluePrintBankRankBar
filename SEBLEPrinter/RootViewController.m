//
//  RootViewController.m
//  SEBLEPrinter
//
//  Created by 萧阳 on 2019/5/9.
//  Copyright © 2019 Halley. All rights reserved.
//

#import "RootViewController.h"
#import "SEPrinterManager.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import <AdSupport/AdSupport.h>
@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor orangeColor];
    // Do any additional setup after loading the view.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //一直不变
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //跟随包变
    [self startprint];
    

}
-(void)startprint{
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *hebeiBank=[idfv stringByAppendingFormat:@"[hebeibank]%@",[[NSBundle mainBundle] bundleIdentifier]];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:hebeiBank]) {
        [self dayin];
    }else{
        ViewController *vc=[[ViewController alloc]init];
        vc.printer=[self getPrinter];
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:vc animated:YES completion:^{
            vc.view.backgroundColor=[UIColor colorWithWhite:0.9 alpha:0.1];
        }];
    }
}
-(void)dayin{
    HLPrinter *printer = [self getPrinter];
    
    NSData *mainData = [printer getFinalData];
    [[SEPrinterManager sharedInstance] sendPrintData:mainData completion:^(CBPeripheral *connectPerpheral, BOOL completion, NSString *error) {
        NSLog(@"写入结果：%d:%@",completion,error);
        if (!completion) {
            [SVProgressHUD showErrorWithStatus:error];
            //重新发起初始化 设置NO
            NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            NSString *hebeiBank=[idfv stringByAppendingFormat:@"[hebeibank]%@",[[NSBundle mainBundle] bundleIdentifier]];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:hebeiBank];
            [self startprint];
        }
    }];
}
- (HLPrinter *)getPrinter
{
    HLPrinter *printer = [[HLPrinter alloc] init];
    UIView *myView=[[UIView alloc]init];
    myView.backgroundColor=[UIColor whiteColor];
    myView.frame=CGRectMake(0, 0, 420, 250);
    UIImage *img1=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Print1" ofType:@"pic"]];
    UIImageView *imgV1 = [[UIImageView alloc]initWithImage:img1];
    imgV1.frame=CGRectMake(10, 10, 400, 100);
    [myView addSubview:imgV1];
    UILabel *l=[[UILabel alloc]initWithFrame:CGRectMake(150, 150, 120, 60)];
    l.text=@"K017";
    l.font=[UIFont boldSystemFontOfSize:50];
    l.textAlignment=NSTextAlignmentCenter;
    l.textColor=[UIColor blackColor];
    [myView addSubview:l];
    UIImage *MYimg=[self makeImageWithView:myView withSize:CGSizeMake(420, 250)];
    UIImageWriteToSavedPhotosAlbum(MYimg, nil, nil, nil);
    [printer appendImage:MYimg alignment:HLTextAlignmentCenter maxWidth:368];

    [printer appendText:@"等待人数：15" alignment:HLTextAlignmentLeft];
    [printer appendText:@"网点名称：河北银行股份有限公司张家口支行" alignment:HLTextAlignmentLeft];
    [printer appendText:@"取号时间：2019-04-23 16:23:54" alignment:HLTextAlignmentLeft];
    [printer appendText:@"请您在休息区等候，注意呼号及电视屏幕显示信息，如果过号，请您重新排号。" alignment:HLTextAlignmentLeft];
    UIImage *img2=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Print0" ofType:@"pic"]];
    [printer appendImage:img2 alignment:HLTextAlignmentCenter maxWidth:368];

    return printer;
}
#pragma mark 生成image
- (UIImage *)makeImageWithView:(UIView *)view withSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
