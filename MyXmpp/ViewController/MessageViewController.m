//
//  MessageViewController.m
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/4.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import "MessageViewController.h"
#import "MyXmppManager.h"
#import "MessageObject.h"
#import "ChatViewController.h"

@interface MessageViewController ()
{
    NSArray * _dataArry;
}
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_dataArry == nil) {
        [self refreashTableView];
    }
    
    MyXmppManager * manager = [MyXmppManager sharedMyxmppManager];
    [manager.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
-(void)refreashTableView{
    _dataArry = [MessageObject fetchRecentChatByPage:1];
    [self.tableView reloadData];
}

-(NSDateFormatter *)getDateFormater{
    static NSDateFormatter * format = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[NSDateFormatter alloc]init];
        [format setAMSymbol:@"上午"];
        [format setPMSymbol:@"下午"];
        [format setDateFormat:@"a HH:mm"];
    });

    return format;
}


#pragma mark - UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArry? _dataArry.count:0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * indentify = @"cell";
    
    MessageUserUnionObject * unionObj = [_dataArry objectAtIndex:indexPath.row];
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentify];
    }

    NSDateFormatter *formatter= [self getDateFormater];
    
    cell.imageView.image = [UIImage imageNamed:@"head.jpeg"];
    cell.textLabel.text = unionObj.user.userId;
    cell.detailTextLabel.text = [formatter stringFromDate:unionObj.message.messageDate];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"message" sender:cell];
}

#pragma mark - XMPPStreamDelegate
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSString *body = [[message elementForName:@"body"] stringValue];
    NSString *displayName = [[message from]bare];
    
    MessageObject * msg = [MessageObject messageWithType:kWCMessageTypePlain];
    NSArray * strs = [displayName componentsSeparatedByString:@"@"];
    
    [msg setMessageDate:[NSDate date]];
    [msg setMessageFrom:strs[0]];
    [msg setMessageContent:body];
    [msg setMessageTo:[MyXmppManager sharedMyxmppManager].myJid ];
    msg.messageType = [NSNumber numberWithInt:kWCMessageCellStyleMe];
    
    if (![UserObject haveSaveUserById:strs[0]]) {
        UserObject * user = [[UserObject alloc]init];
        
        user.userHead = @"";
        user.userId = strs[0];
        user.userDescription = @"hello";
        user.userHead = @"head.jpeg";
        user.friendFlag = [NSNumber numberWithInt:1];
        
        [UserObject saveNewUser:user];
    }
    
    [msg setMessageContent:body];
    
    [MessageObject save:msg];
    [self refreashTableView];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell * cell = (UITableViewCell * )sender;
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    MessageUserUnionObject * unionObj = [_dataArry objectAtIndex:path.row];
    
    if ([[segue destinationViewController]isKindOfClass:[ChatViewController class]]) {
        ChatViewController * chatCtrl = [segue destinationViewController];
        chatCtrl.messageObject = unionObj;
    }
    
}


@end
