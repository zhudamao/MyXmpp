//
//  MessageUserUnionObject.m
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/4.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import "MessageUserUnionObject.h"

@implementation MessageUserUnionObject

+(MessageUserUnionObject *)unionWithMessage:(MessageObject *)aMessage andUser:(UserObject *)aUser
{
    MessageUserUnionObject *unionObject=[[MessageUserUnionObject alloc]init];
    [unionObject setUser:aUser];
    [unionObject setMessage:aMessage];
    return unionObject;
}


@end
