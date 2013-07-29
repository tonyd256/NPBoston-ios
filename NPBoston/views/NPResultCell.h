//
//  NPResultCell.h
//  NPBoston
//
//  Created by Tony DiPasquale on 5/1/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@class FBProfilePictureView;

@interface NPResultCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *cellView;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *pictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *resultLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentsLabel;
@property (strong, nonatomic) IBOutlet UITextView *commentsText;

@end
