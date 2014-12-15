//
//  RoomUserController.h
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/11.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyXmppManager.h"

#define MEMBAN      @"mem_ban"
#define MEMMEBERS   @"mem_bers"
#define MEMRARTORS  @"mem_rator"

@interface RoomUserController : UIViewController<XMPPRoomDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,retain) NSArray * info;
@property (nonatomic,retain)XMPPRoom * room;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
