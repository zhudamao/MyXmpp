//
//  ChatViewController.h
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/9.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageUserUnionObject.h"
#import "ChatCell.h"

@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *toolView;
@property (nonatomic,retain) MessageUserUnionObject * messageObject;
- (IBAction)sendMessage:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UIButton *cancelMessage;

@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@end
