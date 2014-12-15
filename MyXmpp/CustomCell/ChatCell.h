//
//  ChatCell.h
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/10.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageObject.h"

@interface ChatCell : UITableViewCell
{
    UIImageView * _headImageView;
    UIImageView * _bubbleImageView;
    UILabel * _contentLable;
    UIImageView * _headMaskView;

}

@property (nonatomic,retain) MessageObject * msgObj;

+(CGFloat)getHight:(MessageObject *)msg;

@end
