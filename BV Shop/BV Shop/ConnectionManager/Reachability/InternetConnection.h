//
//  InternetConnection.h
//  FrameFun
//
//  Created by Najmul on 11/06/21.
//  Copyright 2011 __SmartMux__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface InternetConnection : NSObject {
    
   
}
- (BOOL) startConnectionChecking;
- (BOOL) checkInternetConnection;
-(void) showAlert;
@end
