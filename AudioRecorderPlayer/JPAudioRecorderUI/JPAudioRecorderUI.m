//
//  JPAudioRecorderUI.m
//  AudioRecorderPlayer
//
//  Created by JPMEENAA on 10/12/17.
//  Copyright © 2017 JPMEENAA. All rights reserved.
//

#import "JPAudioRecorderUI.h"
#import "JPCARLayer.h"

#import "UIImage+animatedGIF.h"

#import "lame.h"

#import <AVFoundation/AVFoundation.h>

#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioRecorder.h>


@interface JPAudioRecorderUI()<AVAudioPlayerDelegate,AVAudioRecorderDelegate>
{
    JPCARLayer *pulse;
    UIButton *btn_record;
    UIButton *btn_play;
    
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
    int recordEncoding;
    
    
    
    enum
    {
        ENC_AAC = 1,
        ENC_ALAC = 2,
        ENC_IMA4 = 3,
        ENC_ILBC = 4,
        ENC_ULAW = 5,
        ENC_PCM = 6,
    } encodingTypes;
}

@property (nonatomic, strong)UIView *view_BG;
@property (nonatomic, strong)UIView *beaconView;

@property (nonatomic, strong)UIView *view_effectBG;
@property (nonatomic, strong)UIView *view_player;

@end
static JPAudioRecorderUI *sharedInstance;
@implementation JPAudioRecorderUI
@synthesize view_BG;
@synthesize beaconView;
@synthesize view_effectBG;
@synthesize view_player;
@synthesize controller;

+ (JPAudioRecorderUI *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JPAudioRecorderUI alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Init Methods

- (id)initWithDelegate:(id<JPAudioRecorderUIDelegate>)delegate
{
    if (self = [super init])
    {
        _delegate = delegate;
    }
    return self;
}


#pragma mark - UI DESIGN START

-(void)showRecorderOnView :(UIView *)baseView
{
    recordEncoding = ENC_AAC;
    
    
    view_BG = [[UIView alloc]initWithFrame:CGRectMake(0, -baseView.frame.size.height,baseView.frame.size.width, baseView.frame.size.height)];
    view_BG.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    [baseView addSubview:view_BG];
    
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(swipeUP:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [view_BG addGestureRecognizer:swipeUp];
    
    
    view_effectBG = [[UIView alloc]initWithFrame:CGRectMake(0, 0,baseView.frame.size.width, 300)];
    view_effectBG.backgroundColor = [UIColor clearColor];
    [view_BG addSubview:view_effectBG];
    
    
    beaconView = [[UIView alloc]initWithFrame:CGRectMake((view_effectBG.frame.size.width-60)/2, (view_effectBG.frame.size.width-60)/2,60,60)];
    beaconView.backgroundColor = [UIColor clearColor];
    [view_effectBG addSubview:beaconView];
    
    
    UIImageView *img_mic = [[UIImageView alloc]initWithFrame:CGRectMake(15, 20,30,30)];
    img_mic.image = [UIImage  imageNamed:@"mic"];
    [beaconView addSubview:img_mic];

    
    
    btn_record = [[UIButton alloc]initWithFrame:CGRectMake((baseView.frame.size.width-60)/2, baseView.frame.size.height-80,60, 60)];
    [view_BG addSubview:btn_record];
    
    [btn_record addTarget:self action:@selector(beginRecordVoice:) forControlEvents:UIControlEventTouchDown];
    
    [btn_record addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
    [btn_record addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchDragOutside];
    
    
    [btn_record setImage:[UIImage imageNamed:@"record_off"] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:3.0f
                          delay:0.5
         usingSpringWithDamping:0.5
          initialSpringVelocity:5.0
                        options:0
                     animations:^{ view_BG.frame = CGRectMake(0, 0,baseView.frame.size.width, baseView.frame.size.height); }
                     completion:^(BOOL finished)
                    {

                        
                     }];
    
    
    [self playerUI];
    
}

-(void)playerUI
{
    view_player = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(view_effectBG.frame), view_effectBG.frame.size.width, 60)];
    view_player.hidden = YES;
    
    UIImageView *img_playerBG = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, view_effectBG.frame.size.width, 60)];
    img_playerBG.image = [UIImage imageNamed:@"img_playerBG"];
    [view_player addSubview:img_playerBG];
    
    
    NSURL *fileUrl = [[NSBundle bundleForClass:[self class]] URLForResource:@"left-arrow" withExtension:@"gif"];
    UIImageView *img_Left =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, view_player.frame.size.width/2, view_player.frame.size.height)];
    img_Left.image = [UIImage animatedImageWithAnimatedGIFURL:fileUrl];
    [view_player addSubview:img_Left];
    
    UIView *view_Left = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view_player.frame.size.width/2, view_player.frame.size.height)];
    view_Left.userInteractionEnabled = YES;
    view_Left.backgroundColor = [UIColor clearColor];
    [view_player addSubview:view_Left];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(swipeLEFT:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [view_Left addGestureRecognizer:swipeLeft];
    
    
    fileUrl = [[NSBundle bundleForClass:[self class]] URLForResource:@"right-arrow" withExtension:@"gif"];
    UIImageView *img_Right =[[UIImageView alloc]initWithFrame:CGRectMake(view_player.frame.size.width/2, 0, view_player.frame.size.width/2, view_player.frame.size.height)];
    img_Right.image = [UIImage animatedImageWithAnimatedGIFURL:fileUrl];
    [view_player addSubview:img_Right];
    
    UIView *view_Right = [[UIView alloc]initWithFrame:CGRectMake(view_player.frame.size.width/2, 0, view_player.frame.size.width/2, view_player.frame.size.height)];
    view_Right.userInteractionEnabled = YES;
    view_Right.backgroundColor = [UIColor clearColor];
    [view_player addSubview:view_Right];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(swipeRIGHT:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [view_Right addGestureRecognizer:swipeRight];
    
    btn_play = [[UIButton alloc]initWithFrame:CGRectMake((view_player.frame.size.width-30)/2,(view_player.frame.size.height-30)/2,30,30)];
    [view_player addSubview:btn_play];
    
    [btn_play addTarget:self action:@selector(playRecording:) forControlEvents:UIControlEventTouchDown];
    
    [btn_play setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [btn_play setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [view_BG addSubview:view_player];
    
}

#pragma mark - UI DESIGN END

#pragma mark - Voice Record ON/OFF EVENT

- (void)beginRecordVoice:(UIButton *)button
{
    view_BG.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [btn_record setImage:[UIImage imageNamed:@"record_on"] forState:UIControlStateNormal];
    
    pulse = [JPCARLayer layer];
    [beaconView.superview.layer insertSublayer:pulse below:beaconView.layer];
    pulse.position = beaconView.center;
    
    [pulse start];
    [self startRecording];
}

- (void)endRecordVoice:(UIButton *)button
{
    view_BG.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    [btn_record setImage:[UIImage imageNamed:@"record_off"] forState:UIControlStateNormal];
    [pulse stop];
    [self stopRecording];
    view_player.hidden = NO;
}

#pragma mark - Voice Record ON/OFF EVENT


#pragma mark - Voice Close

- (void)swipeUP:(UISwipeGestureRecognizer*)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp)
    {
//        [self stopRecording];
        [pulse stop];
        [btn_record setImage:[UIImage imageNamed:@"record_off"] forState:UIControlStateNormal];
        view_BG.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        
        [UIView animateWithDuration:6.0f
                              delay:1.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:5.0
                            options:0
                         animations:^{ view_BG.frame = CGRectMake(0,-view_BG.frame.size.height,view_BG.frame.size.width, view_BG.frame.size.height); }
                         completion:^(BOOL finished)
         {
             
             
         }];
        
    }

}


#pragma mark - Voice Record ON/OFF MATHOD

-(void)startRecording
{
    audioRecorder = nil;
    
    // Init audio with record capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err)
    {
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err)
    {
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    
    
    NSMutableDictionary *recorderSettings = [[NSMutableDictionary alloc] init];
    

    
    recorderSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,[NSNumber numberWithInt: kAudioFormatLinearPCM], AVFormatIDKey,[NSNumber numberWithInt: 2], AVNumberOfChannelsKey, [NSNumber numberWithFloat:12000.0], AVSampleRateKey,[NSNumber numberWithFloat:14000.0],AVEncoderBitRateKey, nil];

    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recordTest.caf", recDir]];

    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recorderSettings error:&error];
    audioRecorder.delegate = self;
    [audioRecorder prepareToRecord];
    audioRecorder.meteringEnabled = YES;

    
    if(!audioRecorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning" message: [err localizedDescription] delegate: nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"message: @"Audio input hardware not available"
                                  delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    
    if ([audioRecorder prepareToRecord] == YES)
    {
        [audioRecorder record];
    }else {
        NSInteger errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode); 
        
    }
    NSLog(@"recording");
}

-(void) stopRecording
{
    NSLog(@"stopRecording");
    [audioRecorder stop];
    NSLog(@"stopped");
    
    [self toMp3];
}
#pragma mark - Voice Record ON/OFF MATHOD

#pragma mark - Listen Recordrd Sound
-(IBAction) playRecording :(UIButton *)button
{
    if ([button isSelected])
    {
        [button setSelected:NO];
        NSLog(@"stopPlaying");
        [self stop];
        NSLog(@"stopped");
    }
    else
    {
        [button setSelected:YES];
        NSLog(@"playRecording");
        // Init audio with playback capability
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        NSError *error = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *str_path = [self mp3Path];;
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recordTest.mp3",documentsDirectory]];
        
        if (![[NSFileManager defaultManager] isReadableFileAtPath:str_path ])
        {
            [self playRecording : btn_play];
            return;
        }
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        audioPlayer.numberOfLoops = 0;
        audioPlayer.delegate = self;
        [audioPlayer play];
        NSLog(@"playing");
    }
    
}

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player
                        successfully: (BOOL) flag {
    if (flag==YES) {
        
        [self playRecording : btn_play];
    }
}

-(void)playWithUrl:(NSURL *)url_file path:(NSString *)str_path
{
    [audioPlayer stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:str_path ])
    {
        [self playRecording : btn_play];
        return;
    }
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url_file error:&error];
    audioPlayer.numberOfLoops = 0;
    audioPlayer.delegate = self;
    [audioPlayer play];
    
}
-(void)stop
{
    [audioPlayer stop];
}

#pragma mark - Delete Recording
- (void)swipeLEFT:(UISwipeGestureRecognizer*)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        view_player.hidden = YES;

        NSString *str_mp3Path = [self mp3Path];
        
        [[NSFileManager defaultManager] removeItemAtPath:str_mp3Path error:nil];
    }
}

#pragma mark - Send Recording and View Close
- (void)swipeRIGHT:(UISwipeGestureRecognizer*)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
    {
        _delegate = controller;
        
        if (_delegate && [_delegate respondsToSelector:@selector(endConvertWithData:)])
        {
            NSData *voiceData = [NSData dataWithContentsOfFile:[self mp3Path]];
            [_delegate endConvertWithData:voiceData];
        }
        else
        {
            NSLog(@"Not Delegating. I dont know why.");
        }
        
    }
}


#pragma mark - Utility mathod for Save file Path

- (NSString *)cafPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *str_path = [NSString stringWithFormat:@"%@/recordTest.caf",documentsDirectory];
    return str_path;
}

- (NSString *)mp3Path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *str_path = [NSString stringWithFormat:@"%@/recordTest.mp3",documentsDirectory];
    return str_path;
}
#pragma mark - Convert File

- (void) toMp3
{
    NSString *cafFilePath =[self cafPath];
    
    NSString *mp3FilePath = [self mp3Path];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(convertMp3Finish)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

- (void) convertMp3Finish
{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    NSInteger fileSize =  [self getFileSize:[self mp3Path]];
    NSString *str_cafPath = [self cafPath];
    [[NSFileManager defaultManager] removeItemAtPath:str_cafPath error:nil];
    NSLog(@"%ld",(long)fileSize);
}

- (NSInteger) getFileSize:(NSString*) path
{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else
    {
        return -1;
    }
}


-(BOOL )isPathFound :(NSString *)str_imagePath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:str_imagePath])
    {
        return NO;
    }
    
    return YES;
}

@end
