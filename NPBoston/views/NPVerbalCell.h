//
//  NPVerbalCell.h
//  NPBoston
//
//  Created by Tony DiPasquale on 4/29/13.
//  Copyright (c) 2013 Tony DiPasquale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface NPVerbalCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePic;

@end
