//
//  SettingVC.m
//  GeofenceAlertApp
//
//  Created by Ashwin on 8/31/20.
//  Copyright © 2020 srivatsa s pobbathi. All rights reserved.
//

#import "SettingVC.h"
#import "SettingCell.h"

@import iOSDFULibrary;


@interface SettingVC ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,LoggerDelegate,DFUServiceDelegate,DFUProgressDelegate,DFUPeripheralSelectorDelegate,UIDocumentPickerDelegate>
{
    UIView * viewBGPicker;
    UIPickerView * pickerSetting;
    NSString *selectedFromPicker;
    NSMutableArray * arrayPickr;
}
@end

@implementation SettingVC

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    
    
    [self setNavigationViewFrames];
    arrayPickr =[[NSMutableArray alloc]initWithObjects:@"10 M",@"20 M",@"30 M", nil];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [APP_DELEGATE showTabBar:self.tabBarController];
    [super viewWillAppear:YES];
    [tblSetting reloadData];
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    int yy = 44;
    if (IS_IPHONE_X)
    {
        yy = 44;
    }

    UIImageView * imgLogo = [[UIImageView alloc] init];
    imgLogo.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgLogo.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgLogo.userInteractionEnabled = YES;
    [self.view addSubview:imgLogo];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy + globalStatusHeight)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, globalStatusHeight, DEVICE_WIDTH-100, yy)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Settings"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];

    
    tblSetting = [[UITableView alloc] initWithFrame:CGRectMake(0, yy+globalStatusHeight+20, DEVICE_WIDTH, DEVICE_HEIGHT-yy-globalStatusHeight)];
    tblSetting.delegate = self;
    tblSetting.dataSource= self;
    tblSetting.backgroundColor = UIColor.clearColor;
    tblSetting.separatorStyle = UITableViewCellSelectionStyleNone;
    tblSetting.hidden = false;
    [self.view addSubview:tblSetting];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  2; // array have to pass
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
        SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        if (cell == nil)
        {
            cell = [[SettingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
        }
    

         if (indexPath.row == 0)
        {
            cell.lblForSetting.text = @"Time interval for Buzzer";
            cell.lblSetValue.text = selectedFromPicker;
        }
        else if (indexPath.row == 1)
        {
            cell.lblForSetting.text = @"update firmware";
        }
    
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
      return cell;
    }
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (indexPath.row == 0)
    {
        [self setupForSettingPicker];
        [APP_DELEGATE hideTabBar:self.tabBarController];
        [super viewWillAppear:YES];
        
    }
    else if (indexPath.row == 1)
    {
        [self OpenFileManager];;
    }

}
#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    int viewHeight = 250;
    if (IS_IPHONE_4)
    {
        viewHeight = 230;
    }
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.4
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT-viewHeight,DEVICE_WIDTH, viewHeight)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.4
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
            [myView setFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, viewHeight)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}
-(void)setupForSettingPicker
{
    [viewBGPicker removeFromSuperview];
    
    viewBGPicker = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 250)];
    [viewBGPicker setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:viewBGPicker];
    
    [pickerSetting removeFromSuperview];
    pickerSetting = nil;
    pickerSetting.delegate=nil;
    pickerSetting.dataSource=nil;
    pickerSetting = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 34, DEVICE_WIDTH, 216)];
    [pickerSetting setBackgroundColor:[UIColor blackColor]];
    pickerSetting.tag=123;
    [pickerSetting setDelegate:self];
    [pickerSetting setDataSource:self];
    NSInteger indexSelctTemp = [[NSUserDefaults standardUserDefaults] integerForKey:@"IndexTime"];
    [pickerSetting selectRow:indexSelctTemp inComponent:0 animated:YES];

    [viewBGPicker addSubview:pickerSetting];
    
//    UILabel * lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, viewListBattry.frame.size.width, 1)];
//    lblLine.backgroundColor = UIColor.lightGrayColor;
//    [viewListBattry addSubview:lblLine];
    
    
    UIButton * btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(0 , 0, DEVICE_WIDTH, 44)];
    [btnDone setBackgroundImage:[UIImage imageNamed:@"BTN.png"] forState:UIControlStateNormal];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [btnDone setTag:123];
    [btnDone addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewBGPicker addSubview:btnDone];
    
  [self ShowPicker:YES andView:viewBGPicker];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arrayPickr.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
     return [arrayPickr objectAtIndex:row];
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;

    if (!pickerLabel)
    {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.textAlignment=NSTextAlignmentCenter;
        pickerLabel.font = [UIFont fontWithName:CGRegular size:textSize];
        pickerLabel.textColor = UIColor.whiteColor;
        
    }
    [pickerLabel setText:[arrayPickr objectAtIndex:row]];

    return pickerLabel;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedFromPicker = [arrayPickr objectAtIndex:row];
}
-(void)btnDoneClicked:(id)sender
{
    if ([[APP_DELEGATE checkforValidString:selectedFromPicker] isEqualToString:@"NA"])
    {
        NSInteger index = [pickerSetting selectedRowInComponent:0];
        
        if (index == -1)
        {
            selectedFromPicker = [NSString stringWithFormat:@"%ld",(long)index];
        }
        else
        {
            selectedFromPicker = [arrayPickr objectAtIndex:0];
        }
    }
    [self ShowPicker:NO andView:viewBGPicker];
    [APP_DELEGATE showTabBar:self.tabBarController];
    [super viewWillAppear:YES];
    [self selctedIndexTime:selectedFromPicker];
    [tblSetting reloadData];
}
-(void)selctedIndexTime:(NSString *)strTempSelect
{
    if ([strTempSelect isEqual:@"10 M"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"IndexTime"];
    }
    else if ([strTempSelect isEqual:@"20 M"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"IndexTime"];
    }
    else if ([strTempSelect isEqual:@"30 M"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"IndexTime"];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self ShowPicker:NO andView:viewBGPicker];
}
#pragma mark-DFU  Firmaware update
-(void)OpenFileManager
{
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.item"]
                      inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:documentPicker animated:YES completion:nil];
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    NSLog(@"FilePath======>>>>>>>%@",urls);
    
    NSString * result = [[urls valueForKey:@"description"] componentsJoinedByString:@""];//description
    NSString * strfilePath =  [result substringWithRange:NSMakeRange(8, result.length-8)];
    
    NSURL *uRL = [NSURL URLWithString:strfilePath];
    DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:uRL type:DFUFirmwareTypeApplication];
    NSLog(@"Selected Firmware========>>>>>>>%@",selectedFirmware);
  
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithQueue:queue];
    [initiator withFirmware:selectedFirmware];
    
    initiator.logger = self; //
    initiator.delegate = self; //
    initiator.progressDelegate = self;
    DFUServiceController * controller1 = [initiator startWithTarget:globalPeripheral];
    [APP_DELEGATE startHudProcess:@"Updating..."];

}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    
}
- (void)dfuStateDidChangeTo:(enum DFUState)state
{
    
}
- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond
{
    
}
- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString *)message
{
    
}
-(void)logWith:(enum LogLevel)level message:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"LogWith Message=%@",message);
    
//    if ([[APP_DELEGATE checkforValidString:message] isEqualToString:@"=Upload completed in"])
//    {
        [APP_DELEGATE endHudProcess];
//    }
    });
}

@end
