//
//  FitbitAuthHandlerProtocol.h
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>
//******* Authorization Errors for code 401 ************
#define fInvalid_Client    @"invalid_client"
#define fExpied_Token      @"expired_token"
#define fInvalid_Token     @"invalid_token"
#define fInvalid_Request   @"invalid_request"
#define FitbitNotification @"FitbitAthozired"
@interface FitbitAuthHandler : NSObject <SFSafariViewControllerDelegate>
-(instancetype)init:(id )delegate_;

-(void)login:(UIViewController*)viewController;
-(void)showAlert :(NSString *)message;
-(void)revokeAccessToken:(NSString *)token;
+(NSString *)getToken;
+(void)clearToken;

@end
