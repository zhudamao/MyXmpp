//
//  RegisteViewController.m
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/3.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import "RegisteViewController.h"

@interface RegisteViewController ()

@end

@implementation RegisteViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [nameTextField becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    nameTextField.delegate = self;
    keyTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)registeNow:(UIButton *)sender {
    MyXmppManager * manager = [MyXmppManager sharedMyxmppManager];
    
    if (nameTextField.text.length == 0 || keyTextField.text.length == 0) {
        [[iToast makeText:@"完善数据"] show];
        return;
    }
    if (![manager.xmppStream isConnected]) {
        [manager connectWithName:nameTextField.text andPassword:keyTextField.text];//连接
    }
    
    
    if (![manager.xmppStream supportsInBandRegistration]) {
        [[iToast makeText:@"不支持内注册"] show];
        return;
    }
    
    [manager.xmppStream setMyJID:[XMPPJID jidWithUser:nameTextField.text domain:XMPPHost resource:@"XMPPIOS"]];
    
    NSError * error = nil;
    if (![manager.xmppStream registerWithPassword:keyTextField.text error:&error]) {
        UIAlertView * alterView = [[UIAlertView alloc]initWithTitle:@"error" message:error.description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alterView show];
    }else{
        [[iToast makeText:@"注册成功!"] show];
        manager.myJid = nameTextField.text;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - UITextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == nameTextField) {
        [keyTextField becomeFirstResponder];
    }else
    {
        [self.view endEditing:YES];
    }
    
    
    return YES;
}

@end
