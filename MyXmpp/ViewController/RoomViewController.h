//
//  RoomViewController.h
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/11.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
