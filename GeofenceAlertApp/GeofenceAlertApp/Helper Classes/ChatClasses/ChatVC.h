//
//  ChatVC.h
//  SC4App18
//
//  Created by stuart watts on 19/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableArray.h"

@interface ChatVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITableView *tblchat;
    int viewWidth;
    UITableView * tblMessages;
    UIView * viewOverLay, * viewMore;
    int headerhHeight, bottomHeight;
    NSMutableArray * arrMessages;
    NSString * msgIndex, * msgTxt;
    UITextField * txtChat;
    UIImageView * backContactView;
    UIView * viewMessage;
    int xx,intkeyboardHeight;
    
}
@property (nonatomic , strong)NSString * userNano;
@property (nonatomic , strong)NSString * userName;
@property (nonatomic , strong)NSString * isFrom;
@property (nonatomic , strong)NSString * sc4NanoId;
@property (strong, nonatomic) TableArray *tableArray;
-(void)GotMessagefromDiver:(NSMutableDictionary *)strDict;
-(void)GotMessageSendAck:(NSString *)strStatus;
-(void)GotSentMessageAcknowledgement:(NSString *)strSeqence withStatus:(NSString *)strStatus;
@end
