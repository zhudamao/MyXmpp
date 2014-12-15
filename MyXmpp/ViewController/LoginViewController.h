//
//  LoginViewController.h
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/3.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyXmppManager.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *keyLable;

    IBOutlet UITextField *nameLable;
}


@end
