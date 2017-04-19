//
//  TalkingViewController.m
//  HellowMyBLE
//
//  Created by Lai Zih Ci on 2017/2/9.
//  Copyright © 2017年 ZihCi. All rights reserved.
//

#import "TalkingViewController.h"
#define CENTRAL_NAME @"=子褀="

@interface TalkingViewController () <CBPeripheralDelegate>
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@end

@implementation TalkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _targetPeripheral.delegate = self;
    [_targetPeripheral setNotifyValue:true forCharacteristic:_targetCharacteristic];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_targetPeripheral setNotifyValue:false forCharacteristic:_targetCharacteristic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)sendBtn:(id)sender {
    
    // Do noting if user don't input any text.
    if(_inputTextField.text.length == 0) {
        return;
    }
    NSLog(@"sender text");
    // Dismiss keyboard
    [_inputTextField resignFirstResponder];
    NSString *message = [NSString stringWithFormat:@"[%@] %@\n", CENTRAL_NAME, _inputTextField.text];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [_targetPeripheral writeValue:data forCharacteristic:_targetCharacteristic type:CBCharacteristicWriteWithResponse];
    //[_targetPeripheral writeValue:data forCharacteristic:_targetCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

#pragma mark - CBPeripheralDelegate Methods
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if(error) {
        NSLog(@"didWriteValueForCharacteristic fail: %@", error);
    } else {
        NSLog(@"Write to characteristic success.");
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error) {
        NSLog(@"didUpdateValueForCharacteristic fail: %@",error);
        return;
    }
    
    NSString *message = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Show on UITextView
    if(message.length > 0) {
        _logTextView.text = [NSString stringWithFormat:@"%@%@", message, _logTextView.text];
    }
}

@end
