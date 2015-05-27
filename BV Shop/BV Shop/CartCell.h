//
//  CartCell.h
//  BV Shop
//
//  Created by Najmul Hasan on 5/27/15.
//  Copyright (c) 2015 BordingVista. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblDetail;

@property (nonatomic, weak) IBOutlet UILabel *lblDecimalSum;
@property (nonatomic, weak) IBOutlet UILabel *lblPrecisionSum;

@end
