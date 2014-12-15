//
//  RegisteViewController.h
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/3.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyXmppManager.h"

@interface RegisteViewController : UIViewController<UITextFieldDelegate>
{

    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *keyTextField;
}
- (IBAction)registeNow:(UIButton *)sender;
@end
