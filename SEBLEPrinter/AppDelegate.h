//
//  AppDelegate.h
//  SEBLEPrinter
//
//  Created by Harvey on 16/5/5.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^WXLoginCallBack)(NSString *isOK);
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic , copy)WXLoginCallBack wxLoginCallBack;


@end

