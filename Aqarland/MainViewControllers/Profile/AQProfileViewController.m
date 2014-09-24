//
//  AQProfileViewController.m
//  Aqarland
//
//  Created by Louise on 12/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQProfileViewController.h"
#import "AQCircleButton.h"

@interface AQProfileViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *contactNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *officeAddressLabel;

@property (weak, nonatomic) IBOutlet AQCircleButton *profilePicButton;
@property (weak, nonatomic) IBOutlet UITextField *contactNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextView *officeAddressTextView;

@end

@implementation AQProfileViewController {
    UserProfile *userProfile;
    UILabel *navigationBarTitleLabel;
    UIButton *editButton;
    UIButton *saveButton;
    UIBarButtonItem *rightBarButtonItem;
    NSMutableString *addressPlaceHolder;
    NSData *selectedProfilePic;
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
    
    self.contactNumberLabel.font = [UIFont fontWithName: @"Roboto-Light" size:15.0f];
    self.emailAddressLabel.font = [UIFont fontWithName: @"Roboto-Light" size:15.0f];
    self.officeAddressLabel.font = [UIFont fontWithName: @"Roboto-Light" size:15.0f];
    self.contactNumberTextField.font = [UIFont fontWithName: @"Roboto-Light" size:15.0f];
    self.emailAddressTextField.font = [UIFont fontWithName: @"Roboto-Light" size:15.0f];
    self.officeAddressTextView.font = [UIFont fontWithName: @"Roboto-Light" size:15.0f];
    self.officeAddressTextView.textColor = [UIColor lightGrayColor];

    [self.profilePicButton drawCircleButton:[UIColor lightGrayColor]];
}

- (void)viewWillAppear:(BOOL)animated {
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
    
    navigationBarTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    navigationBarTitleLabel.backgroundColor = [UIColor clearColor];
    navigationBarTitleLabel.font = [UIFont fontWithName: @"Roboto-Light" size:18.0f];
    navigationBarTitleLabel.textAlignment = NSTextAlignmentCenter;
    navigationBarTitleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = navigationBarTitleLabel;
    navigationBarTitleLabel.text = @"";
    [navigationBarTitleLabel sizeToFit];
    
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
    userProfile = [[ParseLayerService sharedInstance] fetchCurrentUserProfile];
    
    NSLog(@"userProfile : %@", userProfile);
    
    navigationBarTitleLabel.text = [userProfile valueForKey:@"fullName"];
    self.contactNumberTextField.placeholder = [userProfile valueForKey:@"phoneNumber"];
    self.emailAddressTextField.placeholder = @"Email Address";
    
    addressPlaceHolder = [[NSMutableString alloc] init];
    if ([userProfile valueForKey:@"address"]) {
        [addressPlaceHolder appendString:[NSString stringWithFormat:@"%@, ", [userProfile valueForKey:@"address"]]];
    }
    if ([userProfile valueForKey:@"city"]) {
        [addressPlaceHolder appendString:[NSString stringWithFormat:@"%@, ", [userProfile valueForKey:@"city"]]];
    }
    if ([userProfile valueForKey:@"country"]) {
        [addressPlaceHolder appendString:[userProfile valueForKey:@"country"]];
    }
    
    self.officeAddressTextView.text = addressPlaceHolder;
}

- (void)didTapEditButton {
    [self enableInputFields];
    [self switchToSaveMode];
}
- (void)didTapSaveButton {
    [self switchToEditMode];
    [self disableInputFields];
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
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
    selectedProfilePic = UIImageJPEGRepresentation(image, 0.1);
    self.profilePicButton.imageView.image = [UIImage imageWithData:selectedProfilePic];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker; {
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
}

@end
