//
//  PickedProduct.h
//  BV Shop
//
//  Created by Najmul Hasan on 5/27/15.
//  Copyright (c) 2015 BordingVista. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PickedProduct : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * product_id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * text2;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * group_Id;

@end
