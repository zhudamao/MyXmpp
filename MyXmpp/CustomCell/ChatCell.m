//
//  ChatCell.m
//  MyXmpp
//
//  Created by 朱大茂 on 14/12/10.
//  Copyright (c) 2014年 zhudm. All rights reserved.
//

#import "ChatCell.h"

#define CELL_HEIGHT self.contentView.frame.size.height
#define CELL_WIDTH self.contentView.frame.size.width

//头像大小
#define HEAD_SIZE 50.0f
#define TEXT_MAX_HEIGHT 500.0f
//间距
#define INSETS 8.0f


@implementation ChatCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _bubbleImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _contentLable = [[UILabel alloc]initWithFrame:CGRectZero];
        _contentLable.backgroundColor = [UIColor clearColor];
        _headMaskView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [_headMaskView setImage:[[UIImage imageNamed:@"headMask"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
     
        
        [self.contentView addSubview:_headImageView];
        [self.contentView addSubview:_bubbleImageView];
        [self.contentView addSubview:_contentLable];
        [self.contentView addSubview:_headMaskView];
    }
    return self;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)setMsgObj:(MessageObject *)msgObj{
    if (_msgObj != msgObj) {
        _msgObj = msgObj;
    }

    [self setNeedsLayout];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    NSString *orgin=_msgObj.messageContent;
    CGSize textSize = [orgin boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 2*HEAD_SIZE, 60) options:NSStringDrawingUsesFontLeading attributes:nil context:nil].size;
    textSize.width *= 2;
    _contentLable.text = orgin;
    switch ([_msgObj.messageType integerValue]) {
        case kWCMessageCellStyleOther:
        {
            [_contentLable setFrame:CGRectMake(CELL_WIDTH-INSETS*2-HEAD_SIZE-textSize.width-15, (CELL_HEIGHT-textSize.height)/2, textSize.width, textSize.height)];
            [_headImageView setFrame:CGRectMake(CELL_WIDTH-INSETS-HEAD_SIZE, INSETS,HEAD_SIZE , HEAD_SIZE)];
            _headImageView.image = [UIImage imageNamed:@"Icon"];
            [_bubbleImageView setImage:[[UIImage imageNamed:@"SenderTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30]];
            _bubbleImageView.frame=CGRectMake(_contentLable.frame.origin.x-15, _contentLable.frame.origin.y-12, textSize.width+30, textSize.height+30);
        
        }
        break;
        case kWCMessageCellStyleMe:
        {
            [_headImageView setFrame:CGRectMake(INSETS, INSETS,HEAD_SIZE , HEAD_SIZE)];
            [_headImageView setImage:[UIImage imageNamed:@"head.jpeg"]];
            [_contentLable setFrame:CGRectMake(2*INSETS+HEAD_SIZE+15, (CELL_HEIGHT-textSize.height)/2, textSize.width, textSize.height)];
            
            [_bubbleImageView setImage:[[UIImage imageNamed:@"ReceiverTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30]];
            _bubbleImageView.frame=CGRectMake(_contentLable.frame.origin.x-15, _contentLable.frame.origin.y-12, textSize.width+30, textSize.height+30);
        
        }
            break;
        default:
            break;
    }

}

+(CGFloat)getHight:(MessageObject *)msg{
    NSString *orgin= msg.messageContent;
    CGSize textSize = [orgin boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 20, 60) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:nil context:nil].size;
    
    return textSize.height + 30 > HEAD_SIZE ? textSize.height + 30 : HEAD_SIZE;
}

@end
