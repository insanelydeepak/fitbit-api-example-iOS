//
//  FitbitAuthHandlerProtocol.h
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>
#import "Reachability.h"
@protocol FitbitAuthHandlerProtocol <NSObject>
-(void)authorizationDidFinish:(BOOL )success;
@end
@interface FitbitAuthHandler : NSObject <SFSafariViewControllerDelegate>
@property (strong, nonatomic) id <FitbitAuthHandlerProtocol> delegate;

-(instancetype)init:(id )delegate_;
-(void)login:(UIViewController*)viewController;
-(NSString *)getToken;
-(void)clearToken;

@end
