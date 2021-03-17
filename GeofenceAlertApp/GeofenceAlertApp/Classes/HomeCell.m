//
//  HomeCell.m
//  GeofenceAlertApp
//
//  Created by srivatsa s pobbathi on 12/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "HomeCell.h"

@implementation HomeCell
@synthesize lblDeviceName,lblConnect,lblAddress,lblBack;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {    // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,DEVICE_WIDTH-20,60)];
        lblBack.backgroundColor = [UIColor blackColor];
        lblBack.alpha = 0.7;
        lblBack.layer.cornerRadius = 10;
        lblBack.layer.masksToBounds = YES;
        lblBack.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:lblBack];
        
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, DEVICE_WIDTH-36, 35)];
        lblDeviceName.numberOfLines = 2;
        [lblDeviceName setBackgroundColor:[UIColor clearColor]];
        lblDeviceName.textColor = UIColor.whiteColor;
        [lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSize+3]];
        [lblDeviceName setTextAlignment:NSTextAlignmentLeft];
        lblDeviceName.text = @"Device name";
        
        
        lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(18, 30,  DEVICE_WIDTH-36, 25)];
        lblAddress.numberOfLines = 2;
        [lblAddress setBackgroundColor:[UIColor clearColor]];
        [lblAddress setTextColor:[UIColor lightGrayColor]];
        [lblAddress setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [lblAddress setTextAlignment:NSTextAlignmentLeft];
        lblAddress.text = @"Ble Address";
        
        lblConnect = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-104, 0, DEVICE_WIDTH-70, 60)];
        lblConnect.numberOfLines = 2;
        [lblConnect setBackgroundColor:[UIColor clearColor]];
        [lblConnect setTextColor:[UIColor whiteColor]];
        [lblConnect setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [lblConnect setTextAlignment:NSTextAlignmentLeft];
        lblConnect.text = @"Connect";
        
        
        
        [self.contentView addSubview:lblDeviceName];
        [self.contentView addSubview:lblAddress];
        [self.contentView addSubview:lblConnect];
    }
    return self;
}

@end
