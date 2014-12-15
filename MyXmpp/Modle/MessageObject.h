//
//  MessageObject.h
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/4.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserObject.h"
#import "MessageUserUnionObject.h"

#define kMESSAGE_TYPE @"messageType"
#define kMESSAGE_FROM @"messageFrom"
#define kMESSAGE_TO @"messageTo"
#define kMESSAGE_CONTENT @"messageContent"
#define kMESSAGE_DATE @"messageDate"
#define kMESSAGE_ID @"messageId"

enum MessageType {
    kWCMessageTypePlain = 0,
    kWCMessageTypeImage = 1,
    kWCMessageTypeVoice =2,
    kWCMessageTypeLocation=3
};

enum MessageCellStyle {
    kWCMessageCellStyleMe = 0,
    kWCMessageCellStyleOther = 1,
    kWCMessageCellStyleMeWithImage=2,
    kWCMessageCellStyleOtherWithImage=3
};

@interface MessageObject : NSObject
@property (nonatomic,copy) NSString *messageFrom;
@property (nonatomic,copy) NSString *messageTo;
@property (nonatomic,copy) NSString *messageContent;
@property (nonatomic,retain) NSDate *messageDate;
@property (nonatomic,retain) NSNumber *messageType;
@property (nonatomic,retain) NSNumber *messageId;

+(MessageObject *)messageWithType:(int)aType;

//将对象转换为字典
-(NSDictionary*)toDictionary;
+(MessageObject*)messageFromDictionary:(NSDictionary*)aDic;

//数据库增删改查
+(BOOL)save:(MessageObject*)aMessage;
+(BOOL)deleteMessageById:(NSNumber*)aMessageId;
+(BOOL)merge:(MessageObject*)aMessage;

//获取某联系人聊天记录
+(NSMutableArray *)fetchMessageListWithUser:(NSString *)userId byPage:(int)pageIndex;

//获取最近联系人
+(NSMutableArray *)fetchRecentChatByPage:(int)pageIndex;

@end
