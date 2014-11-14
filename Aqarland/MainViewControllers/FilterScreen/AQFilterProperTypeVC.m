//
//  AQFilterProperTypeVC.m
//  Aqarland
//
//  Created by Rey Jenald Pena on 11/4/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQFilterProperTypeVC.h"
#import "AQFilterSearchResult.h"
#import "AQPropertyTypeCell.h"
#import "FXBlurView.h"

#define blurValue 6.0


@interface AQFilterProperTypeVC () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *propertyTypes;
@property (strong, nonatomic) NSString *selectedPropertyType;
@property (weak, nonatomic) IBOutlet FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property(nonatomic,strong) AQFilterSearchResult *searchFilterResult;
@property (weak, nonatomic) IBOutlet UITableView *filterView;

@end

@implementation AQFilterProperTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.backgroundImage setImage:self.imageScreen];
    self.blurView.dynamic = NO;
    self.blurView.blurRadius = blurValue;
    // Do any additional setup after loading the view.
    self.propertyTypes = [GlobalInstance loadPlistfile:@"propertyTypeList" forKey:@"propertyList"];
    
    self.tableView.separatorColor = RGB(46, 122, 172);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

////////////////////////
#pragma - Touched
////////////////////////
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    
    if(!CGRectContainsPoint(self.filterView.frame, touchPoint))
    {
        [self.view removeFromSuperview];
       // [self removeFromParentViewController];
        [self.filterDelegate filterPropertyTypeVCDidEndPresenting];
    }
    
}

- (IBAction)touch_up_inside_search_button:(id)sender {
    
    if (self.selectedPropertyType) {
        
    [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
    
        ParseLayerService *request=[[ParseLayerService alloc] init];
        [request FilterSearchPropertyType:self.selectedPropertyType];
        [request setCompletionBlock:^(id results)
         {
             [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
             
             NSArray *arr=[NSArray arrayWithArray:results];
             if([arr count]!=0)
             {
                 self.searchFilterResult=[GlobalInstance loadStoryBoardId:sSearchFilterResultVC];
                 UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.searchFilterResult];
                 self.searchFilterResult.resultArr=[NSMutableArray arrayWithArray:arr];
                 [GlobalInstance.navController presentViewController:nc animated:YES completion:nil];
             }else
             {
                 [GlobalInstance showAlert:iInformation message:@"No result found"];
             }
         }];
        [request setFailedBlock:^(NSError *error)
         {
             [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
             [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
         }];
        
    }
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.propertyTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"PropertyTypeCell";
    
    AQPropertyTypeCell *cell = (AQPropertyTypeCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.titleLabel.text = self.propertyTypes[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedPropertyType = self.propertyTypes[indexPath.row];
}

@end
