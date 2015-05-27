//
//  CartViewController.h
//  BV Shop
//
//  Created by Najmul Hasan on 5/25/15.
//  Copyright (c) 2015 BordingVista. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *myTableView;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalDecimalSum;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalPrecisionSum;

@property (nonatomic, retain) NSMutableArray *pickedProducts;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
