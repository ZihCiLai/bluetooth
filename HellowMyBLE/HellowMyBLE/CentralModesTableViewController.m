//
//  CentralModesTableViewController.m
//  HellowMyBLE
//
//  Created by Lai Zih Ci on 2017/2/9.
//  Copyright © 2017年 ZihCi. All rights reserved.
//

#import "CentralModesTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralItem.h"
#import "TalkingViewController.h"

#define RELOAD_TIME_INTERVAL 1.0
#define TARGET_UUID_PREFIX @"888"
//#define TARGET_UUID_PREFIX @"FFE1"// KentDongle
//#define TARGET_UUID_PREFIX @"DFB1"// Bluno

@interface CentralModesTableViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>
{

    CBCentralManager *manager;
    NSMutableDictionary *allItems;
    NSDate *lastTableViewReloadDate;
    
    NSMutableString *infoString;
    NSMutableArray *restServices;
    
    BOOL shouldStartTalking;
    CBPeripheral *talkingPeripheral;
    CBCharacteristic *talkingCharacteristic;
}

@end

@implementation CentralModesTableViewController
//-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    allItems = [NSMutableDictionary new];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Handle clean-up after return from talkingViewController.
    if(talkingPeripheral != nil) {
        [manager cancelPeripheralConnection:talkingPeripheral];
        talkingPeripheral = nil;
        talkingCharacteristic = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
return allItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSArray *allKeys = allItems.allKeys;
    NSString *uuidKey = allKeys[indexPath.row];
    PeripheralItem *item = allItems[uuidKey];
    
    NSString *line1String = [NSString stringWithFormat:@"%@ RSSI: %ld", item.peripheral.name, item.rssi];
    NSString *line2String = [NSString stringWithFormat:@"Last seen: %.2f secondsago.",[[NSDate date] timeIntervalSinceDate:item.seenDate ]];
    cell.textLabel.text = line1String;
    cell.detailTextLabel.text = line2String;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    shouldStartTalking = true;
    [self connectWithIndexPath:indexPath];
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    shouldStartTalking = false;
    [self connectWithIndexPath:indexPath];
}

- (void) connectWithIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *allKeys = allItems.allKeys;
    NSString *uuidKey = allKeys[indexPath.row];
    PeripheralItem *item = allItems[uuidKey];
    
    [manager connectPeripheral:item.peripheral options:nil];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    TalkingViewController *vc = segue.destinationViewController;
    vc.targetPeripheral = talkingPeripheral;
    vc.targetCharacteristic = talkingCharacteristic;
    
}

- (IBAction)enableScanValueChangd:(id)sender {
    if([sender isOn]) {
        [self startToScan];
    } else {
        [self stopScanning];
    }
}

- (void) startToScan {
   // CBUUID *uuid = [CBUUID UUIDWithString:@"8888"];
    NSArray *services = @[];//@[uuid];
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @(true)};
    [manager scanForPeripheralsWithServices:services options:options];
}

- (void) stopScanning {
    [manager stopScan];
}

- (void) showAlertWithMessage:(NSString*) message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark - CBCentralManagerDelegate Methods
-(void) centralManagerDidUpdateState:(CBCentralManager *)central {
    
    CBManagerState state = central.state;
    
    if(state != CBManagerStatePoweredOn) {
        NSString *message = [NSString stringWithFormat:@"BLE is not ready(error: %ld)", state];
        [self showAlertWithMessage:message];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    PeripheralItem *existItem = allItems[peripheral.identifier.UUIDString];
    if(existItem==nil) {
        NSLog(@"Discovered %@,RSSI: %ld,UUID: %@\n,AdvData: %@", peripheral.name,RSSI.integerValue,peripheral.identifier.UUIDString,advertisementData.description);
    }
    PeripheralItem *newItem = [PeripheralItem new];
    newItem.peripheral = peripheral;
    newItem.rssi = RSSI.integerValue;
    newItem.seenDate = [NSDate date];
    [allItems setObject:newItem forKey:peripheral.identifier.UUIDString];
    
    // Check if we should reload tableview or not.
    NSDate *now = [NSDate date];
    if(existItem == nil || [now timeIntervalSinceDate:lastTableViewReloadDate] > RELOAD_TIME_INTERVAL) {
        lastTableViewReloadDate = now;
        [self.tableView reloadData];
    }
}

-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Peripheral connected: %@", peripheral.name);
    [self stopScanning];
    
    //Start to discover services
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
}
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSString *message = [NSString stringWithFormat:@"Fail to connect: %@", error];
    [self showAlertWithMessage:message];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self startToScan];
}
#pragma mark -CBPeripheralDelegate Methods
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    if(error) {
        NSLog(@"didDiscoverServices fail: %@",error);
        [manager cancelPeripheralConnection:peripheral];
        return;
    }
    // Dsiscover characteristics of each service, one by one.
    restServices = [NSMutableArray arrayWithArray:peripheral.services];
    
    //Discover the first one
    CBService *targerService = restServices.firstObject;
    [peripheral discoverCharacteristics:nil forService:targerService];
    [restServices removeObjectAtIndex:0];
    
    // Prepare infoString
    infoString = [NSMutableString new];
    
    // Prepare for peripheral
    [infoString appendFormat:@"*** Peripheral: %@ (%ld services)\n", peripheral.name,peripheral.services.count];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
 
    if(error) {
        NSLog(@"didDiscoverServices fail: %@",error);
        [manager cancelPeripheralConnection:peripheral];
        return;
    }
    
    // PRepare for service part
    [infoString appendFormat:@"** Service: %@ (%ld characteristics)\n", service.UUID.UUIDString, service.characteristics.count];
    
    // Prepare for characteristic part
    for (CBCharacteristic *tmp in service.characteristics) {
        [infoString appendFormat:@"* Characteristic: %@\n", tmp.UUID.UUIDString];
        
        // Check if it is the one that is matched with target UUID.
        if (shouldStartTalking && [tmp.UUID.UUIDString hasPrefix:TARGET_UUID_PREFIX]) {
            NSLog(@"8888888888888888");
            talkingPeripheral = peripheral;
            talkingCharacteristic = tmp;
            
            [self performSegueWithIdentifier:@"goTalk" sender:nil];
            return;
        }
    }
    
    // Move to next service?
    if (restServices.count == 0) {
        [self showAlertWithMessage:infoString];
        [manager cancelPeripheralConnection:peripheral];
        
    } else {
        CBService *targerService = restServices.firstObject;
        [peripheral discoverCharacteristics:nil forService:targerService];
        [restServices removeObjectAtIndex:0];
    }
}

@end
