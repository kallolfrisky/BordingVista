//
//  ConnectionManager.m
//  ReferralHive
//
//  Created by Najmul Hasan on 10/9/13.
//  Copyright (c) 2013 Najmul Hasan. All rights reserved.
//

#import "ConnectionManager.h"
#import "InternetConnection.h"
#import "AFNetworking.h"

@implementation ConnectionManager

+ (ConnectionManager*)sharedInstance {
    static dispatch_once_t once;
    static ConnectionManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[ConnectionManager alloc] initWithDelegate:nil]; });
    return sharedInstance;
}

- (id)initWithDelegate:(id<ConnectionManagerDelegate>)myDelegate
{
    self = [super init];
    if (self) {
        
        self.delegate = myDelegate;
    }

	return self;
}

- (void)getMyBadgeInfo{

}

- (void)getServerDataForPost:(NSMutableDictionary*)postDict withUrl:(NSString*)urlString{
    
    InternetConnection *internetConnection = [[InternetConnection alloc] init];
	if (![internetConnection startConnectionChecking]) {
        [SVProgressHUD dismiss];
        return;
    }
    
    NSURL   *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,urlString]];
    
    NSLog(@"Url_String:%@",[NSString stringWithFormat:@"%@%@",BASE_URL,urlString]);
    NSLog(@"url:%@",urlString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    if (postDict) {
        NSError *error;
        NSData *postdata = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postdata length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: postdata];
    }
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [connection start];
    [SVProgressHUD showProgress:-1 status:@"Please Wait" maskType:SVProgressHUDMaskTypeGradient];
}

-(void)getAsyncServerDataForPost:(NSMutableDictionary*)postDict withUrl:(NSString*)urlString{
    
    InternetConnection *internetConnection = [[InternetConnection alloc] init];
	if (![internetConnection startConnectionChecking]) {
        [SVProgressHUD dismiss];
        return;
    }
    
    NSURL   *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,urlString]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (postDict) {
        NSError *error;
        NSData *postdata = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postdata length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: postdata];
    }

    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        
                                                        NSLog(@"response:%@",response);
                                                        NSLog(@"JSON:%@",JSON);
//                                                        if ([JSON[@"result"] count]) {
//                                                            [self actionUpdateBadges:JSON[@"result"]];
                                                            [self.delegate didCompletedFetchJSON:JSON];
//                                                        }
                                                        
                                                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"error:%@",error);
                                                    }];
    
    
    [operation start];
}

- (void)JSONRequestWithPost:(NSMutableDictionary*)postDict
                    withUrl:(NSString*)urlString
                    success:(void (^)(NSDictionary* JSON))success
                    failure:(void (^)(NSError *error, NSDictionary* JSON))failure
{
    
    InternetConnection *internetConnection = [[InternetConnection alloc] init];
	if (![internetConnection startConnectionChecking]) {
        [SVProgressHUD dismiss];
        return;
    }
    
    NSURL   *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,urlString]];
    NSLog(@"Request Url:%@",url.absoluteString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (postDict) {
        NSError *error;
        NSData *postdata = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:&error];
        
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postdata length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: postdata];
    }
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        
                                                        if (success) {
                                                            success((NSDictionary*)JSON);
                                                        }
                                                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        if (failure) {
                                                            failure(error, (NSDictionary*)JSON);
                                                        }
                                                    }];
    
    
    [operation start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.fetchedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
    [self.fetchedData appendData:theData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [SVProgressHUD dismiss];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"Fetch Value: %@",[[NSString alloc] initWithData:self.fetchedData encoding:NSUTF8StringEncoding]);
    [self.delegate didCompletedFetchData:self.fetchedData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
    NSLog(@"didFailWithError= %@",error.description);
}

@end
