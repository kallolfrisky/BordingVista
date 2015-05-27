//
//  CartViewController.m
//  BV Shop
//
//  Created by Najmul Hasan on 5/25/15.
//  Copyright (c) 2015 BordingVista. All rights reserved.
//

#import "CartViewController.h"
#import "PickedProduct.h"
#import "CartCell.h"
#import "AppDelegate.h"

@interface CartViewController ()

@end

@implementation CartViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //Fetch previously saved data if any
    [self fetchSavedData];
}

- (void)fetchSavedData{

    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"PickedProduct" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSError *error;
    _pickedProducts = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    //Get badge info for cart
    float totalValue = [[NSUserDefaults standardUserDefaults] floatForKey:@"TotalValue"];
    NSString *valString = [NSString stringWithFormat:@"%f",totalValue];
    
    _lblTotalDecimalSum.text = [NSString stringWithFormat:@"%d",(int)totalValue];
    _lblTotalPrecisionSum.text = [[[valString componentsSeparatedByString:@"."] lastObject] substringToIndex:2];
    
    [self.myTableView reloadData];
}

- (IBAction)actionCheckOut:(id)sender{

    //Remove all records
    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:@"PickedProduct" inManagedObjectContext:_managedObjectContext]];
    [allCars setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * products = [_managedObjectContext executeFetchRequest:allCars error:&error];
    
    //error handling goes here
    for (PickedProduct *product in products) {
        [_managedObjectContext deleteObject:product];
    }
    [_managedObjectContext save:&error];
    
    
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
    [_pickedProducts removeAllObjects];
    [self.myTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return [_pickedProducts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CartCell";
    CartCell *cell = (CartCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        
        cell = [[CartCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:CellIdentifier];
    }
    
    PickedProduct *anItem = _pickedProducts[indexPath.row];
    
    cell.lblTitle.text = [NSString stringWithFormat:@"%d %@",[anItem.count intValue],anItem.text];
    cell.lblDetail.text = [NSString stringWithFormat:@"a %@",anItem.price];
    
    float priceSum = (float)([anItem.price doubleValue] * [anItem.count intValue]);
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
