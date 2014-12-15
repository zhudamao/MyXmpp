//
//  UserObject.h
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/4.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUSER_ID @"userId"
#define kUSER_NICKNAME @"nickName"
#define kUSER_DESCRIPTION @"description"
#define kUSER_USERHEAD @"userHead"
#define kUSER_FRIEND_FLAG @"friendFlag"

@interface UserObject : NSObject
@property (nonatomic,retain) NSString* userId;
@property (nonatomic,retain) NSString* userNickname;
@property (nonatomic,retain) NSString* userDescription;
@property (nonatomic,retain) NSString* userHead;
@property (nonatomic,retain) NSNumber* friendFlag;


//数据库增删改查
+(BOOL)saveNewUser:(UserObject*)aUser;
+(BOOL)deleteUserById:(NSNumber*)userId;
+(BOOL)updateUser:(UserObject*)newUser;
+(BOOL)haveSaveUserById:(NSString*)userId;

+(NSMutableArray*)fetchAllFriendsFromLocal;

//将对象转换为字典
-(NSDictionary*)toDictionary;
+(UserObject*)userFromDictionary:(NSDictionary*)aDic;
@end
