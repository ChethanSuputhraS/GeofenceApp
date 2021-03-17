//
//  GeofencencAlertCell.m
//  GeofenceAlertApp
//
//  Created by Ashwin on 7/16/20.
//  Copyright © 2020 srivatsa s pobbathi. All rights reserved.
//

#import "GeofencencAlertCell.h"

@implementation GeofencencAlertCell
@synthesize lblDate,lblGeoFncID,lblType,lblStateOfVoi,lblNote,imgArrow,lblCellBgColor,lblForSetting;
- (void)awakeFromNib
{
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
               
        int yy = 0 ;
        
               lblDate = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2, 0,  DEVICE_WIDTH/2-5, 30)];
               lblDate.numberOfLines = 2;
               [lblDate setBackgroundColor:[UIColor clearColor]];
               lblDate.textColor = UIColor.lightGrayColor;
               [lblDate setFont:[UIFont fontWithName:CGRegularItalic size:textSize-3]];
               [lblDate setTextAlignment:NSTextAlignmentRight];
               lblDate.text = @"Date";
               [self.contentView addSubview:lblDate];
        
               lblStateOfVoi = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, DEVICE_WIDTH, 30)];
               lblStateOfVoi.numberOfLines = 2;
               [lblStateOfVoi setBackgroundColor:[UIColor clearColor]];
               [lblStateOfVoi setTextColor:[UIColor lightGrayColor]];
               [lblStateOfVoi setFont:[UIFont fontWithName:CGRegularItalic size:textSize-3]];
               [lblStateOfVoi setTextAlignment:NSTextAlignmentLeft];
               lblStateOfVoi.text = @"Sate";
        
               lblNote = [[UILabel alloc] initWithFrame:CGRectMake(5, 20, DEVICE_WIDTH-15, 70)];
               lblNote.numberOfLines = 0;
               [lblNote setBackgroundColor:[UIColor clearColor]];
               [lblNote setTextColor:[UIColor whiteColor]];
               [lblNote setFont:[UIFont fontWithName:CGRegular size:textSize -1 ]];
               [lblNote setTextAlignment:NSTextAlignmentLeft];
               lblNote.text = @"Note";
               

        imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-12, 35, 10, 12)];
        [imgArrow setImage:[UIImage imageNamed:@"right_icon.png"]];
        [imgArrow setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgArrow];
        
        lblCellBgColor = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 90)];
        [lblCellBgColor setBackgroundColor:[UIColor blackColor]];
        lblCellBgColor.alpha = 0.5;
        [self.contentView addSubview:lblCellBgColor];
        
               [self.contentView addSubview:lblDate];
               [self.contentView addSubview:lblGeoFncID];
               [self.contentView addSubview:lblType];
               [self.contentView addSubview:lblStateOfVoi];
               [self.contentView addSubview:lblNote];

          
            }
            return self;
        }
        
@end
