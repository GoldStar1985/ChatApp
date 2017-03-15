/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EMGroupUpdateSubjectViewController.h"

@interface EMGroupUpdateSubjectViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *groupSubject;

@property (nonatomic, strong) UITextField *subjectField;

@end

@implementation EMGroupUpdateSubjectViewController

- (instancetype)initWithGroupId:(NSString *)aGroupId
                        subject:(NSString *)aSubject
{
    self = [self init];
    if (self) {
        _groupId = aGroupId;
        _groupSubject = aSubject;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"title.updateGroupName", @"Update Group Name");

    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    backButton.accessibilityIdentifier = @"back";
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"common.done", @"Done") style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    [self.navigationItem setRightBarButtonItem:saveItem];
    
    self.view.backgroundColor = [UIColor whiteColor];

    CGRect frame = CGRectMake(20, 20, self.view.frame.size.width - 40, 40);
    self.subjectField = [[UITextField alloc] initWithFrame:frame];
    self.subjectField.layer.cornerRadius = 5.0;
    self.subjectField.layer.borderWidth = 1.0;
    self.subjectField.placeholder = NSLocalizedString(@"group.updateName", @"Please input group subject");
    self.subjectField.text = self.groupSubject;
    [self.view addSubview:self.subjectField];
    
    frame.origin = CGPointMake(frame.size.width - 5.0, 0.0);
    frame.size = CGSizeMake(5.0, 40.0);
    UIView *holder = [[UIView alloc] initWithFrame:frame];
    self.subjectField.rightView = holder;
    self.subjectField.rightViewMode = UITextFieldViewModeAlways;
    
    frame.origin = CGPointMake(0.0, 0.0);
    holder = [[UIView alloc] initWithFrame:frame];
    self.subjectField.leftView = holder;
    self.subjectField.leftViewMode = UITextFieldViewModeAlways;
    self.subjectField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - action
- (void)back
{
    if ([_subjectField isFirstResponder]) {
        [_subjectField resignFirstResponder];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAction
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.groupId type:EMConversationTypeGroupChat createIfNotExist:NO];
    EMError *error = nil;
    EMGroup *retGroup = [[EMClient sharedClient].groupManager changeGroupSubject:self.subjectField.text forGroup:self.groupId error:&error];
    if (!error) {
        if ([self.groupId isEqualToString:conversation.conversationId]) {
            NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
            [ext setObject:retGroup.subject forKey:@"subject"];
            [ext setObject:[NSNumber numberWithBool:retGroup.isPublic] forKey:@"isPublic"];
            conversation.ext = ext;
        }
    }
    [self back];
}

@end
