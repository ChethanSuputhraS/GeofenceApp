//
//  LeftMenuCell.m
//  SC4App18
//
//  Created by stuart watts on 17/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "LeftMenuCell.h"

@implementation LeftMenuCell
@synthesize lblBack,lblLine,lblName,imgIcon,imgArrow,lblContact,lblNanoID,lblIrridiumID,lblBleAdd,lblBiometrics,lblRight,lblGSMIrridiumID,wifiSwitch;

- (void)awakeFromNib
{
  
    
    [super awakeFromNib];
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,DEVICE_WIDTH,60)];
        lblBack.backgroundColor = [UIColor blackColor];
        lblBack.alpha = 0.5;
        lblBack.hidden = YES;
        [self.contentView addSubview:lblBack];
        
        imgIcon = [[UIImageView alloc] init];
        imgIcon.frame = CGRectMake(10, 20, 20, 20);
        [imgIcon setImage:[UIImage imageNamed:@"profile_1.jpg"]];
        [imgIcon setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgIcon];
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(50, 10,DEVICE_WIDTH-60,24)];
        [lblName setTextColor:[UIColor whiteColor]];
        [lblName setBackgroundColor:[UIColor clearColor]];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        [lblName setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [self.contentView addSubview:lblName];
        
        lblBiometrics = [[UILabel alloc] initWithFrame:CGRectMake(50, 10,DEVICE_WIDTH-60,24)];
        [lblBiometrics setTextColor:[UIColor whiteColor]];
        [lblBiometrics setBackgroundColor:[UIColor clearColor]];
        [lblBiometrics setTextAlignment:NSTextAlignmentLeft];
        lblBiometrics.hidden = true;
        lblBiometrics.text = @"";
        [lblBiometrics setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [self.contentView addSubview:lblBiometrics];
        
        lblBleAdd = [[UILabel alloc] initWithFrame:CGRectMake(50, 10,DEVICE_WIDTH-60,24)];
        [lblBleAdd setTextColor:[UIColor grayColor]];
        [lblBleAdd setBackgroundColor:[UIColor clearColor]];
        [lblBleAdd setTextAlignment:NSTextAlignmentLeft];
        lblBleAdd.hidden = true;
        lblBleAdd.text = @"";
        [lblBleAdd setFont:[UIFont fontWithName:CGRegular size:textSize-2]];
        [self.contentView addSubview:lblBleAdd];
        
        imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-30, 20, 20, 20)];
        imgArrow.image = [UIImage imageNamed:@"arrow.png"];
        [imgArrow setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgArrow];
        
        lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, DEVICE_WIDTH, 0.5)];
        [lblLine setBackgroundColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:lblLine];
        
        lblContact = [[UILabel alloc] initWithFrame:CGRectMake(50, 10,DEVICE_WIDTH-60,24)];
        [lblContact setTextColor:[UIColor whiteColor]];
        [lblContact setBackgroundColor:[UIColor clearColor]];
        [lblContact setTextAlignment:NSTextAlignmentLeft];
        lblContact.text = @"Ph No : 224-23923824828";
        lblContact.hidden = true;
        [lblContact setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [self.contentView addSubview:lblContact];
        
        lblNanoID = [[UILabel alloc] initWithFrame:CGRectMake(50, 34,DEVICE_WIDTH-60,24)];
        [lblNanoID setTextColor:[UIColor whiteColor]];
        [lblNanoID setBackgroundColor:[UIColor clearColor]];
        [lblNanoID setTextAlignment:NSTextAlignmentLeft];
        //        lblNanoID.textColor = UIColor.grayColor;
        lblNanoID.text = @"11323232323";
        [lblNanoID setFont:[UIFont fontWithName:CGRegular size:textSize]];
        lblNanoID.hidden = true;
        [self.contentView addSubview:lblNanoID];
        
        lblIrridiumID = [[UILabel alloc] initWithFrame:CGRectMake(50, 34,DEVICE_WIDTH-60,24)];
        [lblIrridiumID setTextColor:[UIColor whiteColor]];
        [lblIrridiumID setBackgroundColor:[UIColor clearColor]];
        [lblIrridiumID setTextAlignment:NSTextAlignmentLeft];
        lblIrridiumID.text = @"Ph No : 224-23923824828";
        lblIrridiumID.hidden = true;
        [lblIrridiumID setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [self.contentView addSubview:lblIrridiumID];
        
        lblGSMIrridiumID = [[UILabel alloc] initWithFrame:CGRectMake(50, 34,DEVICE_WIDTH-60,24)];
        [lblGSMIrridiumID setTextColor:[UIColor whiteColor]];
        [lblGSMIrridiumID setBackgroundColor:[UIColor clearColor]];
        [lblGSMIrridiumID setTextAlignment:NSTextAlignmentLeft];
        lblGSMIrridiumID.text = @"Ph No : 224-23923824828";
        lblGSMIrridiumID.hidden = true;
        [lblGSMIrridiumID setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [self.contentView addSubview:lblGSMIrridiumID];
        
        lblRight = [[UILabel alloc] initWithFrame:CGRectMake(50, 10,DEVICE_WIDTH-60,24)];
        [lblRight setTextColor:[UIColor whiteColor]];
        [lblRight setBackgroundColor:[UIColor clearColor]];
        [lblRight setTextAlignment:NSTextAlignmentLeft];
        lblRight.hidden = true;
        [lblRight setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [self.contentView addSubview:lblRight];
        
        wifiSwitch = [[UISwitch alloc]init];
        wifiSwitch.frame = CGRectMake(250, 15, 50, 50);
        wifiSwitch.hidden = true;
        
        [self.contentView addSubview:wifiSwitch];
        
        
        int viewWidth = DEVICE_WIDTH;
        if (IS_IPAD)
        {
            viewWidth = 704;
            lblLine.frame = CGRectMake(0, 59.5, viewWidth,0.5);
            [lblName setFrame:CGRectMake(50, 0,viewWidth-50,60)];
            [imgArrow setFrame:CGRectMake(viewWidth-20, 27.5, 15, 15)];
            [imgIcon setFrame:CGRectMake(10, 25, 20, 20)];
        }
        else
        {
            lblBack.frame = CGRectMake(0, 0,DEVICE_WIDTH,50);
            lblLine.frame = CGRectMake(0, 49.5, viewWidth, 0.5);
            [lblName setFrame:CGRectMake(40, 0,viewWidth-50,50)];
            [imgArrow setFrame:CGRectMake(viewWidth-20, 17.5, 15, 15)];
            [imgIcon setFrame:CGRectMake(10, 15, 20, 20)];
        }
    }
    return self;
}

  

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
