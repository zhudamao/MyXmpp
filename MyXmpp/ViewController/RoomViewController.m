//
//  RoomViewController.m
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/11.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import "RoomViewController.h"
#import "MyXmppManager.h"
#import "RoomUserController.h"

@interface RoomViewController ()
{
    NSMutableArray * _roomArry;
    XMPPRoomCoreDataStorage * _storage;
    XMPPRoom * _xmppRoom;
}
@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _storage = [[XMPPRoomCoreDataStorage alloc]init];
    MyXmppManager * manager = [MyXmppManager sharedMyxmppManager];
    [manager.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

    /*get exits rooms*/
    self.tableView.rowHeight = 60.0f;
    [self getExitRooms];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method

-(void)getExitRooms{
    MyXmppManager * manager = [MyXmppManager sharedMyxmppManager];
    NSString * myJid = [NSString stringWithFormat:@"%@@%@",manager.myJid,XMPPHost];
    
    NSXMLElement * queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement * iqElement = [NSXMLElement elementWithName:@"iq"];
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"from" stringValue:myJid];
    NSString * host = [NSString stringWithFormat:@"conference.%@",XMPPHost];
    [iqElement addAttributeWithName:@"to" stringValue:host];
    [iqElement addAttributeWithName:@"id" stringValue:@"getexistroomid"];
    [iqElement addChild:queryElement];

    [manager.xmppStream sendElement:iqElement];///*send get request*/
}


#pragma mark -UITableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _roomArry? _roomArry.count:0;
}

-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentify = @"indentify";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentify];
        
    }
    NSArray *attributeArry = [_roomArry objectAtIndex:indexPath.row];
    
    NSString * jidStr = [[attributeArry objectAtIndex:0] stringValue];
    NSString * name = [[attributeArry objectAtIndex:1] stringValue];
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"Room :%@ ,%@",name,jidStr];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSArray *attributeArry = [_roomArry objectAtIndex:indexPath.row];
    
    NSString * jidStr = [[attributeArry objectAtIndex:0] stringValue];
    
    _xmppRoom = [[XMPPRoom alloc]initWithRoomStorage:_storage jid:[XMPPJID jidWithString:jidStr] dispatchQueue:dispatch_get_main_queue()];
    [_xmppRoom activate:[MyXmppManager sharedMyxmppManager].xmppStream];
    
    [_xmppRoom joinRoomUsingNickname:@"fakeYOu" history:nil];// self jion to the room first 
    [self performSegueWithIdentifier:@"roomMember" sender:cell];
}

#pragma mark -XMPPStreamDelegate
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"收到iq:%@",iq.description);
    
    _roomArry = [NSMutableArray array];
    for (DDXMLElement * element in iq.children) {
        if ([element.name isEqualToString:@"query"]) {
            for (DDXMLElement * item in element.children) {
                if ([item.name isEqual:@"item"]) {
                    [_roomArry addObject:item.attributes];
                }
            }
        }
        
    }
    if (_roomArry.count > 0) {
        [self.tableView reloadData];
    }
    
    return YES;
}



#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = (UITableViewCell *)sender;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    if ([[segue destinationViewController]isKindOfClass:[RoomUserController class]]) {
        RoomUserController * roomCtrl = [segue destinationViewController];
        
        NSArray * id = [_roomArry objectAtIndex:indexPath.row];
        roomCtrl.info = id;
        roomCtrl.room = _xmppRoom;
    }
}


@end
