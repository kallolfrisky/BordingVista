//
//  ProductsViewController.m
//  BV Shop
//
//  Created by Najmul Hasan on 5/26/15.
//  Copyright (c) 2015 BordingVista. All rights reserved.
//

#import "ProductsViewController.h"
#import "CartViewController.h"
#import "PickedProduct.h"
#import "AppDelegate.h"

@interface ProductsViewController (){

    int totalProduct;
    float totalValue;
}

@end

@implementation ProductsViewController

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    totalProduct = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"TotalProduct"];
    totalValue = [[NSUserDefaults standardUserDefaults] floatForKey:@"TotalValue"];
    
    if (totalProduct>0)[self updateCartBadgeInfo];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return _products.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ProductCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *product = _products[indexPath.row];

    cell.textLabel.text = product [@"Text"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@   Price: %@",product[@"Text2"], product[@"Price"]];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addBtn addTarget:self action:@selector(actionAddProduct:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.accessoryView = addBtn;
    
    return cell;
}

- (void)actionAddProduct:(id)sender{

    UITableViewCell *cell = [self getSuperViewCell:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSDictionary *product = _products[indexPath.row];
    NSString *product_id = [NSString stringWithFormat:@"%@",product[@"Id"]];
    NSLog(@"product: %@",product);
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PickedProduct" inManagedObjectContext:_managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"product_id = %@", product_id]];
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];

    PickedProduct* pickedProduct;
    if (results.count) {
        
        pickedProduct = [results objectAtIndex:0];
        pickedProduct.count = [NSNumber numberWithInt:[pickedProduct.count intValue] + 1];
        
    }else {
        
        pickedProduct = [NSEntityDescription insertNewObjectForEntityForName:@"PickedProduct" inManagedObjectContext:_managedObjectContext];
        
        pickedProduct.count = [NSNumber numberWithInt:1];
        pickedProduct.product_id = [NSString stringWithFormat:@"%@",product[@"Id"]];
        pickedProduct.text = product[@"Text"];
        pickedProduct.text2 = product[@"Text2"];
        pickedProduct.price = [NSNumber numberWithDouble:[product[@"Price"] doubleValue]];
        pickedProduct.group_Id = [NSString stringWithFormat:@"%@",product[@"Group_Id"]];
    }
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    totalProduct += 1;
    totalValue += [product[@"Price"] floatValue];
    
    [[NSUserDefaults standardUserDefaults] setInteger:totalProduct forKey:@"TotalProduct"];
    [[NSUserDefaults standardUserDefaults] setFloat:totalValue forKey:@"TotalValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SVProgressHUD showSuccessWithStatus:@"Added to Cart"];
    
    //Update cart tab info
    [self updateCartBadgeInfo];
}

- (void)updateCartBadgeInfo{

    UITabBarItem *cartTab = [self.tabBarController.tabBar.items objectAtIndex:1];
    [cartTab setBadgeValue:[NSString stringWithFormat:@"%d",totalProduct]];
    [cartTab setTitle:[NSString stringWithFormat:@"%0.2f DKK",totalValue]];
}

- (UITableViewCell*)getSuperViewCell:(id)sender{
    
    UITableViewCell *feedCell = nil;
    feedCell = (UITableViewCell*)[sender superview];
    if ([feedCell isKindOfClass:[UITableViewCell class]]) {
        return feedCell;
    }else{
        return [self getSuperViewCell:feedCell];
    }
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
