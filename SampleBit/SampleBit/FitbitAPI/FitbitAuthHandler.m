//
//  FitbitAuthHandlerProtocol.m
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import "FitbitAuthHandler.h"

@implementation FitbitAuthHandler
{
    NSString  *clientID;
    NSString  *clientSecret ;
    NSURL     *authUrl ;
    NSURL     *refreshTokenUrl ;
    NSString  *redirectURI  ;
    NSString  *defaultScope ;
    
    NSString *authenticationToken;
    SFSafariViewController  *authorizationVC;
    
 }
-(void)loadVars{
          clientID = @"";
          clientSecret = @"";
          authUrl = [NSURL URLWithString:@"https://www.fitbit.com/oauth2/authorize"];
          refreshTokenUrl = [NSURL URLWithString:@"https://api.fitbit.com/oauth2/token"];
          redirectURI  = @"samplebit://";
          defaultScope = @"sleep+settings+nutrition+activity+social+heartrate+profile+weight+location";
}
-(instancetype)init:(id)delegate_
{
    self = [super init];
    if (self) {
         [self loadVars];
        self.delegate = delegate_;
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"SampleBitLaunchNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            BOOL success;
            NSString *token = [self extractToken:note Key:@"#access_token"];
            
            if (token != nil) {
                //******************** Save Token to NSUserDedaults ******************
                [[NSUserDefaults standardUserDefaults] setObject:token  forKey:@"fitbit_token"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                //********************* *********************** **********************
                
                authenticationToken = token;
                NSLog(@"You have successfully authorized");
                success = true;
            }
            else {
                NSLog(@"There was an error extracting the access token from the authentication response.");
                success = false;
            }
            [authorizationVC dismissViewControllerAnimated:YES completion:^{
                [self.delegate authorizationDidFinish:success];
            }];
        }];
    }
    return self;
}

-(void)login:(UIViewController*)viewController{
   
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?response_type=token&client_id=%@&redirect_uri=%@&scope=%@&expires_in=604800",authUrl,clientID,redirectURI,defaultScope]];
    
    SFSafariViewController *authorizationViewController = [[SFSafariViewController alloc] initWithURL:url];
    authorizationViewController.delegate = self;
    authorizationVC = authorizationViewController;
    [viewController presentViewController:authorizationViewController animated:YES completion:nil];
}
-(NSString *)extractToken:(NSNotification *)notification Key:(NSString *)key{
    NSURL *url = notification.userInfo[@"URL"];
    
    NSString *strippedURL = [url.absoluteString stringByReplacingOccurrencesOfString:redirectURI withString:@""];
    
    NSString *str = [self parametersFromQueryString:strippedURL][key];
    
    return str ;
}
-(NSDictionary *)parametersFromQueryString:(NSString *)queryString{
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init];
    if (queryString != nil) {
        NSScanner *paramScanner = [NSScanner scannerWithString:queryString];
        NSString  *name;
        NSString  *value;
        while (paramScanner.isAtEnd != true) {
            name = nil;
            [paramScanner scanUpToString:@"=" intoString:&name];
            [paramScanner scanString:@"=" intoString:nil];
            
            value = nil;
            [paramScanner scanUpToString:@"&" intoString:&value];
            [paramScanner scanString:@"&" intoString:nil];

            if (name != nil && value != nil) {
                [parameters setValue:[value stringByRemovingPercentEncoding] forKey:[name stringByRemovingPercentEncoding]];
            }
        }
    }
    return parameters;
}
-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller{
    [_delegate authorizationDidFinish:false];
}

#pragma mark - Token Methods ;
-(NSString *)getToken{
  NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fitbit_token"];
  return authToken;
}
-(void)clearToken{
    authenticationToken = nil;
    [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"fitbit_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
