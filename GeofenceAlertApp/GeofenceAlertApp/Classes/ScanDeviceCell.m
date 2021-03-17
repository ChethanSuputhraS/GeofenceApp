//
//  ScanDeviceCell.m
//  GeofenceAlertApp
//
//  Created by Ashwin on 7/16/20.
//  Copyright © 2020 srivatsa s pobbathi. All rights reserved.
//

#import "ScanDeviceCell.h"

@implementation ScanDeviceCell
@synthesize lblDevice;
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

        lblDevice = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
        lblDevice.text = @"BLE====Device===ID";
        lblDevice.textColor = UIColor.whiteColor;
        lblDevice.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:lblDevice];

    }
            return self;
        }
@end
