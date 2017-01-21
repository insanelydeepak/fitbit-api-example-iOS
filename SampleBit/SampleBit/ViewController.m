//
//  ViewController.m
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import "ViewController.h"
#import "FitbitAuthHandler.h"
#import "FitbitAPIManager.h"
@interface ViewController ()<FitbitAuthHandlerProtocol>

@end

@implementation ViewController
{
    FitbitAuthHandler *fitbitAuthHandler;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
  //  fitbitAuthHandler = [[FitbitAuthHandler alloc]init:self] ;
    //authenticationController.delegate = self;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)actionLogin:(UIButton *)sender {
    [fitbitAuthHandler login:self];
   
}
-(void)authorizationDidFinish:(BOOL)success{
    NSLog(@"success %d",success);
    NSString *token = [fitbitAuthHandler getToken];
    
   
    FitbitAPIManager *manager = [FitbitAPIManager sharedManager];
    
    //********** Pass your API here and get details in response **********
    [manager requestGET:@"https://api.fitbit.com/1/user/-/profile.json" Token:token success:^(NSDictionary *responseObject) {
        NSLog(@"Response %@",responseObject);
        
    } failure:^(NSError *error) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@",error.localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alert show];
    }];
    
   }
@end
