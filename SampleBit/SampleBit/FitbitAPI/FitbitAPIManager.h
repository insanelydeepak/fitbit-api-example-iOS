//
//  FitbitAPIManager.h
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <Reachability/Reachability.h>
#import <UIKit/UIKit.h>
#import "FitbitAuthHandler.h"
@interface FitbitAPIManager : NSObject
+ (instancetype)sharedManager;

-(void)requestGET:(NSString *)strURL Token:(NSString *)token success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure;
@end
