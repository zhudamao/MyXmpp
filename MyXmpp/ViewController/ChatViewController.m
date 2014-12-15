//
//  ChatViewController.m
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/9.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import "ChatViewController.h"
#import "MyXmppManager.h"

@interface ChatViewController ()
{
    NSArray * _messageArry;
}

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = _messageObject.user.userId;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    _messageArry = [MessageObject fetchMessageListWithUser:_messageObject.user.userId byPage:1];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArry.count -1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    MyXmppManager * manager = [MyXmppManager sharedMyxmppManager];
    [manager.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
-(void)keyBoardWillHidden:(NSNotification *)notfication{
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 49);
        self.toolView.frame = CGRectMake(0, SCREEN_HEIGHT - self.toolView.bounds.size.height, self.toolView.bounds.size.width, self.toolView.bounds.size.height);
    }];

}

-(void)keyChangeFrame:(NSNotification *)notfication{
    NSDictionary * info = [notfication userInfo];
    NSValue * value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;

    
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - keyboardSize.height - self.toolView.bounds.size.height);
        self.toolView.frame = CGRectMake(0, SCREEN_HEIGHT - keyboardSize.height - self.toolView.bounds.size.height, self.toolView.bounds.size.width, self.toolView.bounds.size.height);
    } completion:^(BOOL finished) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArry.count -1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];

}

#pragma mark - UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messageArry? _messageArry.count:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * indentify = @"cell";
    
    ChatCell * cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    if (cell == nil) {
        cell = [[ChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentify];
    }
    
    MessageObject * obj = [_messageArry objectAtIndex:indexPath.row];
    cell.msgObj = obj;
    //cell.textLabel.text = [NSString stringWithFormat:@"row is %d",indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageObject * obj = [_messageArry objectAtIndex:indexPath.row];
    
    return [ChatCell getHight:obj] + 20;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)cancelMessage:(id)sender {
    [self.messageTextField resignFirstResponder];
}

- (IBAction)sendMessage:(UIButton *)sender {
    NSString * meg = _messageTextField.text;
    
    if (!meg || meg.length == 0) {
        return;
    }
    
    MessageObject * object = [[MessageObject alloc]init];
    object.messageTo = self.messageObject.user.userId;
    object.messageFrom = [MyXmppManager sharedMyxmppManager].myJid;
    object.messageContent = meg;
    object.messageDate = [NSDate date];
    object.messageType = [NSNumber numberWithInt:kWCMessageCellStyleOther];
    
    [MessageObject save:object];
    XMPPJID * jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",object.messageTo,XMPPHost]];
    XMPPMessage * xmppMeg = [XMPPMessage messageWithType:@"chat" to:jid];
    [xmppMeg addChild:[DDXMLNode elementWithName:@"body" stringValue:meg]];
    
    [[MyXmppManager sharedMyxmppManager] sendMessage:xmppMeg];
    [self.messageTextField resignFirstResponder];
    self.messageTextField.text = nil;
    _messageArry = [MessageObject fetchMessageListWithUser:_messageObject.user.userId byPage:1];
    [self.tableView reloadData];
}


#pragma mark - XMPPStreamDelegate
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    _messageArry = [MessageObject fetchMessageListWithUser:_messageObject.user.userId byPage:1];
    [self.tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArry.count -1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark -UITextDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendMessage:nil];
    return YES;
}

@end
