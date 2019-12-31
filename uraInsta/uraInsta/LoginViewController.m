//
//  LoginViewController.m
//  uraInsta
//
//  Created by mac18 on 2019/12/18.
//  Copyright © 2019 mac12. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"

@interface LoginViewController ()

@end


//typedef void(^getCompleteBlock)(void);

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.destinationViewController isKindOfClass:[ViewController class]])
//    {
//        NSLog(@"ok");
//    }
//    else
//    {
//        NSLog(@"no");
//    }
//}

//- (IBAction)btnLogin:(id)sender {
//    if ([_textEmail.text isEqualToString:@"1"]) {
//        NSLog(@"go");
//        ViewController *view = [[ViewController alloc] init];
//        [self showDetailViewController:view sender:nil];
//    }
//    else
//    {
//        NSLog(@"no");
//    }
//}

- (IBAction)btn_login:(id)sender {
    [self getCSRFTokenAndLogin];
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    //Check current segue identifier
    if([identifier isEqualToString:@"gotoindex"]){
        NSLog(@"%@", identifier);
//        [self getCSRFToken];
        
        if([self.textEmail.text isEqualToString:@"123"]){
            return YES;
        }
    }else{
        return YES;
    }
    return NO;
}

//- (void)login:(getCompleteBlock)compBlock{
//
//}
-(void)getCSRFTokenAndLogin{
    
    NSString *url_string = @"http://127.0.0.1:5000/api/login";
    __block NSString *csrf_token = @""; //'__block' makes block code can access this variable
    NSURL *url = [NSURL URLWithString:url_string];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    //Load parameters with dictionary
    /*
    NSDictionary *parameterDict = @{@"email":@"aaa@aaa.com", @"password":@"aaa"};
    NSMutableString *parameter_string = [[NSMutableString alloc]init];
    int pos=0;
    for(NSString *key in parameterDict.allKeys){
        [parameter_string appendFormat:@"%@=%@", key, parameterDict[key]];
        if(pos<parameterDict.allKeys.count-1){
            [parameter_string appendString:@"&"];
        }
        pos++;
    }*/
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    //Customize session configuration
//        NSURLSessionConfiguration *session_conf = [NSURLSessionConfiguration defaultSessionConfiguration];
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:session_conf];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error){
            // If error happened, print out error msg
            NSLog(@"Get error :%@", error.localizedDescription);
        }else{
            NSString *target_tag = @"<input id=\"csrf_token\" name=\"csrf_token\" type=\"hidden\" value=\""; //Set catch tag
            NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]; //HTML content
            if([result rangeOfString:target_tag].location){
                NSUInteger start_point = [result rangeOfString:target_tag].location + [result rangeOfString:target_tag].length;
                csrf_token = [result substringWithRange:NSMakeRange(start_point, 91)];
                //If csrf token is caught successfully, do http post request in main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"csrf=%@", csrf_token);
                    [self login:csrf_token];
                });
            }
        }
    }];
    [task resume];
}

-(void)login:(NSString *)csrf_token{
    NSString *email = self.textEmail.text;
    NSString *password = self.textPassword.text;
    NSString *url_string = @"http://127.0.0.1:5000/api/login";
    NSURL *url = [NSURL URLWithString:url_string];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:10.0];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    NSString *parameter = [[NSString alloc]initWithFormat:@"csrf_token=%@&email=%@&password=%@&submit=submit",csrf_token, email, password];
    NSData *parameter_data = [parameter dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:parameter_data];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            // If error happened, print out error msg
            NSLog(@"Get error :%@", error.localizedDescription);
        }else{
            NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", result);
            if([result isEqualToString:@"ok"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"gotoindex" sender:nil];
                });
                
            }
        }
    }];
    [task resume];
    
}

@end
