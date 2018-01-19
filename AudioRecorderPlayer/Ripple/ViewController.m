//
//  ViewController.m
//  AudioRecorderPlayer
//
//  Created by JPMEENAA on 09/12/17.
//  Copyright © 2017 JPMEENAA. All rights reserved.
//

#import "ViewController.h"

#import "JPAudioRecorderUI.h"

#import "UIImage+animatedGIF.h"

@interface ViewController ()<JPAudioRecorderUIDelegate>

{
    IBOutlet UIButton *btnVoiceRecord;
    
    JPAudioRecorderUI *recorderUI;
    
    IBOutlet UIButton *btn_gif;
    
    
    IBOutlet UITableView *tableView_playSound;
    
    NSIndexPath *selectedIndex;
    NSURL *fileUrl;
    
    NSMutableArray *arrayMp3Count;
}

@property (strong, nonatomic) IBOutlet UIView *viewTest;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    arrayMp3Count = [[NSMutableArray alloc]init];
    
//    arrayMp3Count
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/mp3",[docPaths objectAtIndex:0]];
    
    NSArray *filelist= [fm contentsAtPath:documentsDirectory];
    
    NSInteger filesCount = [filelist count];
    NSLog(@"filesCount:%lu", (long)filesCount);
    
    
    for (int i = 1; i< filesCount+1; i++)
    {
        NSString *str_index = [NSString stringWithFormat:@"%d",i];
        [arrayMp3Count addObject:str_index];
    }
    
    [tableView_playSound reloadData];
    
    
    fileUrl = [[NSBundle bundleForClass:[self class]] URLForResource:@"1" withExtension:@"gif"];
    
    [btn_gif setImage:[UIImage imageNamed:@"1.gif"] forState:UIControlStateNormal];
    [btn_gif setImage:[UIImage animatedImageWithAnimatedGIFURL:fileUrl] forState:UIControlStateSelected];
    recorderUI = [[JPAudioRecorderUI  alloc]init];
    recorderUI.delegate = self;
    
    [btnVoiceRecord setTitle:@"Show UI" forState:UIControlStateNormal];
   
    
    
    [btnVoiceRecord addTarget:self action:@selector(beginRecordVoice:) forControlEvents:UIControlEventTouchDown];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

- (IBAction)click_animation:(UIButton *)sender
{
    if ([sender isSelected])
    {
        [sender setSelected:NO];
    }
    else
    {
        [sender setSelected:YES];
    }
}


#pragma mark - Private

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma click Mathod

- (void)beginRecordVoice:(UIButton *)button
{
    [[JPAudioRecorderUI sharedInstance]  showRecorderOnView:self.view];
    [JPAudioRecorderUI sharedInstance].controller = self;
    
}

- (void)endConvertWithData:(NSData *)voiceData
{
    NSString *str_nextIndex;
    
    
//    if (arrayMp3Count.count <=0)
//    {
//        str_nextIndex = [NSString stringWithFormat:@"0"];
//    }
//    else
//    {
        str_nextIndex = [NSString stringWithFormat:@"%lu",arrayMp3Count.count+1];
//    }
    
    [arrayMp3Count addObject:str_nextIndex];
    
    NSString *nssstr_nextIndex1 =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
                                  stringByAppendingPathComponent:[NSString stringWithFormat:@"mp3"]] ;
    
    str_nextIndex = [NSString stringWithFormat:@"mp3/%@.mp3",str_nextIndex];
    
    NSError *error;
    NSString *mp3FileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
                             stringByAppendingPathComponent:str_nextIndex];
    
    if (NO ==[[JPAudioRecorderUI sharedInstance] isPathFound:nssstr_nextIndex1])
    {
        __block NSString *img_LocalPath = mp3FileName;
        
        img_LocalPath = [NSString stringWithFormat:@"%@",img_LocalPath];
        
        
         
         [[NSFileManager defaultManager] createDirectoryAtPath:nssstr_nextIndex1 withIntermediateDirectories:NO attributes:nil error:&error];
        
        [[NSFileManager defaultManager] createFileAtPath:mp3FileName
                                                contents:voiceData
                                              attributes:nil];
        
    }
    else
    {
        [[NSFileManager defaultManager] createFileAtPath:mp3FileName
                                                contents:voiceData
                                              attributes:nil];
    }
    
    
    
    
    NSLog(@"recorded data");
    
    [tableView_playSound reloadData];
}


#pragma Mark - tableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayMp3Count.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = nil;
    UITableViewCell * cell  = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:
            cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    UIImageView *btn_play = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, tableView.frame.size.width-20, 40)];
    
    [cell.contentView addSubview:btn_play];
    
    [btn_play setImage:[UIImage imageNamed:@"1.gif"] ];
    
    if (selectedIndex == indexPath)
    {
        [btn_play setImage:[UIImage animatedImageWithAnimatedGIFURL:fileUrl]];
    }
    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedIndex == indexPath)
    {
        selectedIndex = 0;
        [[JPAudioRecorderUI sharedInstance] stop];
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
    
        NSString *str_path = [NSString stringWithFormat:@"%@/mp3/%ld.mp3",documentsDirectory,(long)indexPath.row+1];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/mp3/%ld.mp3",documentsDirectory,(long)indexPath.row]];
    
        [[JPAudioRecorderUI sharedInstance] playWithUrl:url path:str_path];
        selectedIndex = indexPath;
    }
    [tableView reloadData];
    
}


@end
