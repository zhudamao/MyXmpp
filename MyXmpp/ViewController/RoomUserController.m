//
//  RoomUserController.m
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/11.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import "RoomUserController.h"
#import "MyXmppManager.h"

@interface RoomUserController ()
{
    NSMutableDictionary * _mesDic;
}
@end

@implementation RoomUserController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mesDic = [NSMutableDictionary dictionary];
    NSString * name = [[_info objectAtIndex:1] stringValue];
    self.title = [NSString stringWithFormat:@"房间%@",name] ;
    
    [_room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self getRoomList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
-(void)getRoomList{
    [_room fetchBanList]; // 黑名单
    [_room fetchMembersList];// 成员名单
    [_room fetchModeratorsList];//群主
}

#pragma mark - UITableView Delegate

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * title = nil;
    
    switch (section) {
        case 0:
            title = MEMBAN;
            break;
        case 1:
            title = MEMMEBERS;
            break;
        case 2:
            title = MEMRARTORS;
            break;
        default:
            break;
    }

    return title;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    switch (section) {
        case 0:
        {
            NSArray * arry  = [_mesDic objectForKey:MEMBAN];
            row = arry? arry.count : 0;
        }
            break;
        case 1:
        {
            NSArray * arry = [_mesDic objectForKey:MEMMEBERS];
            row = arry? arry.count:0;
        }
            break;
        case 2:
        {
            NSArray * arry = [_mesDic objectForKey:MEMRARTORS];
            row = arry? arry.count:0;
        }
            break;
        default:
            break;
    }

    return row;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * indentify = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:indentify];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentify];
    
    }
    NSString * title = nil;
    
    switch (indexPath.section) {
        case 0:
            title = MEMBAN;
            break;
        case 1:
            title = MEMMEBERS;
            break;
        case 2:
            title = MEMRARTORS;
            break;
        default:
            break;
    }

    
    NSArray * arry = [_mesDic objectForKey:title];
    if (arry) {
        NSDictionary * dic = [arry objectAtIndex:indexPath.row];
        cell.textLabel.text = [dic objectForKey:@"nick"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"jid:%@ role:%@",[dic objectForKey:@"jid"],[dic objectForKey:@"role"]];
    }
    
    return cell;
}

#pragma mark - XMPPRoomDelegate

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
    [_mesDic setObject:items forKey:MEMBAN];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    [_mesDic setObject:items forKey:MEMMEBERS];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError{
    NSLog(@"%@",iqError);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items{
    [_mesDic setObject:items forKey:MEMRARTORS];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError{
    NSLog(@"%@",iqError);
}

@end
