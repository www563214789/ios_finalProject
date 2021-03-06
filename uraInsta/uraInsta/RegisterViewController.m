//
//  RegisterViewController.m
//  uraInsta
//
//  Created by mac18 on 2019/12/18.
//  Copyright © 2019 mac12. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()
{
    UITextField *activeField;
    CGPoint lastOffset;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self.textEmail setDelegate:self];
    [self.textPassword setDelegate:self];
    [self.textPassword2 setDelegate:self];
    [self.textAccountName setDelegate:self];
    [self.textDisplayname setDelegate:self];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollview.contentInset = contentInsets;
    _scrollview.scrollIndicatorInsets = contentInsets;

    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.scrollview scrollRectToVisible:activeField.frame animated:YES];
    }
}
-(void)keyboardWillHide:(NSNotification *)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollview.contentInset = contentInsets;
    _scrollview.scrollIndicatorInsets = contentInsets;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeField = textField;
//    lastOffset = CGPointMake(self.scrollview.contentOffset.x, self.scrollview.contentOffset.y);
    return  true;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [activeField resignFirstResponder];
    activeField=nil;
    return true;
}

-(void)dismissKeyboard{
    [self.textEmail resignFirstResponder];
    [self.textPassword resignFirstResponder];
    [self.textPassword2 resignFirstResponder];
    [self.textAccountName resignFirstResponder];
    [self.textDisplayname resignFirstResponder];
}

- (IBAction)startRegist:(id)sender {
    [self getCSRFTokenAndRegister];
}

-(void)getCSRFTokenAndRegister{
    
    NSString *SERVER_URL_PREFIX = [NSString stringWithFormat:@"%@", SERVER_URL];
    NSString *url_string = [NSString stringWithFormat:@"%@register", SERVER_URL_PREFIX];
    __block NSString *csrf_token = @"";
    NSURL *url = [NSURL URLWithString:url_string];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
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
                    [self goRegister:csrf_token];
                });
            }
        }
    }];
    [task resume];
}
-(void)goRegister:(NSString *)csrf_token{
    NSString *accountName = self.textAccountName.text;
    NSString *displayname = self.textDisplayname.text;
    NSString *email = self.textEmail.text;
    NSString *password = self.textPassword.text;
    NSString *password2 = self.textPassword2.text;
    
    NSString *SERVER_URL_PREFIX = [NSString stringWithFormat:@"%@", SERVER_URL];
    NSString *url_string = [NSString stringWithFormat:@"%@register", SERVER_URL_PREFIX];
    NSURL *url = [NSURL URLWithString:url_string];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:10.0];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    NSString *parameter = [[NSString alloc]initWithFormat:@"csrf_token=%@&username=%@&password=%@&password2=%@&display_name=%@&email=%@",csrf_token, accountName, password, password2, displayname, email];
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
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }
        }
    }];
    [task resume];
    
}

@end
