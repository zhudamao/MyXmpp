//
//  LoginViewController.m
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/3.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [nameLable becomeFirstResponder];
    
    MyXmppManager * manager = [MyXmppManager sharedMyxmppManager];
    if (manager.myJid) {
        nameLable.text = manager.myJid;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    nameLable.delegate = self;
    keyLable.delegate =  self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == nameLable) {
        [keyLable becomeFirstResponder];
    }else if (textField == keyLable){
        MyXmppManager * manager = [MyXmppManager sharedMyxmppManager];
        
        if (![manager connectWithName:nameLable.text andPassword:keyLable.text]) {
            [[[UIAlertView alloc]initWithTitle:@"服务器连接失败" message:@"" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil]show];
        }else{
            manager.callBlock = ^(){
                [[iToast makeText:@"连接成功！"] show];
                
                UIStoryboard * board = [UIStoryboard storyboardWithName:@"TabBar" bundle:nil];
                UITabBarController * tabCtrl = [board instantiateInitialViewController];
                
                [UIApplication sharedApplication].delegate.window.rootViewController = tabCtrl;
            };
        }
    }
    
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
