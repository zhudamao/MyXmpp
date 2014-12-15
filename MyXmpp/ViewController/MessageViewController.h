//
//  MessageViewController.h
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/4.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessageObject.h"

@interface MessageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{

}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
