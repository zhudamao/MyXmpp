//
//  MessageObject.m
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/4.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import "MessageObject.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "MyXmppManager.h"

@implementation MessageObject
@synthesize messageContent,messageDate,messageFrom,messageTo,messageType,messageId;
+(MessageObject *)messageWithType:(int)aType{
    MessageObject *msg=[[MessageObject alloc]init];
    [msg setMessageType:[NSNumber numberWithInt:aType]];
    return  msg;
}

+(MessageObject*)messageFromDictionary:(NSDictionary*)aDic
{
    MessageObject *msg=[[MessageObject alloc]init];
    [msg setMessageFrom:[aDic objectForKey:kMESSAGE_FROM]];
    [msg setMessageTo:[aDic objectForKey:kMESSAGE_TO]];
    [msg setMessageContent:[aDic objectForKey:kMESSAGE_CONTENT]];
    [msg setMessageDate:[aDic objectForKey:kMESSAGE_DATE]];
    [msg setMessageDate:[aDic objectForKey:kMESSAGE_TYPE]];
    return  msg;
}


//将对象转换为字典
-(NSDictionary*)toDictionary
{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:messageId,kMESSAGE_ID,messageFrom,kMESSAGE_FROM,messageTo,kMESSAGE_TO,messageContent,kMESSAGE_TYPE,messageDate,kMESSAGE_DATE,messageType,kMESSAGE_TYPE, nil];
    
    return dic;
}

//增删改查
+(BOOL)save:(MessageObject*)aMessage
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    };
    
    NSString *createStr=@"CREATE  TABLE  IF NOT EXISTS 'wcMessage' ('messageId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL  UNIQUE , 'messageFrom' VARCHAR, 'messageTo' VARCHAR, 'messageContent' VARCHAR, 'messageDate' DATETIME,'messageType' INTEGER )";
    
    BOOL worked = [db executeUpdate:createStr];
    
    
    NSString *insertStr=@"INSERT INTO 'wcMessage' ('messageFrom','messageTo','messageContent','messageDate','messageType') VALUES (?,?,?,?,?)";
    worked = [db executeUpdate:insertStr,aMessage.messageFrom,aMessage.messageTo,aMessage.messageContent,aMessage.messageDate,aMessage.messageType];
    
    [db close];
    //发送全局通知
    //[[NSNotificationCenter defaultCenter]postNotificationName:kXMPPNewMsgNotifaction object:aMessage ];
    
    return worked;
}

//获取某联系人聊天记录
+(NSMutableArray*)fetchMessageListWithUser:(NSString *)userId byPage:(int)pageInde
{
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    
    FMDatabase *db=[FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据打开失败");
        return messageList;
    }
    
    NSString *queryString=@"select * from wcMessage where messageFrom=? or messageTo=? order by messageDate";
    
    FMResultSet *rs=[db executeQuery:queryString,userId,userId];
    while ([rs next]) {
        MessageObject *message=[[MessageObject alloc]init];
        [message setMessageId:[rs objectForColumnName:kMESSAGE_ID]];
        [message setMessageContent:[rs stringForColumn:kMESSAGE_CONTENT]];
        [message setMessageDate:[rs dateForColumn:kMESSAGE_DATE]];
        [message setMessageFrom:[rs stringForColumn:kMESSAGE_FROM]];
        [message setMessageTo:[rs stringForColumn:kMESSAGE_TO]];
        [message setMessageType:[rs objectForColumnName:kMESSAGE_TYPE]];
        [ messageList addObject:message];
        
    }
    return  messageList;
    
}

//获取最近联系人
+(NSMutableArray *)fetchRecentChatByPage:(int)pageIndex
{
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    
    FMDatabase *db=[FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据打开失败");
        return messageList;
    }
    
    NSString *queryString=@"select * from wcMessage as m ,wcUser as u where u.userId<>? and ( u.userId=m.messageFrom or u.userId=m.messageTo ) group by u.userId  order by m.messageDate desc limit ?,10";
    FMResultSet *rs=[db executeQuery:queryString,[MyXmppManager sharedMyxmppManager].myJid,[NSNumber numberWithInt:pageIndex-1]];
    while ([rs next]) {
        MessageObject *message=[[MessageObject alloc]init];
        [message setMessageId:[rs objectForColumnName:kMESSAGE_ID]];
        [message setMessageContent:[rs stringForColumn:kMESSAGE_CONTENT]];
        [message setMessageDate:[rs dateForColumn:kMESSAGE_DATE]];
        [message setMessageFrom:[rs stringForColumn:kMESSAGE_FROM]];
        [message setMessageTo:[rs stringForColumn:kMESSAGE_TO]];
        [message setMessageType:[rs objectForColumnName:kMESSAGE_TYPE]];
        
        UserObject *user=[[UserObject alloc]init];
        [user setUserId:[rs stringForColumn:kUSER_ID]];
        [user setUserNickname:[rs stringForColumn:kUSER_NICKNAME]];
        [user setUserHead:[rs stringForColumn:kUSER_USERHEAD]];
        [user setUserDescription:[rs stringForColumn:kUSER_DESCRIPTION]];
        [user setFriendFlag:[rs objectForColumnName:kUSER_FRIEND_FLAG]];
        
        MessageUserUnionObject *unionObject=[MessageUserUnionObject unionWithMessage:message andUser:user ];
        
        [ messageList addObject:unionObject];
        
    }
    return  messageList;
    
}
@end
