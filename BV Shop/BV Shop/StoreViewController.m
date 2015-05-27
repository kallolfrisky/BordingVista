//
//  StoreViewController.m
//  BV Shop
//
//  Created by Najmul Hasan on 5/25/15.
//  Copyright (c) 2015 BordingVista. All rights reserved.
//

#import "StoreViewController.h"
#import "GroupsViewController.h"

@interface StoreViewController (){

    NSArray *departments;
}

@end

@implementation StoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    UITabBarItem *cartTab = [self.tabBarController.tabBar.items objectAtIndex:1];
    
    int products = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"TotalProduct"];
    [cartTab setBadgeValue:(products)?[NSString stringWithFormat:@"%d",products]:nil];
    [cartTab setTitle:[NSString stringWithFormat:@"%0.2f DKK",[[NSUserDefaults standardUserDefaults] floatForKey:@"TotalValue"]]];
    
    [self getProductDepartments];
}

- (void)getProductDepartments{

//    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
//    postDict[@"data"] = dict;
    
    [SVProgressHUD showProgress:-1 status:@"Please Wait" maskType:SVProgressHUDMaskTypeGradient];
    [[ConnectionManager sharedInstance] JSONRequestWithPost:nil
                                                    withUrl:@"departments"
                                                    success:^(NSDictionary *JSON) {
                                                        
                                                        NSLog(@"Success:%@", JSON);
                                                        departments = (NSArray*)JSON;
                                                        [self.tableView reloadData];
                                                        [SVProgressHUD dismiss];
                                                    }
                                                    failure:^(NSError *error, NSDictionary *JSON) {
                                                        [SVProgressHUD showErrorWithStatus:@"Error occured, please try again latter"];
                                                        NSLog(@"failure JSON:%@",JSON);
                                                    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return departments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DeptCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dept = departments[indexPath.row];
    cell.textLabel.text = dept [@"Name"];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSDictionary *dept = departments[indexPath.row];
    
    GroupsViewController *destVC = (GroupsViewController*)[segue destinationViewController];
    destVC.deptID = dept [@"Id"];
}

@end
