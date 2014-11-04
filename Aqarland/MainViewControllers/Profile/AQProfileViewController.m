//
//  AQProfileViewController.m
//  Aqarland
//
//  Created by Louise on 12/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQProfileViewController.h"
#import "AQCircleButton.h"
#import "AMBCircularButton.h"

@interface AQProfileViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *contactNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *officeAddressLabel;

@property (strong, nonatomic) IBOutlet AMBCircularButton *profilePicButton;
@property (weak, nonatomic) IBOutlet UITextField *contactNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextView *officeAddressTextView;

@end

@implementation AQProfileViewController {
    UserProfile *userProfile;
    PFUser *pfUser;
    
    UILabel *navigationBarTitleLabel;
    UIButton *editButton;
    UIButton *saveButton;
    UIBarButtonItem *rightBarButtonItem;
    NSMutableString *addressPlaceHolder;
    NSData *selectedProfilePic;
    NSMutableDictionary *userDictionary;
    PFImageView *pfImageView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeHeaderBar];
    
    [self.profilePicButton setImage:[UIImage imageNamed:@"emptyProfileImage"] forState:UIControlStateNormal];
    [self.profilePicButton setImage:[UIImage imageNamed:@"emptyProfileImage"] forState:UIControlStateSelected];
    [self.profilePicButton setImage:[UIImage imageNamed:@"emptyProfileImage"] forState:UIControlStateDisabled];
    
    pfImageView = [[PFImageView alloc] initWithFrame:self.profilePicButton.frame];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updatePlaceHolders];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)customizeHeaderBar {
    [self.navigationItem setTitle:@"Profile"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)]) {
        UIImage *menuImage = [UIImage imageNamed:iMenuImg];
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0,0,22,32);
        [menuBtn setImage:menuImage forState:UIControlStateNormal];
        
        [menuBtn addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    
    editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 32.0f);
    editButton.titleLabel.font = [UIFont fontWithName: @"Roboto-Light" size:18.0f];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(didTapEditButton) forControlEvents:UIControlEventTouchUpInside];
    
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 32.0f);
    saveButton.titleLabel.font = [UIFont fontWithName: @"Roboto-Light" size:18.0f];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(didTapSaveButton) forControlEvents:UIControlEventTouchUpInside];
    
    rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [self disableInputFields];
}

- (void)updatePlaceHolders {
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];

    ParseLayerService *request = [[ParseLayerService alloc] init];
    [request fetchCurrentUserProfile];
    [request setCompletionBlock:^(id results) {
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];

        userDictionary = (NSMutableDictionary *)results;
        
        userProfile = [userDictionary objectForKey:pUserProfile];
        pfUser = [userDictionary objectForKey:pUser];
        
        navigationBarTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        navigationBarTitleLabel.backgroundColor = [UIColor clearColor];
        navigationBarTitleLabel.font = [UIFont fontWithName: @"Roboto-Regular" size:18.0f];
        navigationBarTitleLabel.textAlignment = NSTextAlignmentCenter;
        navigationBarTitleLabel.textColor = [UIColor whiteColor];
        navigationBarTitleLabel.text = pfUser[@"name"];
        [navigationBarTitleLabel sizeToFit];
        self.navigationItem.titleView = navigationBarTitleLabel;
        self.officeAddressTextView.textColor = [UIColor lightGrayColor];
        
        if ([userProfile valueForKey:@"userAvatar"]) {
            PFFile *imageFile = [userProfile valueForKey:@"userAvatar"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                pfImageView.image = [UIImage imageWithData:imageData];
                [self.profilePicButton setImage:pfImageView.image forState:UIControlStateNormal];
                [self.profilePicButton setImage:pfImageView.image forState:UIControlStateSelected];
                [self.profilePicButton setImage:pfImageView.image forState:UIControlStateDisabled];
            }];
        }
        
        self.contactNumberTextField.placeholder = [userProfile valueForKey:@"phoneNumber"];
        self.emailAddressTextField.placeholder = [pfUser valueForKey:@"email"];
        
        addressPlaceHolder = [[NSMutableString alloc] init];
        if ([[userProfile valueForKey:@"address"] length] > 0) {
            if ([[userProfile valueForKey:@"address"] rangeOfString:@","].location == NSNotFound) {
                [addressPlaceHolder appendString:[NSString stringWithFormat:@"%@, ", [userProfile valueForKey:@"address"]]];
            } else {
                [addressPlaceHolder appendString:[userProfile valueForKey:@"address"]];
            }
        }
        if ([[userProfile valueForKey:@"city"] length] > 0) {
            if ([[userProfile valueForKey:@"city"] rangeOfString:@","].location == NSNotFound) {
                [addressPlaceHolder appendString:[NSString stringWithFormat:@"%@, ", [userProfile valueForKey:@"city"]]];
            } else {
                [addressPlaceHolder appendString:[userProfile valueForKey:@"city"]];
            }
        }
        if ([[userProfile valueForKey:@"country"] length] > 0) {
            if ([[userProfile valueForKey:@"country"] rangeOfString:@","].location == NSNotFound) {
                [addressPlaceHolder appendString:[NSString stringWithFormat:@"%@, ", [userProfile valueForKey:@"country"]]];
            } else {
                [addressPlaceHolder appendString:[userProfile valueForKey:@"country"]];
            }
        }
        
        self.officeAddressTextView.text = addressPlaceHolder;

    }];
    [request setFailedBlock:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to fetch user information" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];

    }];
    
}

- (void)didTapEditButton {
    [self enableInputFields];
    [self switchToSaveMode];
}

- (void)didTapSaveButton {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
    hud.labelText = @"Saving...";
    
    NSData *imageData = UIImagePNGRepresentation(pfImageView.image);
    PFFile *pfImageFile = [PFFile fileWithName:@"avatar.png" data:imageData];
    
    pfUser.email = (self.emailAddressTextField.text.length > 0) ? self.emailAddressTextField.text: self.emailAddressTextField.placeholder;
    
    if (self.officeAddressTextView.text.length > 0) {
        [userProfile setValue:self.officeAddressTextView.text forKey:@"address"];
        [userProfile setValue:@"" forKey:@"city"];
        [userProfile setValue:@"" forKey:@"country"];
    }
    
    if (self.contactNumberTextField.text.length > 0) {
        [userProfile setValue:self.contactNumberTextField.text forKey:@"phoneNumber"];
    }
    
    [userProfile setValue:pfUser forKey:@"user"];
    PFObject *post = [PFObject objectWithClassName:pUserProfile];
    post = (PFObject *)userProfile;
    [post setObject:pfImageFile forKey:@"userAvatar"];
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFRelation *relation = [pfUser relationForKey:pUserProfile];
            [relation addObject:post];
            [pfUser saveInBackground];
            
            [self switchToEditMode];
            [self disableInputFields];
            [self updatePlaceHolders];
            [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
        } else {
            [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
            [GlobalInstance showAlert:iErrorInfo message:[error description]];
        }
    }];
    
    
    
    //[[ParseLayerService sharedInstance] updateUserProfile:userProfile pfUser:pfUser];
}

- (void)switchToEditMode {
    rightBarButtonItem.customView = editButton;
}

- (void)switchToSaveMode {
    rightBarButtonItem.customView = saveButton;
}

- (void)enableInputFields {
    self.profilePicButton.enabled = YES;
    self.contactNumberTextField.enabled = YES;
    self.emailAddressTextField.enabled = YES;
    self.officeAddressTextView.editable = YES;
    [self.contactNumberTextField becomeFirstResponder];
}

- (void)disableInputFields {
    self.profilePicButton.enabled = NO;
    self.profilePicButton.backgroundColor = [UIColor clearColor];
    self.contactNumberTextField.enabled = NO;
    self.emailAddressTextField.enabled = NO;
    self.officeAddressTextView.editable = NO;
}

- (void)takeNewPhotoFromCamera {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.allowsEditing = NO;
        controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        controller.delegate = self;
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"No camera available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)choosePhotoFromExistingImages {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = NO;
        controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        controller.delegate = self;
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - IBAction

- (IBAction)didTapProfilePicButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Take a new photo", @"Choose from existing", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:addressPlaceHolder]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = addressPlaceHolder;
        textView.textColor = [UIColor lightGrayColor];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self takeNewPhotoFromCamera];
            break;
        case 1:
            [self choosePhotoFromExistingImages];
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIGraphicsBeginImageContext(CGSizeMake(99.0f, 90.0f));
    [image drawInRect:CGRectMake(0.0f, 0.0f, 99.0f, 90.0f)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    pfImageView.image = newImage;
    [self.profilePicButton setImage:pfImageView.image forState:UIControlStateNormal];
    [self.profilePicButton setImage:pfImageView.image forState:UIControlStateSelected];
    [self.profilePicButton setImage:pfImageView.image forState:UIControlStateDisabled];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker; {
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - ParseLayerServiceDelegate

- (void)parseLayerServiceDidSave:(ParseLayerService *)parseLayerService isSuccessful:(BOOL)success {
    if (success) {
        [self switchToEditMode];
        [self disableInputFields];
        [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Profile updated." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to save. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end