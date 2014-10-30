//
//  AQFilterSearchResult.m
//  Aqarland
//
//  Created by Louise on 22/10/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQFilterSearchResult.h"
#import "AQFilterResultCell.h"
#import "PropertyList.h"
#import "AQViewProperty.h"
@interface AQFilterSearchResult ()

@property(nonatomic,strong) AQViewProperty *viewProperty;
@end

@implementation AQFilterSearchResult

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeHeaderBar];
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

////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////
-(void) customizeHeaderBar
{
    [self.navigationItem setTitle:@"Search Result"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        UIImage *backImage = [UIImage imageNamed:iCloseImg];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0,0,22,22);
        [backBtn setImage:backImage forState:UIControlStateNormal];
        
        [backBtn addTarget:self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
        
    }
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

///////////////////////////////////////////////
#pragma mark - UITableViewDelegate Methods
//////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"filterResultCell";
    AQFilterResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
   
    PropertyList *property= (PropertyList *)[self.resultArr objectAtIndex:indexPath.row];
    NSLog(@"property %@",property.m_houseNumber);
    // Configure the cell...
    NSString *address=[NSString stringWithFormat:@"%@, %@, %@",
                       property.m_street,
                       property.m_city,
                       property.m_postCode];
    [cell bindWithLocalData:address Idx:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.viewProperty=[GlobalInstance loadStoryBoardId:sViewPropertyVC];
    self.viewProperty.propertyDetails=[self.resultArr objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:self.viewProperty animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

@end
