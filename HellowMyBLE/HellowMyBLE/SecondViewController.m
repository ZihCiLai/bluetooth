//
//  SecondViewController.m
//  HellowMyBLE
//
//  Created by Lai Zih Ci on 2017/2/9.
//  Copyright © 2017年 ZihCi. All rights reserved.
//

#import "SecondViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID @"8888"
#define CHARACTERISTIC_UUID @"8888"
#define CHATROOM_NAME @"＝子褀＝"

@interface SecondViewController () <CBPeripheralManagerDelegate>
{
    CBPeripheralManager *manager;
    CBMutableCharacteristic *chatroomCharacteristic;
}
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enableAdvertisingChanged:(id)sender {
    if([sender isOn]) {
        // Check if we should perform preparring.
        if(chatroomCharacteristic == nil) {
                [self prepareToAdvertise];
        }
        
        CBUUID *serviceUUID = [CBUUID UUIDWithString:SERVICE_UUID];
        NSArray *UUIDs = @[serviceUUID]; // Important!
        
        NSDictionary *info = @{CBAdvertisementDataLocalNameKey: CHATROOM_NAME, CBAdvertisementDataServiceUUIDsKey: UUIDs};
        [manager startAdvertising:info];
        
    } else {
        [manager stopAdvertising];
    }
}

-(void) prepareToAdvertise {
    CBUUID *serviceUUID = [CBUUID UUIDWithString:SERVICE_UUID];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    
    CBCharacteristicProperties properties = CBCharacteristicPropertyNotify |
    CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite;//CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify | CBCharacteristicWriteWithoutResponse;
    CBAttributePermissions permissions = CBAttributePermissionsReadable | CBAttributePermissionsWriteable;
    
    chatroomCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:properties value:nil permissions:permissions];
    
    CBMutableService *chatroomService = [[CBMutableService alloc] initWithType:serviceUUID primary:true];
    
    chatroomService.characteristics = @[chatroomCharacteristic];
    
    [manager addService:chatroomService];
}

- (IBAction)sendBtnPressed:(id)sender {
    if(_inputTextField.text.length == 0) {
        return;
    }
    
    [_inputTextField resignFirstResponder];
    
    NSString *message = [NSString stringWithFormat:@"[%@] %@\n",CHATROOM_NAME, _inputTextField.text];
    [self sendTextWithMessage:message withCentral:nil];
    [self addToLogWithInfo:message];
}

- (void) showAlertWithMessage:(NSString*) message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:true completion:nil];
}

-(void) addToLogWithInfo:(NSString *) info {
    _logTextView.text = [NSString stringWithFormat:@"%@%@", info, _logTextView.text];
}

-(void) sendTextWithMessage:(NSString *)message withCentral:(CBCentral*)central {
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *centrals = (central == nil ? nil: @[central]);
    
    [manager updateValue:data forCharacteristic:chatroomCharacteristic onSubscribedCentrals:centrals];
}

#pragma  mark - CBPeripheralManagerDelegate Methods
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    CBManagerState state = peripheral.state;
    if(state != CBManagerStatePoweredOn) {
        NSString *message = [NSString stringWithFormat:@"BLE is not ready(error: %ld)", state];
        [self showAlertWithMessage:message];
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"one");
    NSString *info = [NSString stringWithFormat:@"* Central subscribed. UUID: %@,max update length: %ld.\n",central.identifier.UUIDString,central.maximumUpdateValueLength];
    [self addToLogWithInfo:info];
    
    // Say Hello to Central
    NSString *hello = [NSString stringWithFormat:@"[%@] Hi,I am %@.(Total: %ld)\n", CHATROOM_NAME, CHATROOM_NAME, chatroomCharacteristic.subscribedCentrals.count];
    [self sendTextWithMessage:hello withCentral:central];
    
    [self addToLogWithInfo:hello];
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"two");
    NSString *inf = [NSString stringWithFormat:@"* Central unsubscribed. UUID:%@.\n", central.identifier.UUIDString];
    [self addToLogWithInfo:inf];
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    NSLog(@"three");
    for(CBATTRequest *tmp in requests) {
        NSString *incomingMessage = [[NSString alloc] initWithData:tmp.value encoding:NSUTF8StringEncoding];
        if(incomingMessage != nil) {
            [self sendTextWithMessage:incomingMessage withCentral:nil];
            [self addToLogWithInfo:incomingMessage];
        }
        // Important;
        [peripheral respondToRequest:tmp withResult:CBATTErrorSuccess];
    }
}

@end
