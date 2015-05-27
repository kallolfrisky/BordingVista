//
//  ProductsViewController.m
//  BV Shop
//
//  Created by Najmul Hasan on 5/26/15.
//  Copyright (c) 2015 BordingVista. All rights reserved.
//

#import "ProductsViewController.h"
#import "CartViewController.h"

@interface ProductsViewController (){

    NSMutableDictionary *pickedProduct;

    int totalProduct;
    float totalValue;
}

@end

@implementation ProductsViewController

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    totalProduct = 0;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    NSString *cartFilePath = [DOC_FOLDER_PATH stringByAppendingPathComponent:PICKED_PRODUCT];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cartFilePath]) {
        
        pickedProduct = [[NSMutableDictionary alloc] initWithContentsOfFile:cartFilePath];
    }else{
        pickedProduct = [[NSMutableDictionary alloc] init];
    }
    
    totalProduct = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"TotalProduct"];
    totalValue = [[NSUserDefaults standardUserDefaults] floatForKey:@"TotalValue"];
    
    if (totalProduct>0)[self updateCartBadgeInfo];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [self savePickedProductInfo];
    
    [super viewWillDisappear:animated];
}

- (void)savePickedProductInfo{

    NSString *cartFilePath = [DOC_FOLDER_PATH stringByAppendingPathComponent:PICKED_PRODUCT];
    [pickedProduct writeToFile:cartFilePath atomically:YES];
    
    [[NSUserDefaults standardUserDefaults] setInteger:totalProduct forKey:@"TotalProduct"];
    [[NSUserDefaults standardUserDefaults] setFloat:totalValue forKey:@"TotalValue"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    NSLog(@"product: %@",product);
    
    //Make a mutant copy of real product
    NSMutableDictionary *mutantProduct;
   
    //Check whether poduct added before
    NSArray *collections = [pickedProduct allKeys];
    NSString *keyID = [NSString stringWithFormat:@"%@",product[@"Id"]];
    
    if ([collections containsObject:keyID]) {
        
        mutantProduct = pickedProduct [keyID];
        
        int count = [mutantProduct [@"count"] intValue];
        count += 1; //Make an increment
        mutantProduct [@"count"] = [NSString stringWithFormat:@"%d",count]; //Reassign item number
        
    }else {
        
        mutantProduct = [product mutableCopy];
        mutantProduct [@"count"] = @"1";
    }
    
    //Add to cart
    [pickedProduct setObject:mutantProduct forKey:keyID];
    totalProduct += 1;
    totalValue += [mutantProduct[@"Price"] floatValue];
    
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
