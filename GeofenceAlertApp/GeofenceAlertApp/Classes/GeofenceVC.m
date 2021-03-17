//
//  GeofenceVC.m
//  GeofenceAlertApp
//
//  Created by srivatsa s pobbathi on 13/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "GeofenceVC.h"
#import "GeofenceCell.h"
#import "AddGeofenceVC.h"
#import "ViewController.h"
#import "PolygonGeofenceVC.h"

@interface GeofenceVC ()

@end

@implementation GeofenceVC

- (void)viewDidLoad
{
    [self setNavigationViewFrames];
    [self setContentViewFrames];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    arrGeofence = [[NSMutableArray alloc]init];
    NSString * str = [NSString stringWithFormat:@"Select * from Geofence"];
    [[DataBaseManager dataBaseManager] execute:str resultsArray:arrGeofence];
    
    [tblContent reloadData];
        NSLog(@"array is %@",arrGeofence);

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
    
//    UILabel *lblBack = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy + globalStatusHeight)];
//    lblBack.backgroundColor = UIColor.blackColor;
//    [viewHeader addSubview:lblBack];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, globalStatusHeight, DEVICE_WIDTH-100, yy)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"GeoFence"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * imgBack = [[UIImageView alloc]initWithFrame:CGRectMake(10,globalStatusHeight+11, 14, 22)];
    imgBack.image = [UIImage imageNamed:@"back_icon.png"];
    imgBack.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgBack];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, 0, 80, yy+globalStatusHeight)];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnBack];
    
    UIImageView * imgAdd = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-40,globalStatusHeight+4.5, 35, 35)];
    imgAdd.image = [UIImage imageNamed:@"add.png"];
    imgAdd.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgAdd];
    
    UIButton * btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAdd setFrame:CGRectMake(DEVICE_WIDTH-60, 0, yy+globalStatusHeight, yy+globalStatusHeight)];
    [btnAdd addTarget:self action:@selector(btnAddClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnAdd];
}
-(void)setContentViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0, yy+10, DEVICE_WIDTH,(DEVICE_HEIGHT)-yy-10) style:UITableViewStylePlain];
    tblContent.delegate = self;
    tblContent.dataSource = self;
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.backgroundColor = [UIColor clearColor];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblContent];
    
}
#pragma mark- UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblContent)
    {
//        return 2;
        return arrGeofence.count;
    }
    
    return true;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    GeofenceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[GeofenceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    cell.lblDeviceName.text = [[arrGeofence objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.lblShape.text = [[arrGeofence objectAtIndex:indexPath.row] valueForKey:@"type"];

    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[arrGeofence objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"Circular"])
    {
        ViewController *view1 = [[ViewController alloc]init];
        view1.dictGeofenceInfo = [arrGeofence objectAtIndex:indexPath.row];
        view1.isfromEdit = YES;
        [self.navigationController pushViewController:view1 animated:true];
    }
    else
    {
        PolygonGeofenceVC *view1 = [[PolygonGeofenceVC alloc]init];
        view1.dictGeofenceInfo = [arrGeofence objectAtIndex:indexPath.row];
        view1.isfromEdit = YES;
        [self.navigationController pushViewController:view1 animated:true];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        //insert your editAction here
        AddGeofenceVC * view1 = [[AddGeofenceVC alloc]init];
        view1.isFromEdit = YES;
        view1.dictEditGeofence = [self->arrGeofence objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:view1 animated:true];
    }];
    editAction.backgroundColor = [UIColor blueColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        //insert your deleteAction here
        NSString * strDelete = [NSString stringWithFormat:@"delete from Geofence where id = '%@' ",[[self->arrGeofence objectAtIndex:indexPath.row]valueForKey:@"id"]];
        [[DataBaseManager dataBaseManager] execute:strDelete];
        
        [self->arrGeofence removeObject:[self->arrGeofence objectAtIndex:indexPath.row]];
        [self->tblContent reloadData];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction,editAction];
}
#pragma mark - All Button Clicks
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnAddClick
{
    AddGeofenceVC *view1 = [[AddGeofenceVC alloc]init];
    view1.isFromEdit = false;
    [self.navigationController pushViewController:view1 animated:true];
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
