//
//  ChatVC.m
//  SC4App18
//
//  Created by stuart watts on 19/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "ChatVC.h"
#import "MessageCell.h"
#import "LeftMenuCell.h"
#import "FCAlertView.h"
#import "HomeVC.h"

@interface ChatVC ()
{
    BOOL isFreeText;
    UILabel * lblChatText;
}
@end

@implementation ChatVC
@synthesize userNano,isFrom,userName,sc4NanoId;

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    self.navigationController.navigationBarHidden = YES;
//
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, viewWidth, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    [self.view addSubview:imgBack];

     headerhHeight = 64;
    if (IS_IPAD)
    {
        headerhHeight = 64;
        viewWidth = 704;
        imgBack.frame = CGRectMake(0, 0, 704, DEVICE_HEIGHT);
        imgBack.image = [UIImage imageNamed:@"right_bg.png"];
    }
    else
    {
        headerhHeight = 64;
        if (IS_IPHONE_X)
        {
            headerhHeight = 88;
        }
        viewWidth = DEVICE_WIDTH;
        imgBack.frame = CGRectMake(0, 0, viewWidth, DEVICE_HEIGHT);
    }
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_HEIGHT-200, headerhHeight)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,viewWidth-200,headerhHeight)];
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.alpha = 0.4;
    [viewHeader addSubview:lblBack];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, viewWidth, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Messaging"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];

    UIImageView * imgDelete = [[UIImageView alloc] initWithFrame:CGRectMake(viewWidth-40, 20+(headerhHeight-20-21)/2, 20, 21)];
    [imgDelete setImage:[UIImage imageNamed:@"delete.png"]];
    [imgDelete setContentMode:UIViewContentModeScaleAspectFit];
    imgDelete.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:imgDelete];
    
    UIButton * btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDelete addTarget:self action:@selector(btnDeleteClick) forControlEvents:UIControlEventTouchUpInside];
    btnDelete.frame = CGRectMake(viewWidth-headerhHeight-40, 0, headerhHeight + 40, headerhHeight);
    btnDelete.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnDelete];

    [self setupMainContentView:headerhHeight];

    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(0, 40, DEVICE_WIDTH, 44);
//        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        imgDelete.frame = CGRectMake(viewWidth-40, 12+44, 20, 21);
        btnDelete.frame = CGRectMake(DEVICE_WIDTH-70, 0, 70, 88);
    }
    [APP_DELEGATE startHudProcess:@"Fetching details..."];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    strCurrentScreen = @"Chat";
        [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    strCurrentScreen = @"Other";
    [super viewWillDisappear:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
    [APP_DELEGATE endHudProcess];
    [self getMessagesfromDatabase];
    [super viewDidAppear:YES];
}

-(void)getMessagesfromDatabase
{
    NSMutableArray * chatDetailArr = [[NSMutableArray alloc]init];
    NSString * strMessage = [NSString stringWithFormat:@"SELECT * FROM NewChat where from_nano ='%@' or to_nano = '%@'",sc4NanoId,sc4NanoId];
    [[DataBaseManager dataBaseManager] execute:strMessage resultsArray:chatDetailArr];
    NSLog(@"Message data=%@",chatDetailArr);
    self.tableArray = [[TableArray alloc] init];

    for (int i=0; i<[chatDetailArr count]; i++)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate * dateInstalled = [dateFormatter dateFromString:[[chatDetailArr objectAtIndex:i]valueForKey:@"time"]];

        Message *message = [[Message alloc] init];
        message.text = [[chatDetailArr objectAtIndex:i]valueForKey:@"msg_txt"];
        message.sequences = [[chatDetailArr objectAtIndex:i]valueForKey:@"sequence"];
        message.date = dateInstalled;
        message.chat_id =@"1";
        if ([[[chatDetailArr objectAtIndex:i] objectForKey:@"from_name"] isEqualToString:@"Me"])
        {
            message.sender = MessageSenderMyself;
        }
        else
        {
            message.sender = MessageSenderSomeone;
        }
        message.status = MessageStatusSent;

        if ([[[chatDetailArr objectAtIndex:i] objectForKey:@"status"] isEqualToString:@"Broadcast"])
        {
            message.status = MessageStatusSent;
        }
        else if([[[chatDetailArr objectAtIndex:i] objectForKey:@"status"] isEqualToString:@"Read"])
        {
            message.status = MessageStatusRead;
        }
        else if([[[chatDetailArr objectAtIndex:i] objectForKey:@"status"] isEqualToString:@"Received"])
        {
            message.status = MessageStatusReceived;
        }
        else if([[[chatDetailArr objectAtIndex:i] objectForKey:@"status"] isEqualToString:@"Failed"])
        {
            message.status = MessageStatusFailed;
        }
        [self.tableArray addObject:message];
    }
    [tblchat reloadData];

    if ([chatDetailArr count]>0)
    {
        NSIndexPath *indexPath3 = [self.tableArray indexPathForLastMessage];
        [tblchat scrollToRowAtIndexPath:indexPath3 atScrollPosition:UITableViewScrollPositionBottom animated:false];
    }
    arrMessages = [[NSMutableArray alloc]init];
    NSString * strCanned = [NSString stringWithFormat:@"SELECT * FROM DiverMessage"];
    [[DataBaseManager dataBaseManager] execute:strCanned resultsArray:arrMessages];
}
-(void)setupMainContentView:(int)headerHeights
{
    self.tableArray = [[TableArray alloc] init];
     bottomHeight = 80;
    
    if (IS_IPHONE)
    {
        if (IS_IPHONE_X)
        {
            bottomHeight = 70 + 45;
        }
        else
        {
            bottomHeight = 60;
        }
    }
    if ([self.isFrom isEqualToString:@"History"])
    {
        bottomHeight = 0;
    }

    tblchat=[[UITableView alloc]initWithFrame:CGRectMake(0, headerHeights, viewWidth, DEVICE_HEIGHT-headerHeights-200-1)];
    tblchat.rowHeight=80;
    tblchat.delegate=self;
    tblchat.dataSource=self;
    tblchat.allowsSelection = NO;
    tblchat.backgroundColor=[UIColor clearColor];
    [tblchat setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tblchat setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:tblchat];
    
    xx=headerHeights;
    
    viewMessage = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT, viewWidth, 100)];//100 == 80
    viewMessage.backgroundColor = UIColor.greenColor;
    [self.view addSubview:viewMessage];
    
    UIImageView * img = [[UIImageView alloc] init];
    img.frame = CGRectMake(0, 0, viewWidth-0, 80);
    img.image = [UIImage imageNamed:@"msg_main_bg.png"];
    img.userInteractionEnabled = YES;
    [viewMessage addSubview:img];
    
    UILabel * lblBack = [[UILabel alloc] init];
    lblBack.frame =CGRectMake(15,10, viewWidth-120, 60);
    lblBack.backgroundColor = [UIColor blackColor];
    lblBack.userInteractionEnabled = YES;
    lblBack.layer.cornerRadius = 25;
    lblBack.layer.masksToBounds = YES;
    [img addSubview:lblBack];
    
    UIImageView * imgMsg = [[UIImageView alloc] init];
    imgMsg.frame = CGRectMake(15, 20, 24, 20);
    imgMsg.image = [UIImage imageNamed:@"messsage_icon.png"];
//    [lblBack addSubview:imgMsg];
    
    UIImageView * imgSend = [[UIImageView alloc] init];
    imgSend.frame = CGRectMake(img.frame.size.width-60-20, 15, 50, 50);
    imgSend.image = [UIImage imageNamed:@"send_icon.png"];
    [img addSubview:imgSend];
    
    lblChatText = [[UILabel alloc] init];
    lblChatText.frame =CGRectMake(70, 100, viewWidth-120-75, 80);
    lblChatText.backgroundColor = [UIColor clearColor];
    lblChatText.userInteractionEnabled = YES;
    lblChatText.textColor = UIColor.whiteColor;
    lblChatText.font = [UIFont fontWithName:CGRegular size:textSize];
    lblChatText.text = @"Enter message";
//    [img addSubview:lblChatText];
    
    UIButton * btnMsgSelec = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMsgSelec.frame = CGRectMake(0, 0, viewWidth-120, 80);
    [btnMsgSelec addTarget:self action:@selector(msgSelectionClick) forControlEvents:UIControlEventTouchUpInside];
    btnMsgSelec.backgroundColor = [UIColor clearColor];
    [img addSubview:btnMsgSelec];
    
    txtChat = [[UITextField alloc]init];
    txtChat.frame = CGRectMake(30, 0,viewWidth-100-30, 80);
    txtChat.textAlignment = NSTextAlignmentLeft;
//    txtChat.backgroundColor = UIColor.redColor;
    txtChat.autocorrectionType = UITextAutocorrectionTypeNo;
    txtChat.placeholder = @"Enter message";
    txtChat.delegate = self;
    txtChat.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtChat.textColor = UIColor.whiteColor;
    txtChat.font = [UIFont fontWithName:CGRegular size:textSize];
    txtChat.keyboardType = UIKeyboardTypeDefault;
    txtChat.returnKeyType = UIReturnKeyDone;
    txtChat.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Name" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:textSize]}];
    [img addSubview:txtChat];

//    [txtChat setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    UIButton * btnMsgSend = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMsgSend.frame = CGRectMake(viewWidth-125, 0, 125, 80);
    [btnMsgSend addTarget:self action:@selector(sendMessageClick) forControlEvents:UIControlEventTouchUpInside];
    [img addSubview:btnMsgSend];
 
    if (IS_IPHONE)
    {
        viewMessage.frame = CGRectMake(0, DEVICE_HEIGHT-bottomHeight-50, viewWidth-0, 60);

        img.frame = CGRectMake(0, 0, viewWidth-0, 60);
        if (IS_IPHONE_X)
        {
            tblchat.frame = CGRectMake(0, headerHeights, viewWidth, DEVICE_HEIGHT-headerHeights-bottomHeight+15);
            viewMessage.frame = CGRectMake(0, DEVICE_HEIGHT-100, viewWidth-0, 60);
        }
        lblBack.frame =CGRectMake(5,10, viewWidth-60, 40);
        lblBack.layer.cornerRadius = 20;
        imgMsg.frame = CGRectMake(5, 10, 24, 20);
        imgSend.frame = CGRectMake(img.frame.size.width-45, 10, 40, 40);
        btnMsgSend.frame = CGRectMake(viewWidth-65, 0, 65, 60);
        txtChat.frame = CGRectMake(30, 0,DEVICE_WIDTH-65-30, 60);
        btnMsgSelec.frame = CGRectMake(0, 0, 65, 60);

    }
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView==tblMessages)
    {
        return 1;
    }
    return [self.tableArray numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==tblMessages)
    {
        return [arrMessages count];
    }
    return [self.tableArray numberOfMessagesInSection:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==tblMessages)
    {
        NSString *cellIdentifier = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[LeftMenuCell alloc]initWithStyle:
                    UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        NSString * str = [NSString stringWithFormat:@" %@. %@",[[arrMessages objectAtIndex:indexPath.row] valueForKey:@"indexStr"],[[arrMessages objectAtIndex:indexPath.row] valueForKey:@"Message"]];
        cell.lblName.text= str;
        cell.lblName.textColor=[UIColor whiteColor];
        cell.lblLine.hidden = YES;
        cell.lblName.frame= CGRectMake(10, 0, DEVICE_WIDTH, 50);
        
        if (IS_IPHONE)
        {
            cell.lblName.font=[UIFont fontWithName:CGRegular size:textSize];
        }
        return cell;
    }
    static NSString *CellIdentifier = @"MessageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.message = [self.tableArray objectAtIndexPath:indexPath];
    cell.resendButton.tag = indexPath.row;
    [cell.resendButton addTarget:self action:@selector(btnResendClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView == tblMessages)
    {
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_bg.png"]];
    }
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==tblMessages)
    {
        return 50;
    }
    Message *message = [self.tableArray objectAtIndexPath:indexPath];
    return message.heigh;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (IS_IPAD)
    {
        return 40.0;
    }
    else
    {
        return 40.0;
    }
    return 40.0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView==tblMessages)
    {
        return @"Select any message to send";
    }
    return [self.tableArray titleForSection:section];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
    if (IS_IPAD)
    {
       frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
    }
    else
    {
        frame = CGRectMake(0, 0, tableView.frame.size.width,40);
    }
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:CGRegular size:textSize+5];
    [label sizeToFit];
    label.center = view.center;
    label.font = [UIFont fontWithName:CGRegular size:textSize];
    label.backgroundColor = [UIColor colorWithRed:207/255.0 green:220/255.0 blue:252.0/255.0 alpha:1];
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.autoresizingMask = UIViewAutoresizingNone;
    [view addSubview:label];
    
    if (IS_IPHONE)
    {
        label.font = [UIFont fontWithName:CGRegular size:textSize-1];
    }
    if (tableView == tblMessages)
    {
        label.text = @"Select message to send";
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor blackColor];

        label.frame = CGRectMake(20, 0, tableView.frame.size.width, 40);
        view.backgroundColor = [UIColor blackColor];
        
        UIFontDescriptor *fontDescriptor1 = [UIFontDescriptor fontDescriptorWithName:CGBold size:textSize];
        UIFontDescriptor *symbolicFontDescriptor1 = [fontDescriptor1 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        
        NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:@"* Select message to send"];
        UIFont *fontWithDescriptor = [UIFont fontWithDescriptor:fontDescriptor1 size:textSize+3];
        UIFont *fontWithDescriptor1 = [UIFont fontWithDescriptor:symbolicFontDescriptor1 size:textSize];
        UIFont *fontWithDescriptor2 = [UIFont fontWithDescriptor:symbolicFontDescriptor1 size:textSize];
        
        [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor1, NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, hintText.length)];
        [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor, NSForegroundColorAttributeName:[UIColor redColor]} range:NSMakeRange(0, 1)];
        [hintText setAttributes:@{NSFontAttributeName:fontWithDescriptor2, NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(8, 9)];
        
        [label setAttributedText:hintText];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont fontWithName:CGRegular size:textSize];
        
        view.backgroundColor = [UIColor blackColor];
    }
    
    return view;
}
- (void)tableViewScrollToBottomAnimated:(BOOL)animated
{
    NSInteger numberOfSections = [self.tableArray numberOfSections];
    NSInteger numberOfRows = [self.tableArray numberOfMessagesInSection:numberOfSections-1];
    if (numberOfRows)
    {
        [tblchat scrollToRowAtIndexPath:[self.tableArray indexPathForLastMessage]
                          atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblMessages)
    {
        isFreeText = NO;
        msgIndex = [[arrMessages objectAtIndex:indexPath.row] valueForKey:@"indexStr"];
//        if ([txtChat.text isEqualToString:@""])
        {
            lblChatText.text = [[arrMessages objectAtIndex:indexPath.row] valueForKey:@"Message"];
        }
//        else
//        {
//            txtChat.text = [NSString stringWithFormat:@"%@ %@",txtChat.text,[[arrMessages objectAtIndex:indexPath.row] valueForKey:@"Message"]];
//
//        }
        [self hideMorePopUpView:YES];
        
    }
    
}

#pragma mark - UITextfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField == txtChat)
    {
        [txtChat resignFirstResponder];
    }
    return true;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    viewMessage.frame = CGRectMake(0, DEVICE_HEIGHT-bottomHeight-230, viewWidth-0, 60);
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    viewMessage.frame = CGRectMake(0, DEVICE_HEIGHT-bottomHeight-50, viewWidth-0, 60);
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    if (textField == txtChat)
    {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 18;
    }
    return YES;
}
- (void)scrollToBottom
{
    CGFloat yOffset = 0;
    
    if (tblchat.contentSize.height > tblchat.bounds.size.height) {
        yOffset = tblchat.contentSize.height - tblchat.bounds.size.height;
    }
    
    [tblchat setContentOffset:CGPointMake(0, yOffset) animated:true];
}
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"NA";
        }
    }
    else
    {
        strValid = @"NA";
    }
    return strValid;
}
#pragma mark - Button EVent
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)btnDeleteClick
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert addButton:@"Yes" withActionBlock:^{
        NSLog(@"Custom Font Button Pressed");
        // Put your action here
        [self deleteMessagesfromDatabase];
    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSize];
    [alert showAlertInView:self
                 withTitle:@"Combat Diver"
              withSubtitle:@"Are you sure want to delete message history ?"
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
}
-(void)btnCloseClick
{
//    [self hideMorePopUpView:YES];
}
-(void)OverLayTaped:(id)sender
{
    NSLog(@"Tapped");
    [self hideMorePopUpView:YES];
}
-(void)msgSelectionClick
{
    [self ShowPicker:false andView:viewMessage];
    [self showMessageList];
}
-(void)deleteMessagesfromDatabase
{
    NSString * strDelete = [NSString stringWithFormat:@"Delete from NewChat where from_nano ='%@' or to_nano = '%@'",sc4NanoId,sc4NanoId];
    [[DataBaseManager dataBaseManager]execute:strDelete];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"historyRefresh" object:nil];
    NSString * strUpdate = [NSString stringWithFormat:@"update NewContact set msg = '' where SC4_nano_id = '%@'",sc4NanoId];//KP13-04-2015.
    [[DataBaseManager dataBaseManager]execute:strUpdate];
    
    [self.tableArray removeAllObjects];
    self.tableArray = [[TableArray alloc] init];
    [tblchat reloadData];
}
-(void)sendMessageClick
{
    if ([txtChat.text isEqual:@""])
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"Geofence"
                  withSubtitle:@"Please enter any message"
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    else
    {
        if (globalPeripheral.state == CBPeripheralStateConnected)
        {
            globalSequence = [self GetUniqueNanoModemId];
            NSInteger sequenceInt = [globalSequence integerValue]; //Unique Sequence No
            NSData * sequencData = [[NSData alloc] initWithBytes:&sequenceInt length:4];
            NSString * strSqnc = [NSString stringWithFormat:@"%@",sequencData];
            strSqnc = [strSqnc stringByReplacingOccurrencesOfString:@" " withString:@""];
            strSqnc = [strSqnc stringByReplacingOccurrencesOfString:@"<" withString:@""];
            strSqnc = [strSqnc stringByReplacingOccurrencesOfString:@">" withString:@""];

            Message *message = [[Message alloc] init];
            message.text = lblChatText.text;
            message.date = [NSDate date];
            message.chat_id =@"1";
            message.sender = MessageSenderMyself;
            message.status = MessageStatusSent;
            message.sequences = [NSString stringWithFormat:@"%@",strSqnc];
            [self.tableArray addObject:message];
            
            [tblchat reloadData];
            [self sendMessagetoDevice];
            
            NSIndexPath *indexPath3 = [self.tableArray indexPathForLastMessage];
            [tblchat scrollToRowAtIndexPath:indexPath3 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeWarning];
            [alert addButton:@"Go to Connect Device" withActionBlock:^
            {
                [self.navigationController popViewControllerAnimated:true];
            }];
            [alert showAlertInView:self
                         withTitle:@"Geofence"
                      withSubtitle:@"Device is not connected. Please connect first."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
}
-(void)btnResendClick:(id)sender
{
    
}

#pragma mark - BLE Methods EVent
-(void)sendMessagetoDevice
{
    if (isFreeText)
    {
        NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
        NSString * strQuery = [NSString stringWithFormat:@"select * from DiverMessage where Message = '%@'",lblChatText.text];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArr];
        if ([tmpArr count]>0)
        {
            isFreeText = NO;
            msgIndex = [[tmpArr objectAtIndex:0] valueForKey:@"indexStr"];
        }
    }
    
    [self ShowPicker:false andView:viewMessage];
    
    NSInteger cmdInt = [@"05" integerValue]; //Command
    NSData * cmdData = [[NSData alloc] initWithBytes:&cmdInt length:1];

    NSInteger lengthInt = [@"06" integerValue]; //length of Message
    NSData * lengthData = [[NSData alloc] initWithBytes:&lengthInt length:1];

    NSInteger nanoInt = [sc4NanoId integerValue]; //Nano Modem ID
    NSData * nanoData = [[NSData alloc] initWithBytes:&nanoInt length:4];

    NSInteger opcodeInt = [@"01" integerValue]; //Opcode
    NSData * opcodeData = [[NSData alloc] initWithBytes:&opcodeInt length:1];

    NSInteger dataInt=  [msgIndex integerValue]; // Message data
    NSData * dataData = [[NSData alloc] initWithBytes:&dataInt length:1];
    
    NSInteger sequenceInt = [globalSequence integerValue]; //Unique Sequence No
    NSData * sequencData = [[NSData alloc] initWithBytes:&sequenceInt length:4];

    NSMutableData *completeData = [cmdData mutableCopy];
    [completeData appendData:lengthData];
    [completeData appendData:nanoData];
    [completeData appendData:opcodeData];
    [completeData appendData:dataData];
    [completeData appendData:sequencData];

//    [[BLEService sharedInstance] writeValuetoDevice:completeData with:globalPeripheral];
    NSLog(@"Sent Msg from Chat >>>%@",completeData);

    double dateStamp = [[NSDate date] timeIntervalSince1970];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString * timeStr =[dateFormatter stringFromDate:[NSDate date]];
    NSString * strSqnc = [NSString stringWithFormat:@"%@",sequencData];
    strSqnc = [strSqnc stringByReplacingOccurrencesOfString:@" " withString:@""];
    strSqnc = [strSqnc stringByReplacingOccurrencesOfString:@"<" withString:@""];
    strSqnc = [strSqnc stringByReplacingOccurrencesOfString:@">" withString:@""];

    NSString * strInsertCan = [NSString stringWithFormat:@"insert into 'NewChat' ('from_name','from_nano','to_name','to_nano','msg_id','msg_txt','time','status','timeStamp','sequence') values ('%@','%@','%@','%@','%@','%@','%@','%@','%f','%@')",@"Me",sc4NanoId,userName,sc4NanoId,msgIndex,lblChatText.text,timeStr,@"Sent",dateStamp, strSqnc];
    [[DataBaseManager dataBaseManager] execute:strInsertCan];

    NSString * strUpdate = [NSString stringWithFormat:@"update NewContact set msg ='%@', time='%@' where SC4_nano_id='%@'",lblChatText.text,timeStr,sc4NanoId];
    [[DataBaseManager dataBaseManager] execute:strUpdate];

    /*FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    [alert showAlertInView:self
                 withTitle:@"Combat Diver"
              withSubtitle:@"Message has been sent successfully."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];*/
    lblChatText.text = @"Enter message";
}
#pragma mark - View for Choosing Contacts
-(void)showMessageList
{
    [viewOverLay removeFromSuperview];
    viewOverLay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, DEVICE_HEIGHT)];
    [viewOverLay setBackgroundColor:[UIColor colorWithRed:97/255.0f green:97/255.0f blue:97/255.0f alpha:0.5]];
    viewOverLay.userInteractionEnabled = YES;
    [self.view addSubview:viewOverLay];
    
    backContactView = [[UIImageView alloc] init];
    backContactView.frame = CGRectMake(80, DEVICE_HEIGHT, viewWidth-160, 660);
    backContactView.image = [UIImage imageNamed:@"pop_up_bg.png"];
    backContactView.userInteractionEnabled = YES;
    [self.view addSubview:backContactView];
    
    UILabel * lblTitle = [[UILabel alloc] init];
    lblTitle.frame = CGRectMake(0, 30, backContactView.frame.size.width, 50);
    lblTitle.font = [UIFont fontWithName:CGRegular size:textSize];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.text = @"Select Message";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [backContactView addSubview:lblTitle];
    
    UILabel * lblline = [[UILabel alloc] init];
    lblline.frame = CGRectMake(34, 30+49, backContactView.frame.size.width-68, 0.5);
    lblline.backgroundColor = [UIColor lightGrayColor];
    [backContactView addSubview:lblline];
    
    UIButton * btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(20, 30, 120, 50);
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize-1];
    [btnCancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [backContactView addSubview:btnCancel];
    
    UIButton * btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDone.frame = CGRectMake(backContactView.frame.size.width-130, 30, 100, 50);
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize-1];
    [btnDone setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [backContactView addSubview:btnDone];
    
    tblMessages=[[UITableView alloc]init];
    tblMessages.delegate=self;
    tblMessages.dataSource=self;
    tblMessages.frame = CGRectMake(27, 80, backContactView.frame.size.width-54, backContactView.frame.size.height-60-60);
    tblMessages.backgroundColor=[UIColor blueColor];
    [tblMessages setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tblMessages setSeparatorColor:[UIColor clearColor]];
    [backContactView addSubview:tblMessages];
    
    if (IS_IPHONE)
    {
        backContactView.image = [UIImage imageNamed:@" "];
        backContactView.backgroundColor = [UIColor blackColor];
        backContactView.layer.cornerRadius = 10;
        backContactView.layer.borderWidth = 1.0;
        backContactView.layer.masksToBounds = YES;
//        backContactView.frame = CGRectMake(20, DEVICE_HEIGHT, viewWidth-40, DEVICE_HEIGHT-80);
        lblTitle.frame = CGRectMake(0, 0, backContactView.frame.size.width, 50);
        lblline.frame = CGRectMake(10, 49, backContactView.frame.size.width-20, 0.5);
        btnCancel.frame = CGRectMake(0, 0, 60, 50);
        btnDone.frame = CGRectMake(backContactView.frame.size.width-60, 0, 60, 50);
        tblMessages.frame = CGRectMake(0, 50, backContactView.frame.size.width-0, DEVICE_HEIGHT-80-50);
        if (IS_IPHONE_5 || IS_IPHONE_4)
        {
            backContactView.frame = CGRectMake(10, DEVICE_HEIGHT, viewWidth-20, DEVICE_HEIGHT-80);
            tblMessages.frame = CGRectMake(0, 50, backContactView.frame.size.width-0, DEVICE_HEIGHT-80-50);
        }
    }
    [self hideMorePopUpView:NO];
    
}
-(void)hideMorePopUpView:(BOOL)isHide
{
    if (isHide == YES)
    {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options: UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             if (IS_IPHONE)
                             {
                                 if (IS_IPHONE_5 || IS_IPHONE_4)
                                 {
                                    self-> backContactView.frame = CGRectMake(10, DEVICE_HEIGHT, self->viewWidth-20, DEVICE_WIDTH-80);
                                 }
                                 else
                                 {
                                     self->backContactView.frame = CGRectMake(20, DEVICE_HEIGHT, self->viewWidth-40, DEVICE_WIDTH-80);
                                 }
                             }
                             else
                             {
                                 self->backContactView.frame = CGRectMake(80, DEVICE_HEIGHT, self->viewWidth-160, 660);
                             }
                         }
                         completion:^(BOOL finished){
                             [self->viewOverLay removeFromSuperview];
                             [self->backContactView removeFromSuperview];
                             [self->tblMessages removeFromSuperview];
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             if (IS_IPHONE)
                             {
                                 if (IS_IPHONE_5 || IS_IPHONE_4)
                                 {
                                     self->backContactView.frame = CGRectMake(10, 40, self->viewWidth-20, DEVICE_HEIGHT-80);
                                 }
                                 else
                                 {
                                     self->backContactView.frame = CGRectMake(20, 40, self->viewWidth-40, DEVICE_HEIGHT-80);
                                 }
                             }
                             else
                             {
                                 self->backContactView.frame = CGRectMake(80, 54, self->viewWidth-160, 660);
                             }
                         }
                         completion:^(BOOL finished){
                         }];
    }
}
#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.2
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            
                            if (myView == self->viewMessage)
                            {
                                self->viewMessage.frame = CGRectMake(0,DEVICE_HEIGHT-self->intkeyboardHeight-self->bottomHeight, self->viewWidth-0, 80);

                                NSLog(@"hhh is %f",DEVICE_HEIGHT-self->intkeyboardHeight);
                            }
            if (myView == self->tblchat) {
                self->tblchat.frame = CGRectMake(0, self->xx, self->viewWidth, DEVICE_HEIGHT-self->xx-self->bottomHeight-self->intkeyboardHeight);
//                                tblchat.backgroundColor = UIColor.redColor;
                            }
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.2
                           options:UIViewAnimationOptionCurveEaseOut
                        animations:^{
                            
                            if (myView == self->viewMessage)
                            {
                                self->viewMessage.frame = CGRectMake(0,DEVICE_HEIGHT-self->bottomHeight, self->viewWidth-0, 80);
                            }
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}
- (void)keyboardWasShown:(NSNotification *)notification
{
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    intkeyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    //    int width = MAX(keyboardSize.height,keyboardSize.width);
    //your other code here..........
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)hexFromStr:(NSString*)str
{
    NSData* nsData = [str dataUsingEncoding:NSUTF8StringEncoding];
    const char* data = [nsData bytes];
    NSUInteger len = nsData.length;
    NSMutableString* hex = [NSMutableString string];
    for(int i = 0; i < len; ++i)
        [hex appendFormat:@"%02X", data[i]];
    return hex;
}
- (NSData *)dataFromHexString:(NSString*)hexStr
{
    const char *chars = [hexStr UTF8String];
    NSInteger i = 0, len = hexStr.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}
-(void)GotMessagefromDiver:(NSMutableDictionary *)strDict;
{
    if (strDict)
    {
        if (![[APP_DELEGATE checkforValidString:[strDict valueForKey:@"nanoId"]] isEqualToString:@"NA"])
        {
            if ([[strDict valueForKey:@"nanoId"] isEqualToString:sc4NanoId])
            {
                Message *message = [[Message alloc] init];
                message.text = [APP_DELEGATE checkforValidString:[strDict valueForKey:@"msg_txt"]];
                message.date = [NSDate date];
                message.chat_id =@"1";
                message.sender = MessageSenderSomeone;
                message.status = MessageStatusReceived;
                [self.tableArray addObject:message];
                [tblchat reloadData];
                NSIndexPath *indexPath3 = [self.tableArray indexPathForLastMessage];
                [tblchat scrollToRowAtIndexPath:indexPath3 atScrollPosition:UITableViewScrollPositionBottom animated:false];
            }
        }
    }
}
-(void)GotMessageSendAck:(NSString *)strStatus;
{
    if ([strStatus isEqualToString:@"010130"])
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        [alert showAlertInView:self
                     withTitle:@"Combat Diver"
                  withSubtitle:@"Message has been sent successfully."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];

    }
    else
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeWarning];
        [alert showAlertInView:self
                     withTitle:@"Combat Diver"
                  withSubtitle:@"Something went wrong. Please try again."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];

    }
}
-(void)GotSentMessageAcknowledgement:(NSString *)strSeqence withStatus:(NSString *)strStatus
{
    for (int i =0; i<[self.tableArray numberOfSections]; i++)
    {
        for (int k = 0; k < [self.tableArray numberOfMessagesInSection:i]; k++)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:k inSection:i];
            Message * message = [[Message alloc] init];
            message = [self.tableArray objectAtIndexPath:indexPath];
//            NSLog(@"Sent Sqnc=%@ ArrSeqn=%@",strSeqence,message.sequences);
            if ([message.sequences isEqualToString:strSeqence])
            {
                if ([strStatus isEqualToString:@"32"])
                {
                    [[self.tableArray objectAtIndexPath:indexPath] setStatus:MessageStatusRead];
                }
                else if([strStatus isEqualToString:@"31"])
                {
                    [[self.tableArray objectAtIndexPath:indexPath] setStatus:MessageStatusReceived];
                }
                else if([strStatus isEqualToString:@"33"])
                {
                    [[self.tableArray objectAtIndexPath:indexPath] setStatus:MessageStatusFailed];
                    NSString * strUser = @"User";
                    if (![[self checkforValidString:userName] isEqualToString:@"NA"])
                    {
                        strUser = userName;
                    }
                    NSString * strMsg = [NSString stringWithFormat:@"%@ did not recieve message : %@. Please try again later.",strUser,message.text];
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    alert.colorScheme = [UIColor blackColor];
                    [alert makeAlertTypeWarning];
                    [alert showAlertInView:self
                                 withTitle:@"Message Sent Failed"
                              withSubtitle:strMsg
                           withCustomImage:[UIImage imageNamed:@"logo.png"]
                       withDoneButtonTitle:nil
                                andButtons:nil];
                }
                break;
            }
        }
    }
    [tblchat reloadData];
}
-(NSString *)GetUniqueNanoModemId
{
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSString * strTime = [NSString stringWithFormat:@"%f",timeInSeconds];
    strTime = [strTime stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString * strData ;
    if ([strTime length]>=16)
    {
        strTime = [strTime substringWithRange:NSMakeRange([strTime length]-8, 8)];
        int intVal = [strTime intValue];
        NSData * lineLightNanoData = [[NSData alloc] initWithBytes:&intVal length:4];
        strData = [NSString stringWithFormat:@"%@",lineLightNanoData];
        strData = [strTime stringByReplacingOccurrencesOfString:@" " withString:@""];
        strData = [strTime stringByReplacingOccurrencesOfString:@"<" withString:@""];
        strData = [strTime stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        NSLog(@"got starData=%@",strData);
        
        if([[strData substringWithRange:NSMakeRange(0,2)] isEqualToString:@"00"])
        {
            strTime = [NSString stringWithFormat:@"88%@",[strTime substringWithRange:NSMakeRange(2,6)]];
        }
        else if([[strData substringWithRange:NSMakeRange(6,2)] isEqualToString:@"00"])
        {
            strTime = [NSString stringWithFormat:@"%@99",[strTime substringWithRange:NSMakeRange(0,6)]];
        }
    }
    return strTime;
}
-(void)setDummyDataforTable
{
    self.tableArray = [[TableArray alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //    NSDate * dateInstalled = [dateFormatter dateFromString:@"2018-12-12 11:09:04"];
    NSDate *today = [NSDate date];
    NSData * yDate  = [today dateByAddingTimeInterval: -86400.0];
    
    Message *message = [[Message alloc] init];
    message.text = @"Go";
    message.date = yDate;
    message.chat_id =@"1";
    message.sender = MessageSenderMyself;
    message.status = MessageStatusReceived;
    [self.tableArray addObject:message];
    
    Message *message1 = [[Message alloc] init];
    message1.text = @"Ok";
    message1.date = yDate;
    message1.chat_id =@"1";
    message1.sender = MessageSenderSomeone;
    [self.tableArray addObject:message1];
    
    Message *message2 = [[Message alloc] init];
    message2.text = @"Low Air";
    message2.date = yDate;
    message2.chat_id =@"1";
    message2.sender = MessageSenderSomeone;
    [self.tableArray addObject:message2];
    
    Message *message3 = [[Message alloc] init];
    message3.text = @"Stop";
    message3.date = yDate;
    message3.chat_id =@"1";
    message3.sender = MessageSenderMyself;
    message3.status = MessageStatusReceived;
    [self.tableArray addObject:message3];
    
    Message *message4 = [[Message alloc] init];
    message4.text = @"Complete";
    message4.date = yDate;
    message4.chat_id =@"1";
    message4.sender = MessageSenderSomeone;
    [self.tableArray addObject:message4];
    
    Message *message5 = [[Message alloc] init];
    message5.text = @"Training Complete";
    message5.date = yDate;
    message5.chat_id =@"1";
    message5.sender = MessageSenderMyself;
    message5.status = MessageStatusReceived;
    [self.tableArray addObject:message5];
    
    Message *message6 = [[Message alloc] init];
    message6.text = @"Training Complete";
    message6.date = yDate;
    message6.chat_id =@"1";
    message6.sender = MessageSenderSomeone;
    [self.tableArray addObject:message6];
    
    
    
    //    for (int i=0; i<20; i++)
    //    {
    //        Message *message23 = [[Message alloc] init];
    //        message23.text = @"Training Complete";
    //        message23.date = [NSDate date];
    //        message23.chat_id =@"1";
    //        message23.sender = MessageSenderSomeone;
    //        [self.tableArray addObject:message23];
    //    }
    
    [tblchat reloadData];
    //Store Message in memory
}
@end
/*
 2020-02-28 18:06:07.422 Combat Diver[1211:302999] didUpdateValueForCharacteristic==<050b0469 301e0109 0c165c02 32>
 2020-02-28 18:06:07.423 Combat Diver[1211:302999] ----->>>>>>>Sequence No---->0c165c02
 2020-02-28 18:06:12.030 Combat Diver[1211:302999] didUpdateValueForCharacteristic==<050b0469 301e0109 71d7ad01 32>
 2020-02-28 18:06:12.031 Combat Diver[1211:302999] ----->>>>>>>Sequence No---->71d7ad01
 2020-02-28 18:06:16.004 Combat Diver[1211:302999] didUpdateValueForCharacteristic==<050b0469 301e0106 df5b6500 32>
 2020-02-28 18:06:16.006 Combat Diver[1211:302999] ----->>>>>>>Sequence No---->df5b6500
 2020-02-28 18:06:20.198 Combat Diver[1211:302999] didUpdateValueForCharacteristic==<050b0469 301e0107 a9391d00 32>
 2020-02-28 18:06:20.199 Combat Diver[1211:302999] ----->>>>>>>Sequence No---->a9391d00
 2020-02-28 18:06:24.218 Combat Diver[1211:302999] didUpdateValueForCharacteristic==<050b0469 301e0109 03cf9a05 32>
 2020-02-28 18:06:24.219 Combat Diver[1211:302999] ----->>>>>>>Sequence No---->03cf9a05
 2020-02-28 18:06:28.328 Combat Diver[1211:302999] didUpdateValueForCharacteristic==<050b0469 301e0106 effdb403 32>
 2020-02-28 18:06:28.329 Combat Diver[1211:302999] ----->>>>>>>Sequence No---->effdb403
 2020-02-28 18:06:32.348 Combat Diver[1211:302999] didUpdateValueForCharacteristic==<050b0469 301e0106 c7886302 32>
 2020-02-28 18:06:32.349 Combat Diver[1211:302999] ----->>>>>>>Sequence No---->c7886302
 2020-02-28 18:06:36.428 Combat Diver[1211:302999] didUpdateValueForCharacteristic==<050b0469 301e0102 b4d3d703 32>
 2020-02-28 18:06:36.429 Combat Diver[1211:302999] ----->>>>>>>Sequence No---->b4d3d703
 2020-02-28 18:06:50.288 Combat Diver[1211:302999] didUpdateValueForCharacteristic==<05060000 00000864>
 
 */
