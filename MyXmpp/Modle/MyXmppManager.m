//
//  MyXmppManager.m
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/3.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import "MyXmppManager.h"
#import "DDTTYLogger.h"


#ifdef  DEBUG
    static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
    static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation MyXmppManager
@synthesize  xmppStream ;

+(MyXmppManager *)sharedMyxmppManager{
    static MyXmppManager * manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MyXmppManager alloc]init];
        manager.isLogined = NO;
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [manager setupStream];
    });
    
    return manager;
}

#pragma  mark ------收发消息-------
- (void)sendMessage:(XMPPMessage *)aMessage
{
    [xmppStream sendElement:aMessage];
    //创建message对象
    //WCMessageObject *msg=[[WCMessageObject alloc]init];
    //[msg setMessageDate:[NSDate date]];
    //[msg setMessageFrom:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]];
    
    //[msg setMessageTo:strs[0]];
    //判断多媒体消息
    
   // NSDictionary *messageDic=[body JSONValue];
   // NSLog(@"发送消息中:%@",[messageDic objectForKey:@"text"]);
    
//    [msg setMessageType:[messageDic objectForKey:@"messageType"]];
//    
//    if (msg.messageType.intValue==kWCMessageTypePlain) {
//        [msg setMessageContent:[messageDic objectForKey:@"text"]];
//    }else
//        [msg setMessageContent:[[messageDic objectForKey:@"file"]objectForKey:@"shortPath"]];
//    
//    
//    //[msg setMessageContent:body];
//    [WCMessageObject save:msg];
    //发送全局通知
    //    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPNewMsgNotifaction object:msg ];
    //    [msg release];
}



#pragma mark --------配置XML流---------
- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Activate xmpp modules
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];

    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    [xmppStream setHostName:XMPPHost];
    [xmppStream setHostPort:5222];
    
    // You may need to alter these settings depending on the server you're connecting to
    allowSelfSignedCertificates = NO;
    allowSSLHostNameMismatch = NO;
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    
    [xmppReconnect         deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// http://code.google.com/p/xmppframework/wiki/WorkingWithElements

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    [xmppStream sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [xmppStream sendElement:presence];
}

#pragma mark Connect/disconnect

- (BOOL)connectWithName:(NSString *)myJid andPassword:(NSString *)key
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }

    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    // myJID = @"user@gmail.com/xmppframework";
    // myPassword = @"";
    
    if (myJid == nil || key == nil) {
        return NO;
    }
    
    _myJid = myJid;
    _myPassWord = key;
    
    [xmppStream setMyJID:[XMPPJID jidWithUser:myJid domain:XMPPHost resource:@"ios"]];
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
}

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}
// Returns the URL to the application's Documents directory.


#pragma mark XMPPStreamDelegate

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (allowSelfSignedCertificates)
    {
        [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
    }
    
    if (allowSSLHostNameMismatch)
    {
        [settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
    }
    else
    {
        // Google does things incorrectly (does not conform to RFC).
        // Because so many people ask questions about this (assume xmpp framework is broken),
        // I've explicitly added code that shows how other xmpp clients "do the right thing"
        // when connecting to a google server (gmail, or google apps for domains).
        
        NSString *expectedCertName = nil;
        
        NSString *serverDomain = xmppStream.hostName;
        NSString *virtualDomain = [xmppStream.myJID domain];
        
        if ([serverDomain isEqualToString:@"talk.google.com"])
        {
            if ([virtualDomain isEqualToString:@"gmail.com"])
            {
                expectedCertName = virtualDomain;
            }
            else
            {
                expectedCertName = serverDomain;
            }
        }
        else if (serverDomain == nil)
        {
            expectedCertName = virtualDomain;
        }
        else
        {
            expectedCertName = serverDomain;
        }
        
        if (expectedCertName)
        {
            [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
        }
    }
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![xmppStream authenticateWithPassword:_myPassWord error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
    [xmppRoster fetchRoster];
    
    if (self.callBlock) {
        self.callBlock();
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self.xmppStream disconnect];
    [[iToast makeText:@"授权失败"] show];
}

//- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//   	if ([message isChatMessageWithBody])
//    {
//        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
//                                                                 xmppStream:xmppStream
//                                                       managedObjectContext:[self managedObjectContext_roster]];
//        
//        NSString *body = [[message elementForName:@"body"] stringValue];
//        NSString *displayName = [user displayName];
//        
//        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
//        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
//                                                                message:body
//                                                               delegate:nil
//                                                      cancelButtonTitle:@"Ok"
//                                                      otherButtonTitles:nil];
//            [alertView show];
//        }
//        else
//        {
//            // We are not active, so use a local notification instead
//            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//            localNotification.alertAction = @"Ok";
//            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
//            
//            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
//        }
//    }
//}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}



#pragma mark XMPPRosterDelegate

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    
    XMPPJID *jid=[XMPPJID jidWithString:[presence stringValue]];
    [xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
}

- (void)addSomeBody:(NSString *)userId
{
    [xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@hcios.com",userId]]];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}
@end
