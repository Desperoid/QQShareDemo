//
//  ViewController.m
//  QQshareDemo
//
//  Created by Geng on 2016/12/9.
//  Copyright © 2016年 Geng. All rights reserved.
//

#import "ViewController.h"
#import "ShareViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *shareType;
@end

@implementation ViewController
static NSString * const cellIdentifier = @"cellIdentifier";
- (void)viewDidLoad {
   [super viewDidLoad];
   [self setEdgesForExtendedLayout:UIRectEdgeNone];
   self.tableView.tableFooterView = [[UIView alloc] init];
   self.shareType = @[@"纯文字分享",
                      @"纯图片分享",
                      @"新闻分享",
                      @"音乐分享",
                      @"文件分享"];
   // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 56;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [self.shareType count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (indexPath.row < [self.shareType count]) {
      
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
      if (!cell) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
      }
      cell.textLabel.text = self.shareType[indexPath.row];
      return cell;
   }
   return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([segue.identifier isEqualToString:@"toShareVC"]) {
      ShareViewController *controller = segue.destinationViewController;
      controller.title = @"share";
      NSUInteger index = [self.tableView indexPathForCell:sender].row;
      ShareType t;
      switch (index) {
         case 0:
            t = ShareTypeText;
            break;
         case 1:
            t = ShareTypeImage;
            break;
         case 2:
            t = ShareTypeURL;
            break;
         case 3:
            t = ShareTypeMusic;
            break;
         case 4:
            t = ShareTypeFile;
            break;
         default:
            break;
      }
      controller.shareType = t;
   }
}


@end
