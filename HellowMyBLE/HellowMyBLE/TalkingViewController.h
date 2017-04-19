//
//  TalkingViewController.h
//  HellowMyBLE
//
//  Created by Lai Zih Ci on 2017/2/9.
//  Copyright © 2017年 ZihCi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface TalkingViewController : UIViewController

@property (nonatomic,strong) CBPeripheral *targetPeripheral;
@property (nonatomic, strong) CBCharacteristic *targetCharacteristic;

@end
