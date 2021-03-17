//
//  CustomAnnotationView.m
//  HomeTribe
//
//  Created by Oneclick IT on 8/23/16.
//  Copyright © 2016 Oneclick IT. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "Constant.h"


@implementation CustomAnnotationView 

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    
    [super setSelected:selected animated:animated];
    
    if(selected)
    {
        [viewCallout removeFromSuperview];
        viewCallout= [[UIView alloc]init];
        [viewCallout setBackgroundColor:[UIColor clearColor]];
        [viewCallout setFrame:CGRectMake(0,0, DEVICE_WIDTH-80, 75)];
        [self addSubview:viewCallout];
        viewCallout.userInteractionEnabled=YES;
        
        [viewBGPopUp removeFromSuperview];
         viewBGPopUp= [[UIView alloc]init];
        [viewBGPopUp setBackgroundColor:[UIColor whiteColor]];
        [viewBGPopUp setFrame:CGRectMake(0,0, DEVICE_WIDTH-80, 75)];
        viewBGPopUp.layer.cornerRadius = 5;
        viewBGPopUp.layer.shadowColor = [UIColor blackColor].CGColor;
        viewBGPopUp.layer.shadowOpacity = 0.6;
        viewBGPopUp.layer.shadowRadius = 10;
        [viewCallout addSubview:viewBGPopUp];
        

        
        lblID = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, viewBGPopUp.frame.size.width-10, 25)];
        lblID.font=[UIFont fontWithName:CGRegular size:textSize-2];
        lblID.textColor=[UIColor darkGrayColor];
        lblID.numberOfLines = 0;
        lblID.textAlignment = NSTextAlignmentLeft;
        lblID.text = _subtitle1;
        [viewCallout addSubview:lblID];
        
        lblType= [[UILabel alloc]initWithFrame:CGRectMake(viewBGPopUp.frame.size.width-10, 0, viewBGPopUp.frame.size.width/2, 25)];
        lblType.font=[UIFont fontWithName:CGRegular size:textSize-2];
        lblType.textColor=[UIColor darkGrayColor];
        lblType.numberOfLines = 0;
        lblType.textAlignment = NSTextAlignmentRight;
        lblType.text = _subtitle2;
        [viewCallout addSubview:lblType];
        
       lblSate= [[UILabel alloc]initWithFrame:CGRectMake(5, 25, viewBGPopUp.frame.size.width-0, 25)];
       lblSate.font=[UIFont fontWithName:CGRegular size:textSize-2];
       lblSate.textColor=[UIColor darkGrayColor];
       lblSate.numberOfLines = 0;
       lblSate.textAlignment = NSTextAlignmentLeft;
       lblSate.text = _subtitle3;
       [viewCallout addSubview:lblSate];

        lblNote= [[UILabel alloc]initWithFrame:CGRectMake(5, 50, viewBGPopUp.frame.size.width-10, 25)];
        lblNote.font=[UIFont fontWithName:CGRegular size:textSize-2];
        lblNote.textColor=[UIColor darkGrayColor];
        lblNote.numberOfLines = 0;
        lblNote.textAlignment = NSTextAlignmentLeft;
        lblNote.text = _subtitle4;
        [viewCallout addSubview:lblNote];
        
        
        
        id title = [NSString stringWithFormat:@"%@",_title];
        NSString * strtitle;
        if (title != [NSNull null])
        {
            strtitle = (NSString *)title;
            if ([strtitle isEqualToString:@""]||[strtitle isEqualToString:@"<null>"]||[strtitle isEqualToString:@"(null)"])
            {
                strtitle=@"";
            }
            else
            {
            }
        }
        else
        {
            strtitle=@"";
        }
//         [lblID setText:[NSString stringWithFormat:@"%@",strtitle]];
        id catefory = [NSString stringWithFormat:@"%@",_subtitle1];
        NSString * strCategory;
        if (catefory != [NSNull null])
        {
            strCategory = (NSString *)catefory;
            if ([strCategory isEqualToString:@""]||[strCategory isEqualToString:@"<null>"]||[strCategory isEqualToString:@"(null)"])
            {
                strCategory=@"";
            }
            else
            {
            }
        }
        else
        {
            strCategory=@"";
        }
//        [lblPrice setText:strCategory];
        
        if ([_isfromAdd isEqualToString:@"YES"])
        {
            NSLog(@"isaaa");
 
        }
                
        CGRect calloutViewFrame = viewCallout.frame;
        calloutViewFrame.origin = CGPointMake(-calloutViewFrame.size.width/2, -calloutViewFrame.size.height);
        viewCallout.frame = calloutViewFrame;
        
        
        animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
        CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
        CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
        
        NSArray *frameValues = [NSArray arrayWithObjects:
                                [NSValue valueWithCATransform3D:scale1],
                                [NSValue valueWithCATransform3D:scale2],
                                [NSValue valueWithCATransform3D:scale3],
                                [NSValue valueWithCATransform3D:scale4],
                                nil];
        [animation setValues:frameValues];
        
        NSArray *frameTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.5],
                               [NSNumber numberWithFloat:0.9],
                               [NSNumber numberWithFloat:1.0],
                               nil];
        [animation setKeyTimes:frameTimes];
        animation.fillMode = kCAFillModeRemoved;
        animation.removedOnCompletion = NO;
        animation.duration = .2;
        
        [self.layer addAnimation:animation forKey:@"popup"];
        
        
        [viewCallout setUserInteractionEnabled:YES];
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           //Remove your custom view...
                           [self->viewCallout setUserInteractionEnabled:NO];
                           [self->viewCallout removeFromSuperview];
                       });
        
        viewCallout=nil;
    }
}

-(void)buttonHandlerCallOut:(UIButton*)sender{

    if (_delegate && [self.delegate respondsToSelector:@selector(buttonHandlerCallOut:)]) {
        [_delegate buttonHandlerCallOut:sender];
    }
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* v = [super hitTest:point withEvent:event];
    if (v != nil)
    {
        [self.superview bringSubviewToFront:self];
    }
    return v;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect rec = self.bounds;
    BOOL isIn = CGRectContainsPoint(rec, point);
    if(!isIn)
    {
        for (UIView *v in self.subviews)
        {
            isIn = CGRectContainsPoint(v.frame, point);
            if(isIn)
                break;
        }
    }
    return isIn;
}

@end
