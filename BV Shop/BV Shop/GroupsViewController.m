//
//  GroupsViewController.m
//  BV Shop
//
//  Created by Najmul Hasan on 5/26/15.
//  Copyright (c) 2015 BordingVista. All rights reserved.
//

#import "GroupsViewController.h"
#import "ProductsViewController.h"

@interface GroupsViewController (){

    NSArray *groups;
    NSArray *products;
}

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self getProductGroups];
}

- (void)getProductGroups{
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    postDict[@"departmentId"] = self.deptID;
    
    [SVProgressHUD showProgress:-1 status:@"Please Wait" maskType:SVProgressHUDMaskTypeGradient];
    [[ConnectionManager sharedInstance] JSONRequestWithPost:postDict
                                                    withUrl:@"Groups"
                                                    success:^(NSDictionary *JSON) {
                                                        
                                                        [SVProgressHUD dismiss];
                                                        NSLog(@"Success:%@", JSON);
                                                        groups = (NSArray*)JSON;
                                                        [self.tableView reloadData];
                                                    }
                                                    failure:^(NSError *error, NSDictionary *JSON) {
                                                        [SVProgressHUD showErrorWithStatus:@"Error occured, please try again latter"];
                                                        NSLog(@"failure JSON:%@",JSON);
                                                    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return groups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"GroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *group = groups[indexPath.row];
    cell.textLabel.text = group [@"Name"];
    
    return cell;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{

    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSDictionary *group = groups[indexPath.row];
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    postDict[@"groupId"] = group [@"Id"];
    
    [SVProgressHUD showProgress:-1 status:@"Please Wait" maskType:SVProgressHUDMaskTypeGradient];
    [[ConnectionManager sharedInstance] JSONRequestWithPost:postDict
                                                    withUrl:@"Products"
                                                    success:^(NSDictionary *JSON) {
                                                    
                                                        products = [NSArray arrayWithArray:(NSArray *)JSON];
                                                        if (!products.count){
                                                            [SVProgressHUD showErrorWithStatus:@"Sorry product of this group is out of stock"];
                                                        }else{

                                                            [SVProgressHUD dismiss];
                                                            
                                                            //Invoke injection to perform the specific segue
                                                            [self performSegueWithIdentifier:identifier sender: sender];
                                                        }
                                                    }
                                                    failure:^(NSError *error, NSDictionary *JSON) {
                                                        [SVProgressHUD showErrorWithStatus:@"Error occured, please try again latter"];
                                                        NSLog(@"failure JSON:%@",JSON);
                                                    }];
    //Revoke conventional ways
    return NO;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    ProductsViewController *productVC = (ProductsViewController*)[segue destinationViewController];
    productVC.products = products;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
