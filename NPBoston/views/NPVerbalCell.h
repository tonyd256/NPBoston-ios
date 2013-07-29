//
//  NPVerbalCell.h
//  NPBoston
//
//  Created by Tony DiPasquale on 4/29/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

@class FBProfilePictureView;

@interface NPVerbalCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePic;

@end
