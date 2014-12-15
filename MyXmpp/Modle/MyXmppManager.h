//
//  MyXmppManager.h
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/3.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPPFramework.h"
#import "SBJson4.h"
#import "FMDatabase.h"

typedef void(^callBack) ();

@interface MyXmppManager : NSObject<XMPPRosterDelegate>

{
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    
    
    BOOL allowSelfSignedCertificates;
    BOOL allowSSLHostNameMismatch;
    
    BOOL isXmppConnected;
    
    
}

- (NSManagedObjectContext *)managedObjectContext_roster;
@property (readonly, retain,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, retain,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, retain,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, retain,nonatomic) XMPPStream* xmppStream;
@property (assign, nonatomic) BOOL isLogined;
//@property (retain, nonatomic) JXRoomPool* roomPool;
/*
 *  add by zhudm 12.1
 */
@property (nonatomic,copy) NSString * myPassWord;
@property (nonatomic,copy) NSString * myJid;
/*
 * for other user callback
 */
@property (nonatomic,copy) callBack callBlock;


- (void)saveContext;

- (BOOL)connectWithName:(NSString *)myJid andPassword:(NSString *)key;
- (void)disconnect;

- (FMDatabase*)openUserDb:(NSString*)userId;

#pragma mark -------配置XML流-----------

- (void)setupStream;
- (void)teardownStream;


#pragma mark ----------收发信息------------
- (void)goOnline;
- (void)goOffline;

- (void)sendMessage:(XMPPMessage *)aMessage;
- (void)addSomeBody:(NSString *)userId;


#pragma mark ---------文件传输-----------
-(void)sendFile:(NSData*)aData toJID:(XMPPJID*)aJID;


+(MyXmppManager *)sharedMyxmppManager;

@end
