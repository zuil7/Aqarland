//
//  AQPropertyUploadPhoto.m
//  Aqarland
//
//  Created by Louise on 19/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQPropertyUploadPhoto.h"
#import "AQUploadPhoto.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PropertyImages.h"
#import "AQMapConfirmLocationViewController.h"

#define defaultImage @"add_property_icon.png"


@interface AQPropertyUploadPhoto ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) AQMapConfirmLocationViewController *mapConfirmVC;
@end

@implementation AQPropertyUploadPhoto {
    NSMutableArray *propertyImages;
    NSMutableArray *newPropertyImages;
    BOOL isOnEditMode;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeHeaderBar];
    self.imageList=[[NSMutableArray alloc] initWithCapacity:6];
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:self.HUD];
    [self.imageList addObject:defaultImage];
    if (self.propertyDetails) {
        isOnEditMode = YES;
        newPropertyImages = [NSMutableArray array];
        propertyImages = [NSMutableArray array];
        ParseLayerService *request = [[ParseLayerService alloc] init];
        [request propertyImagesForPropertyList:self.propertyDetails];
        [request setCompletionBlock:^(id results) {
            NSArray *images = (NSArray *)results;
            for (PropertyImages *propertyImage in images) {
                if ([propertyImage valueForKey:@"propertyImg"] != [NSNull null]) {
                    PFFile *imageFile = [propertyImage valueForKey:@"propertyImg"];
                    NSData *imageData = [imageFile getData];
                    UIImage *image = [UIImage imageWithData:imageData];
                    [self.imageList addObject:image];
                    [propertyImages addObject:propertyImage];
                }
            }
            [self.photoCV reloadData];

        }];
        [request setFailedBlock:^(NSError *error) {
            
        }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////

-(void) customizeHeaderBar
{
    [self.navigationItem setTitle:@"Add Property"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        UIImage *backImage = [UIImage imageNamed:@""];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0,0,22,32);
        [backBtn setImage:backImage forState:UIControlStateNormal];
        
        [backBtn addTarget:self action:@selector(dummy:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
        
    }
    if ([self.navigationItem respondsToSelector:@selector(rightBarButtonItems)])
    {
        UIImage *forwardImage = [UIImage imageNamed:iForwardArrowImg];
        UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        forwardBtn.frame = CGRectMake(0,0,22,32);
        [forwardBtn setImage:forwardImage forState:UIControlStateNormal];
        
        [forwardBtn addTarget:self action:@selector(uploadImages:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:forwardBtn];
        [self.navigationItem setRightBarButtonItem:barButtonItem];
        
    }
}
-(void) dummy:(id) sender
{

}
-(void) uploadImages:(id) sender
{
     __block int ctr=0;
    if (isOnEditMode && newPropertyImages.count <= 0 && self.imageList.count > 1) {
        self.mapConfirmVC=[GlobalInstance loadStoryBoardId:sPropertyConfirmLocVC];
        self.mapConfirmVC.propertyImg=(UIImage *)[self.imageList objectAtIndex:1];
        self.mapConfirmVC.strPropertyID=self.propertyDetails.m_objectID;
        self.mapConfirmVC.propertyDetails = self.propertyDetails;
        [self.navigationController pushViewController:self.mapConfirmVC animated:YES];

    } else if([self.imageList count]>1)
    {
        self.HUD.delegate = self;
        self.HUD.labelText = @"Uploading";
        self.HUD.detailsLabelText = [NSString stringWithFormat:@"0 of %lu",(unsigned long)[self.imageList count]-1];
        self.HUD.square = YES;
        [self.HUD show:YES];
        
        NSMutableArray *imagesToUpload;
        if (isOnEditMode) {
            imagesToUpload = newPropertyImages;
        } else {
            imagesToUpload = self.imageList;
            [imagesToUpload removeObjectAtIndex:0];
        }
        ParseLayerService *request=[[ParseLayerService alloc] init];
        [request uploadImages:imagesToUpload :self.propertyObjID];
        [request setCompletionBlock:^(id results)
         {
             NSDictionary *dict=(NSDictionary *) results;
             NSLog(@"dict %@",dict);
             NSString *propertyID=dict[@"propertyObjID"];
             if ([dict[@"flag"] boolValue]==1)
             {
                 ctr=ctr+1;
                 
                 self.HUD.detailsLabelText = [NSString stringWithFormat:@"%d of %lu",ctr,(unsigned long)[imagesToUpload count]];
                 if(ctr==[imagesToUpload count])
                 {
                     self.mapConfirmVC=[GlobalInstance loadStoryBoardId:sPropertyConfirmLocVC];
                     self.mapConfirmVC.propertyImg=(UIImage *)[self.imageList objectAtIndex:1];
                     NSLog(@"propertyList %@",propertyID);
                     self.mapConfirmVC.strPropertyID=propertyID;
                     self.mapConfirmVC.propertyDetails = self.propertyDetails;
                     [self.navigationController pushViewController:self.mapConfirmVC animated:YES];
                     [self.HUD hide:YES];
                 }
             }
         }];
        [request setFailedBlock:^(NSError *error)
         {
             [self.HUD hide:YES];
             [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
         }];

        
    }else
    {
         NSLog(@"Fail");
    }
   

}
/*
-(void) myTask
{
    
    __block int ctr=0;
    for (int i=0; i<[self.imageList count]; i++)
    {
        if (i!=0)
        {
            UIImage *image=(UIImage *)[self.imageList objectAtIndex:i];
            NSData *imageData = UIImagePNGRepresentation(image);
            PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
            PFObject *userPhoto = [PFObject objectWithClassName:pPropertyImage];
            
            userPhoto[@"propertyImg"] = imageFile;
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if(error)
                 {
                     
                 }else
                 {
                    

                         ctr=ctr+1;
                         NSLog(@"ctr %d",ctr);
                         self.HUD.detailsLabelText = [NSString stringWithFormat:@"%d of %d",ctr,[self.imageList count]-1];
                          if(ctr==[self.imageList count]-1)
                          {
                              [self.HUD hide:YES];
                          }
                    
                 }
             }];
            
        }
    }

    //self.HUD.detailsLabelText = [NSString stringWithFormat:@"0 of %d",[self.imageList count]-1];
}*/

-(void) addPhotoButton:(id) sender
{
    
    UIActionSheet *mediaSheet=[[UIActionSheet alloc] init];
    mediaSheet.tag=22;
    [mediaSheet addButtonWithTitle:@"Take photo"];
    [mediaSheet addButtonWithTitle:@"Choose Existing Photo"];
    [mediaSheet addButtonWithTitle:@"Cancel"];
    mediaSheet.delegate=self;
    mediaSheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    [mediaSheet showInView:self.view];
}

-(void) deleteImg:(id)sender
{
    if (self.propertyDetails) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSInteger index = [sender tag] - 1;
        PropertyImages *propertyImage = propertyImages[index];
        ParseLayerService *request = [[ParseLayerService alloc] init];
        [request deleteImage:propertyImage fromProperty:self.propertyDetails];
        [request setCompletionBlock:^(id results) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            [indexSet addIndex:[sender tag]];
            if ([newPropertyImages containsObject:self.imageList[index]]) {
                [newPropertyImages removeObject:self.imageList[index]];
            }
            [self.imageList removeObjectsAtIndexes:indexSet];
            NSLog(@"self.imageList %@",self.imageList);
            [self.photoCV reloadData];

        }];
        [request setFailedBlock:^(NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
    else
    {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex:[sender tag]];
        [self.imageList removeObjectsAtIndexes:indexSet];
        NSLog(@"self.imageList %@",self.imageList);
        [self.photoCV reloadData];

    }
}
-(void) cameraLaunch
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker=[[UIImagePickerController alloc]init];
        picker.delegate=self;
        picker.allowsEditing=YES;
        picker.sourceType=UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker
                           animated:YES completion:nil];
    }else {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error Accessing Photo Library" message:@"Device does not support a Camera" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

-(void) albumLaunch
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
        picker.delegate=self;
        picker.allowsEditing=YES;
        picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = @[(NSString *) kUTTypeImage];
        [self presentViewController:picker
                           animated:YES completion:nil];
        
    }else
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error Accessing Photo Library" message:@"Device does not support a photo library" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}
//////////////////////////////////////
#pragma mark - UIActionsheet delegate
//////////////////////////////////////
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag==11)
    {
        NSLog(@"Done");
    }else {
        switch (buttonIndex)
        {
            case 0:
                [self cameraLaunch];
                break;
            case 1:
                [self albumLaunch];
                break;
            default:
                break;
        }
    }
    
    
}

/////////////////////////////////
#pragma mark - Collection Delegate
//////////////////////////////////

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.imageList count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AQUploadPhoto *cell;
    if(indexPath.row==0)
    {
         cell= (AQUploadPhoto *)[collectionView dequeueReusableCellWithReuseIdentifier:@"UploadPhotoCell" forIndexPath:indexPath];
        [cell.addPhotoBtn setImage:[UIImage imageNamed:[self.imageList objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
        [cell.addPhotoBtn addTarget:self
                           action:@selector(addPhotoButton:)
                 forControlEvents:UIControlEventTouchDown];
    }else
    {
        cell= (AQUploadPhoto *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
        [cell.photoImg setImage:[self.imageList objectAtIndex:indexPath.row]];
        [cell.deleteImgBtn setTag:indexPath.row];
        [cell.deleteImgBtn addTarget:self
                             action:@selector(deleteImg:)
                   forControlEvents:UIControlEventTouchDown];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // [self.weatherCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    //    CustomCollectionCell *cell = (CustomCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    //    NSArray *views = [cell.contentView subviews];
    //    UILabel *label = [views objectAtIndex:0];
    //NSLog(@"Select %d",indexPath.row);
}
/////////////////////////////////
#pragma mark UIImagePickerControllerDelegate
/////////////////////////////////

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if([self.imageList count]<=5)
        {
            [self.imageList insertObject:image atIndex:1];
            [newPropertyImages addObject:image];
            [self.photoCV reloadData];
        }else
        {
            [GlobalInstance showAlert:iInformation message:@"You can only upload 5 photos."];
        }
       
    }
    
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
