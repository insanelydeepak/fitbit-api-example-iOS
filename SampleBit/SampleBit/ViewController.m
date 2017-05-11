//
//  ViewController.m
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import "ViewController.h"
#import "FitbitExplorer.h"
@interface ViewController ()

@end

@implementation ViewController
{
    FitbitAuthHandler *fitbitAuthHandler;
    __weak IBOutlet UITextView *resultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    fitbitAuthHandler = [[FitbitAuthHandler alloc]init:self] ;
    
    resultView.layer.borderColor     = [UIColor lightGrayColor].CGColor;
    resultView.layer.borderWidth     = 2.0f;
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(notificationDidReceived) name:FitbitNotification object:nil];

}

-(void)notificationDidReceived{
    resultView.text = @"Authorization Successfull \nPlease press getProfile to fetch data of fitbit user profile";
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)actionLogin:(UIButton *)sender {
    [fitbitAuthHandler login:self];
}

- (IBAction)actionGetProfile:(UIButton *)sender {
    NSString *token = [FitbitAuthHandler getToken];
    
    FitbitAPIManager *manager = [FitbitAPIManager sharedManager];
    //********** Pass your API here and get details in response **********
    NSString *urlString = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/profile.json"] ;

    [manager requestGET:urlString Token:token success:^(NSDictionary *responseObject) {
        // ------ response -----
        resultView.text = [responseObject description];
        
    } failure:^(NSError *error) {
        NSData * errorData = (NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *errorResponse =[NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
        NSArray *errors = [errorResponse valueForKey:@"errors"];
        NSString *errorType = [[errors objectAtIndex:0] valueForKey:@"errorType"] ;
        if ([errorType isEqualToString:fInvalid_Client] || [errorType isEqualToString:fExpied_Token] || [errorType isEqualToString:fInvalid_Token]|| [errorType isEqualToString:fInvalid_Request]) {
            // To perform login if token is expired
            [fitbitAuthHandler login:self];
        }
    }];
}

@end
