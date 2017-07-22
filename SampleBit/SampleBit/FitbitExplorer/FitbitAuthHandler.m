//
//  FitbitAuthHandlerProtocol.m
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import "FitbitAuthHandler.h"
#import "FitbitAPIManager.h"
@implementation FitbitAuthHandler
{
    NSString  *clientID;
    NSString  *clientSecret ;
    NSURL     *authUrl ;
    NSURL     *refreshTokenUrl ;
    NSString  *redirectURI  ;
    NSString  *defaultScope ;
    NSString  *expiresIn ;
    
    NSString *authenticationCode;
    SFSafariViewController  *authorizationVC;
 }

-(void)loadVars{
    //------ Initialize all required vars -----
    clientID         = @"";
    clientSecret     = @"";
    redirectURI      = @"";
    expiresIn        = @"604800";
    authUrl          = [NSURL URLWithString:@"https://www.fitbit.com/oauth2/authorize"];
    refreshTokenUrl  = [NSURL URLWithString:@"https://api.fitbit.com/oauth2/token"];
    defaultScope     = @"sleep+settings+nutrition+activity+social+heartrate+profile+weight+location";
    
    /** expiresIn Details
    // 86400 for 1 day
    // 604800 for 1 week
    // 2592000 for 30 days
    // 31536000 for 1 year
     */
}
-(instancetype)init:(id)delegate_
{
    self = [super init];
    if (self) {
         [self loadVars];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"SampleBitLaunchNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            BOOL success;
            NSString *code = [self extractCode:note Key:@"?code"];
            if (code != nil) {
                authenticationCode = code;
                NSLog(@"You have successfully authorized");
                success = true;
            }
            else {
                NSLog(@"There was an error extracting the access token from the authentication response.");
                success = false;
            }
            [authorizationVC dismissViewControllerAnimated:YES completion:^{
               // [self.delegate authorizationDidFinish:success];
                [self getAccessToken:success];
            }];
        }];
    }
    return self;
}

-(void)login:(UIViewController*)viewController{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?response_type=code&client_id=%@&redirect_uri=%@&scope=%@&expires_in=%@",authUrl,clientID,redirectURI,defaultScope,expiresIn]];
    
    SFSafariViewController *authorizationViewController = [[SFSafariViewController alloc] initWithURL:url];
    authorizationViewController.delegate = self;
    authorizationVC = authorizationViewController;
    [viewController presentViewController:authorizationViewController animated:YES completion:nil];
}

-(NSString *)extractCode:(NSNotification *)notification Key:(NSString *)key{
    NSURL *url = notification.userInfo[@"URL"];
    NSString *strippedURL = [url.absoluteString stringByReplacingOccurrencesOfString:redirectURI withString:@""];
    NSString *str = [self parametersFromQueryStringCode:strippedURL][key];
    return str ;
}
-(NSDictionary *)parametersFromQueryStringCode:(NSString *)queryString{
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
            [paramScanner scanUpToString:@"#" intoString:&value];
            [paramScanner scanString:@"#" intoString:nil];
            [paramScanner scanUpToString:@"_" intoString:&value];
            [paramScanner scanString:@"_" intoString:nil];

            if (name != nil && value != nil) {
                [parameters setValue:[value stringByRemovingPercentEncoding] forKey:[name stringByRemovingPercentEncoding]];
            }
        }
    }
    
    return parameters;
}
-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller{
    [self getAccessToken:false];
}
-(void)showAlert :(NSString *)message{
    UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [UIViewController new];
    window.windowLevel = UIWindowLevelAlert + 1;
    
    UIAlertController* alertView = [UIAlertController alertControllerWithTitle:@"Fitbit Error!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
        window.hidden = YES;
    }]];
    
    [window makeKeyAndVisible];
    [window.rootViewController presentViewController:alertView animated:YES completion:nil];
}
#pragma mark - Fitbit Access Token
-(void)getAccessToken:(BOOL)success{
     if (success) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *base64 = [self base64String:[NSString stringWithFormat:@"%@:%@",clientID,clientSecret]];
        // NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"fitbit_code"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",base64] forHTTPHeaderField:@"Authorization"];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/x-www-form-urlencoded"];
        
        NSDictionary *param = @{@"grant_type":@"authorization_code",@"clientId":clientID,@"code":authenticationCode,@"redirect_uri":redirectURI};
        
        [manager POST:@"https://api.fitbit.com/oauth2/token" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             //******************** Save Token to NSUserDedaults ******************
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"access_token"]  forKey:@"fitbit_token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:FitbitNotification object:nil userInfo:nil];
            //********************* *********************** **********************
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               [self showAlert:[NSString stringWithFormat:@"%@",error.localizedDescription]];
        }];
    }
    else {
     
        [self showAlert:@"Authorization canceled"];
    }
}
-(void)revokeAccessToken:(NSString *)token{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *base64 = [self base64String:[NSString stringWithFormat:@"%@:%@",clientID,clientSecret]];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",base64] forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/x-www-form-urlencoded"];
    
    NSDictionary *params = @{@"token":token};
    [manager POST:@"https://api.fitbit.com/oauth2/revoke" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) [task response];
        NSInteger statusCode = [response statusCode];

        if (statusCode == 200) {
            //******************** clear Token ******************
            [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"fitbit_token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //********************* *********************** **********************
            NSLog(@"Fitbit RevokeToken Successfully");
            
        }
        else {
            NSLog(@"Fitbit RevokeToken Error: StatusCode= %ld Response= %@",(long)statusCode,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showAlert:[NSString stringWithFormat:@"%@",error.localizedDescription]];
    }];
    
}
-(NSString *)base64String:(NSString *)string {
    // Create NSData object
    NSData *nsdata = [string dataUsingEncoding:NSUTF8StringEncoding];
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    return base64Encoded;
}

#pragma mark - Token Methods ;
+(NSString *)getToken{
  NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fitbit_token"];
  return authToken;
}
+(void)clearToken{
    [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"fitbit_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
