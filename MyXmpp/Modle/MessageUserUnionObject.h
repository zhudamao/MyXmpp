//
//  MessageUserUnionObject.h
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/4.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserObject.h"
@class MessageObject;

@interface MessageUserUnionObject : NSObject

@property (nonatomic,retain) MessageObject * message;
@property (nonatomic,retain) UserObject* user;

+(MessageUserUnionObject *)unionWithMessage:(MessageObject *)aMessage andUser:(UserObject *)aUser;

@end
