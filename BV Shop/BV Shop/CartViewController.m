//
//  CartViewController.m
//  BV Shop
//
//  Created by Najmul Hasan on 5/25/15.
//  Copyright (c) 2015 BordingVista. All rights reserved.
//

#import "CartViewController.h"
#import "CartCell.h"

@interface CartViewController ()

@end

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    //Fetch previously saved data if any
    NSString *cartFilePath = [DOC_FOLDER_PATH stringByAppendingPathComponent:PICKED_PRODUCT];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cartFilePath]) {
        
        _pickedProduct = [[NSMutableDictionary alloc] initWithContentsOfFile:cartFilePath];
        [self.myTableView reloadData];
    }
    
    float totalValue = [[NSUserDefaults standardUserDefaults] floatForKey:@"TotalValue"];
    NSString *valString = [NSString stringWithFormat:@"%f",totalValue];
    
    _lblTotalDecimalSum.text = [NSString stringWithFormat:@"%d",(int)totalValue];
    _lblTotalPrecisionSum.text = [[[valString componentsSeparatedByString:@"."] lastObject] substringToIndex:2];
}

- (IBAction)actionCheckOut:(id)sender{

    NSString *cartFilePath = [DOC_FOLDER_PATH stringByAppendingPathComponent:PICKED_PRODUCT];
    [[NSFileManager defaultManager] removeItemAtPath:cartFilePath error:nil];
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"TotalProduct"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.0 forKey:@"TotalValue"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SVProgressHUD showSuccessWithStatus:@"Checked Out Successfully, You will get delivered soon."];
    
    //Update badge info
    UITabBarItem *cartTab = [self.tabBarController.tabBar.items objectAtIndex:1];
    [cartTab setBadgeValue:nil];
    [cartTab setTitle:@"0.0f DKK"];
    
    //Update cart
    
    _lblTotalDecimalSum.text = @"00";
    _lblTotalPrecisionSum.text = @"00";
    [_pickedProduct removeAllObjects];
    [self.myTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return [_pickedProduct.allKeys count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CartCell";
    CartCell *cell = (CartCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        
        cell = [[CartCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:CellIdentifier];
    }
    
    NSString *anItemKey = _pickedProduct.allKeys[indexPath.row];
    NSDictionary *anItem = _pickedProduct [anItemKey];
    
    cell.lblTitle.text = [NSString stringWithFormat:@"%@ %@",anItem[@"count"],anItem[@"Text"]];
    cell.lblDetail.text = [NSString stringWithFormat:@"a %@",anItem[@"Price"]];
    
    float priceSum = [anItem[@"Price"] floatValue] * [anItem[@"count"] intValue];
    NSString *valString = [NSString stringWithFormat:@"%f",priceSum];
    
    cell.lblDecimalSum.text = [NSString stringWithFormat:@"%d",(int)priceSum];
    cell.lblPrecisionSum.text = [[[valString componentsSeparatedByString:@"."] lastObject] substringToIndex:2];
    
    return cell;
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

@end
