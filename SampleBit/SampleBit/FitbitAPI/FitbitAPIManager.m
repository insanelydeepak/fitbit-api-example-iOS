//
//  FitbitAPIManager.m
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import "FitbitAPIManager.h"

@implementation FitbitAPIManager {
    NSURLSession *session;
}
+ (instancetype)sharedManager {
    static FitbitAPIManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[FitbitAPIManager alloc] init];
    });
    
    return _sharedManager;
}

-(void)requestGET:(NSString *)strURL Token:(NSString *)token success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure {
    
    BOOL isNetworkAvailable = [self checkNetConnection];
    
    if (!isNetworkAvailable) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Info!" message:@"Please check your internet connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [manager GET:strURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if([responseObject isKindOfClass:[NSDictionary class]]) {
                if(success) {
                    success(responseObject);
                }
            }
            else {
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                if(success) {
                    success(response);
                }
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(failure) {
                failure(error);
            }
            
        }];
    }
}

//-----------------------------------------------------
//                 Method : Reachability
//-----------------------------------------------------

-(BOOL)checkNetConnection
{
    Reachability * reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus] ;
    
    if(internetStatus == NotReachable)
    {
        NSLog(@"Network is not reachable");
        return NO;
    }
    else {
        // NSLog(@"Network is reachable");
        return YES;
    }
}
//-----------------------------------------------------
//-----------------------------------------------------

@end
