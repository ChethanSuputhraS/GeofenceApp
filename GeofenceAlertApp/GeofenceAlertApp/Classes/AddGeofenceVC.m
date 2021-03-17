//
//  AddGeofenceVC.m
//  GeofenceAlertApp
//
//  Created by srivatsa s pobbathi on 13/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "AddGeofenceVC.h"
#import "PolygonGeofenceVC.h"
#import "ViewController.h"
@interface AddGeofenceVC ()
{
    UILabel *lblCircular, * lblPolygon;
}
@end

@implementation AddGeofenceVC
@synthesize isFromEdit,dictEditGeofence;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dictGeofenceInfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"NA",@"name",@"NA",@"radius",@"NA",@"type", nil];
    [self setNavigationViewFrames];
    [self setContentViewFrames];

    // Do any additional setup after loading the view.
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    UIImageView * imgLogo = [[UIImageView alloc] init];
    imgLogo.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgLogo.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgLogo.userInteractionEnabled = YES;
    [self.view addSubview:imgLogo];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];

    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Add GeoFence"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * imgBack = [[UIImageView alloc]initWithFrame:CGRectMake(10,yy-44+11, 14, 22)];
    imgBack.image = [UIImage imageNamed:@"back_icon.png"];
    imgBack.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgBack];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, 0, 80, yy)];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnBack];
    if (IS_IPHONE_X)
    {
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        imgBack.frame = CGRectMake(10,40+11, 14, 22);
    }
}
-(void)setContentViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    yy = yy+20;
    txtName = [[UIFloatLabelTextField alloc]init];
    txtName.frame = CGRectMake(10, yy, DEVICE_WIDTH-20, 44);
    txtName.textAlignment = NSTextAlignmentLeft;
    txtName.backgroundColor = UIColor.clearColor;
    txtName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtName.floatLabelPassiveColor = UIColor.lightGrayColor;
    txtName.floatLabelActiveColor = UIColor.lightGrayColor;
    txtName.placeholder = @"Name";
    txtName.delegate = self;
    txtName.textColor = UIColor.whiteColor;
    txtName.font = [UIFont fontWithName:CGRegular size:textSize];
    txtName.keyboardType = UIKeyboardTypeDefault;
    txtName.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:txtName];
    [txtName setValue:UIColor.whiteColor forKeyPath:@"_placeholderLabel.textColor"];
    
    lblNameLine = [[UILabel alloc]init];
    lblNameLine.backgroundColor = UIColor.lightGrayColor;
    lblNameLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    [txtName addSubview:lblNameLine];
    
    yy = yy+44+10;
    
    UILabel *lblType = [[UILabel alloc]initWithFrame:CGRectMake(10, yy, 80, 40)];
    [lblType setBackgroundColor:[UIColor clearColor]];
    [lblType setText:@" Type :"];
    [lblType setTextAlignment:NSTextAlignmentLeft];
    [lblType setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
    [lblType setTextColor:[UIColor whiteColor]];
    [self.view addSubview:lblType];
    
    imgRadioCircular = [[UIImageView alloc]init];
    imgRadioCircular.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
    imgRadioCircular.frame = CGRectMake(80, yy+10, 20, 20);
    [self.view addSubview:imgRadioCircular];
    
    lblCircular = [[UILabel alloc]initWithFrame:CGRectMake(105, yy, 80, 40)];
    [lblCircular setBackgroundColor:[UIColor clearColor]];
    [lblCircular setText:@"Circular"];
    [lblCircular setTextAlignment:NSTextAlignmentLeft];
    [lblCircular setFont:[UIFont fontWithName:CGBold size:textSize+1]];
    [lblCircular setTextColor:[UIColor whiteColor]];
    [self.view addSubview:lblCircular];
    
    UIButton *btnCircular = [[UIButton alloc]initWithFrame:CGRectMake(70, yy, (DEVICE_WIDTH/2)-35, 40)];
    btnCircular.backgroundColor = UIColor.clearColor;
    [btnCircular addTarget:self action:@selector(btnCircularClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCircular];
    
    int zz = 105+80+20;
    imgRadioPolygon = [[UIImageView alloc]init];
    imgRadioPolygon.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
    imgRadioPolygon.frame = CGRectMake(zz, yy+10, 20, 20);
    [self.view addSubview:imgRadioPolygon];
    
    lblPolygon = [[UILabel alloc]initWithFrame:CGRectMake(zz+25, yy, 80, 40)];
    [lblPolygon setBackgroundColor:[UIColor clearColor]];
    [lblPolygon setText:@"Polygon"];
    [lblPolygon setTextAlignment:NSTextAlignmentLeft];
    [lblPolygon setFont:[UIFont fontWithName:CGRegular size:textSize+1]];
    [lblPolygon setTextColor:[UIColor whiteColor]];
    [self.view addSubview:lblPolygon];
    
    UIButton *btnPolygon = [[UIButton alloc]initWithFrame:CGRectMake(zz, yy, (DEVICE_WIDTH/2)-35, 40)];
    btnPolygon.backgroundColor = UIColor.clearColor;
    [btnPolygon addTarget:self action:@selector(btnPolygonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPolygon];
    
    yy = yy+44;
    txtRadius = [[UIFloatLabelTextField alloc]init];
    txtRadius.frame = CGRectMake(10, yy, DEVICE_WIDTH-20, 44);
    txtRadius.textAlignment = NSTextAlignmentLeft;
    txtRadius.backgroundColor = UIColor.clearColor;
    txtRadius.autocorrectionType = UITextAutocorrectionTypeNo;
    txtRadius.floatLabelPassiveColor = UIColor.lightGrayColor;
    txtRadius.floatLabelActiveColor = UIColor.lightGrayColor;
    txtRadius.placeholder = @"Radius in Km";
    txtRadius.delegate = self;
    txtRadius.textColor = UIColor.whiteColor;
    txtRadius.font = [UIFont fontWithName:CGRegular size:textSize];
//    txtRadius.keyboardType = UIKeyboardTypeNumberPad;
    txtRadius.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:txtRadius];
    [txtRadius setValue:UIColor.whiteColor forKeyPath:@"_placeholderLabel.textColor"];
    
    lblRadiusLine = [[UILabel alloc]init];
    lblRadiusLine.backgroundColor = UIColor.lightGrayColor;
    lblRadiusLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    [txtRadius addSubview:lblRadiusLine];
    
    yy = yy+80;
    
    btnNext = [[UIButton alloc]initWithFrame:CGRectMake(20, yy, DEVICE_WIDTH-40, 50)];
    btnNext.backgroundColor = UIColor.blackColor;
    btnNext.layer.masksToBounds = true;
    [btnNext setTitle:@"Next" forState:UIControlStateNormal];
    [btnNext setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnNext.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize ];
    btnNext.layer.cornerRadius = 15;
    [btnNext addTarget:self action:@selector(btnNextClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnNext];
    
    if (isFromEdit == true)
    {
        txtName.text = [dictEditGeofence valueForKey:@"name"];
        if ([[dictEditGeofence valueForKey:@"type"]isEqualToString:@"Circular"])
        {
            txtRadius.text = [dictEditGeofence valueForKey:@"radius"];
            [self btnCircularClick];
            btnCircular.enabled = false;
            btnPolygon.enabled = false;
        }
        else
        {
            [self btnPolygonClick];
            btnCircular.enabled = false;
            btnPolygon.enabled = false;
        }
    }
}

#pragma mark - All Button Clicks
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnCircularClick
{
    [lblCircular setFont:[UIFont fontWithName:CGBold size:textSize+1]];
    [lblPolygon setFont:[UIFont fontWithName:CGRegular size:textSize+1]];

    isPolygonClicked = false;
    imgRadioPolygon.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
    imgRadioCircular.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
    btnNext.frame = CGRectMake(20,txtRadius.frame.origin.y+80, DEVICE_WIDTH-40, 50);
    txtRadius.hidden = false;
    lblRadiusLine.hidden = false;
}
-(void)btnPolygonClick
{
    [lblCircular setFont:[UIFont fontWithName:CGRegular size:textSize+1]];
    [lblPolygon setFont:[UIFont fontWithName:CGBold size:textSize+1]];

    isPolygonClicked = true;
    imgRadioPolygon.image = [UIImage imageNamed:@"radiobuttonSelected.png"];
    imgRadioCircular.image = [UIImage imageNamed:@"radiobuttonUnselected.png"];
    btnNext.frame = CGRectMake(20,txtRadius.frame.origin.y+10, DEVICE_WIDTH-40, 50);
    txtRadius.hidden = true;
    lblRadiusLine.hidden = true;
}
-(void)btnNextClick
{
    PolygonGeofenceVC *view2 = [[PolygonGeofenceVC alloc]init];
    ViewController *view1 = [[ViewController alloc]init];


    if ([txtName.text isEqualToString:@""])
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please Enter Your Name" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{}];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
        if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
    else
    {
        [self.view endEditing:true];
        
        [dictGeofenceInfo setValue:[APP_DELEGATE checkforValidString:txtName.text] forKey:@"name"];
        if (isFromEdit == true)
        {
            view1.isfromEdit = true;
            view2.isfromEdit = true;
            
            [dictGeofenceInfo setValue:[APP_DELEGATE checkforValidString:[dictEditGeofence valueForKey:@"id"]] forKey:@"id"];
        }
        if (isPolygonClicked == true)
        {
            [dictGeofenceInfo setValue:@"0" forKey:@"radius"];
            [dictGeofenceInfo setValue:@"Polygon" forKey:@"type"];
            if (isFromEdit)
            {
                view2.dictGeofenceInfo = dictEditGeofence;
            }
            else
            {
                view2.dictGeofenceInfo = dictGeofenceInfo;
            }
            [self.navigationController pushViewController:view2 animated:true];
        }
        else
        {
            if ([txtRadius.text isEqualToString:@""])
            {
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please Enter Radius" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                    [alertView hideWithCompletionBlock:^{}];
                }];
                [alertView showWithAnimation:URBAlertAnimationTopToBottom];
                if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
            }
            else
            {
                [dictGeofenceInfo setValue:[APP_DELEGATE checkforValidString:txtRadius.text] forKey:@"radius"];
                [dictGeofenceInfo setValue:@"Circular" forKey:@"type"];
                if (isFromEdit)
                {
                    view1.dictGeofenceInfo = dictEditGeofence;
                }
                else
                {
                    view1.dictGeofenceInfo = dictGeofenceInfo;
                }
                [self.navigationController pushViewController:view1 animated:true];
            }
            
        }
      
    }
   
}

-(void)doneKeyBoarde
{
    [txtRadius resignFirstResponder];
}
#pragma mark - UITextfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtName)
    {
        [txtName resignFirstResponder];
    }
    else if (textField == txtRadius)
    {
        [txtRadius resignFirstResponder];

    }
    return true;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == txtName)
    {
        lblNameLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblNameLine.backgroundColor = UIColor.whiteColor;
    }
    else if (textField == txtRadius)
    {
        lblRadiusLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblRadiusLine.backgroundColor = UIColor.whiteColor;
        
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        numberToolbar.barStyle =  UIBarStyleDefault;
        UIBarButtonItem *space =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *Done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
        [Done setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor blackColor], NSForegroundColorAttributeName,nil]
                              forState:UIControlStateNormal];
        Done.tintColor=[UIColor colorWithRed:202.0/255 green:202.0/255 blue:202.0/255 alpha:202.0/255];
        
        numberToolbar.items = [NSArray arrayWithObjects:space,Done,
                               nil];
        [numberToolbar sizeToFit];
        textField.inputAccessoryView = numberToolbar;
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == txtName)
    {
        lblNameLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
        lblNameLine.backgroundColor = UIColor.lightGrayColor;
    }
    else if (textField == txtRadius)
    {
        lblRadiusLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
        lblRadiusLine.backgroundColor = UIColor.whiteColor;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
