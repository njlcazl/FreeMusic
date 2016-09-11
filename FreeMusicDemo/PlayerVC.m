//
//  PlayerVC.m
//  FreeMusicDemo
//
//  Created by 曾祺植 on 5/24/15.
//  Copyright (c) 2015 曾祺植. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerVC.h"
#import "ShowAlert.h"
#import "Helper.h"
#import "Track.h"
#import "TrackNetItem.h"
#import "UIView+i7Rotate360.h"
#import "DOUAudioStreamer.h"
#import "DOUAudioVisualizer.h"
#import "ASValueTrackingSlider.h"


static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface PlayerVC ()
{
    DOUAudioStreamer *streamer;
    DOUAudioVisualizer *audioVisualizer;
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet UILabel *TrackInfo;
@property (weak, nonatomic) IBOutlet UILabel *currentLable;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlayPause;
@property (weak, nonatomic) IBOutlet UIButton *PreBtn;
@property (weak, nonatomic) IBOutlet UIButton *NxtBtn;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIImageView *AlbumBackground;
@property (weak, nonatomic) IBOutlet UIImageView *AlbumShow;

@property (strong, nonatomic) UIImage *AlbumImage;
@property (strong, nonatomic) MPMediaItemArtwork *albumImg;
@property (strong, nonatomic) NSMutableDictionary *TrackDic;

@end

@implementation PlayerVC


- (NSMutableDictionary *)TrackDic
{
    if (!_TrackDic) {
        _TrackDic = [[NSMutableDictionary alloc] init];
    }
    return _TrackDic;
}

- (void)viewDidLoad
{
    UIImage *volumeImg = [Helper imageCompressForWidth:[UIImage imageNamed:@"volume_progress_btn.png"] targetWidth:15];
    [self.progressSlider setThumbImage:volumeImg forState:UIControlStateNormal];
    [self.volumeSlider setThumbImage:volumeImg forState:UIControlStateNormal];
    [self.volumeSlider setThumbImage:volumeImg forState:UIControlStateHighlighted];
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
//    [self.volumeSlider setNumberFormatter:formatter];
//    self.volumeSlider.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:26];
//    self.volumeSlider.popUpViewAnimatedColors = @[[UIColor purpleColor], [UIColor redColor], [UIColor orangeColor]];
    [self.progressSlider addTarget:self action:@selector(actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
    [self.volumeSlider addTarget:self action:@selector(actionSliderVolume:) forControlEvents:UIControlEventValueChanged];
    //将AlbunShow的视图剪裁成圆形
    self.AlbumShow.layer.masksToBounds = YES;
    self.AlbumShow.layer.cornerRadius = self.AlbumShow.frame.size.width / 2;
    [self.PreBtn.imageView setContentMode:UIViewContentModeScaleToFill];
    UIImage *preImg = [Helper imageCompressForWidth:[UIImage imageNamed:@"player_btn_prev_normal"] targetWidth:20];
    [self.PreBtn setImage:preImg forState:UIControlStateNormal];                            //设置按钮图片
    UIImage *preDisableImg = [Helper imageCompressForWidth:[UIImage imageNamed:@"player_btn_prev_disable"] targetWidth:20];
    [self.PreBtn setImage:preDisableImg forState:UIControlStateDisabled];
    UIImage *preSelectImg = [Helper imageCompressForWidth:[UIImage imageNamed:@"player_btn_prev_select"] targetWidth:20];
    [self.PreBtn setImage:preSelectImg forState:UIControlStateSelected];
    UIImage *nextImg = [Helper imageCompressForWidth:[UIImage imageNamed:@"player_btn_next_normal"] targetWidth:20];
    [self.NxtBtn setImage:nextImg forState:UIControlStateNormal];
    UIImage *nextSelectImg = [Helper imageCompressForWidth:[UIImage imageNamed:@"player_btn_next_select"] targetWidth:20];
    [self.NxtBtn setImage:nextSelectImg forState:UIControlStateSelected];
    UIImage *playImg = [Helper imageCompressForWidth:[UIImage imageNamed:@"player_btn_play_normal"] targetWidth:20];
    [self.buttonPlayPause setImage:playImg forState:UIControlStateNormal];
    [self.buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"player_btn_playring_normal"]
                                    forState:UIControlStateNormal];
    [self.buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"player_btn_playring_select"]
                                    forState:UIControlStateSelected];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resumeRotate)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

}

- (void)ConfigureUI
{
//
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{                             //网络异步获取专辑图片
        self.AlbumImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentTrack.albumURL]]];
        MPMediaItemArtwork *tempAlbum = [[MPMediaItemArtwork alloc] initWithImage:self.AlbumImage];
        dispatch_async(dispatch_get_main_queue(), ^{                                                             //设置背景图片和专辑图片
            [self.TrackDic setObject:tempAlbum forKey:MPMediaItemPropertyArtwork];
            MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
            [center setNowPlayingInfo:self.TrackDic];
            [self.AlbumBackground setImage:self.AlbumImage];
            [self.AlbumShow setImage:self.AlbumImage];
            // Do any additional setup after loading the view, typically from a nib.
            //使用图片初始化背景色
            //实现模糊效果
            if (self.AlbumBackground.subviews.count > 0) {
                [[self.AlbumBackground.subviews objectAtIndex:0] removeFromSuperview];
            }
            UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            visualEffectView.frame = self.AlbumBackground.bounds;
            visualEffectView.alpha = 1.0;
            [self.AlbumBackground addSubview:visualEffectView];
            
        });
    });
}


- (void)resumeRotate
{
    [self.AlbumShow stopAnimation];
    [self.AlbumShow rotate360WithDuration:5                                                              //添加旋转动画
                              repeatCount:[self.currentTrack.duration intValue] / 1000 / 5
                               timingMode:i7Rotate360TimingModeLinear];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl)
    {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPause:
                [self PlayAct];
                break;
            case UIEventSubtypeRemoteControlPlay:
                [self PlayAct];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                //do something
                [self PreAct];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                //do something
                [self NextAct];
                break;
            default:
            break;
                
        }
    }
}

- (void)setArtWork{
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    [self.TrackDic setObject:self.currentTrack.albumName forKey:MPMediaItemPropertyAlbumTitle];
    [self.TrackDic setObject:self.currentTrack.artistName forKey:MPMediaItemPropertyArtist];
    [self.TrackDic setObject:self.currentTrack.trackName forKey:MPMediaItemPropertyTitle];
    [self.TrackDic setObject:@([self.currentTrack.duration doubleValue] / 1000) forKey:MPMediaItemPropertyPlaybackDuration];
    [center setNowPlayingInfo:self.TrackDic];

}

- (void)PlayAct
{
    if ([streamer status] == DOUAudioStreamerPaused ||
        [streamer status] == DOUAudioStreamerIdle) {
        if ([streamer status] == DOUAudioStreamerPaused) {
            [self.AlbumShow resumeAnimation];
        } else {
            [self.AlbumShow rotate360WithDuration:5                                                              //添加旋转动画
                                      repeatCount:[self.currentTrack.duration intValue] / 1000 / 5
                                       timingMode:i7Rotate360TimingModeLinear];
        }
        [streamer play];
    } else {
        [streamer pause];
        [self.AlbumShow pauseAnimation];
    }
}

- (IBAction)PlayTrack:(id)sender
{
    [self PlayAct];
}

- (IBAction)StopTrack:(id)sender
{
    [streamer stop];
    [self.AlbumShow stopAnimation];
}

- (void)cancelStreamer
{
    if (streamer != nil) {
        [streamer pause];
        [streamer removeObserver:self forKeyPath:@"status"];
        [streamer removeObserver:self forKeyPath:@"duration"];
        [streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        streamer = nil;
    }
}

- (void)updateBufferingStatus
{
    if ([streamer bufferingRatio] >= 1.0) {
        NSLog(@"sha256: %@", [streamer sha256]);
    }
}

- (void)timerAction:(id)timer
{
    if ([streamer duration] == 0.0) {
        [self.progressSlider setValue:0.0f animated:NO];
    }
    else {
        [self.progressSlider setValue:[streamer currentTime] / [streamer duration] animated:YES];
        int cTime = [[NSNumber numberWithDouble:[streamer currentTime]] intValue];
        self.currentLable.text = [NSString stringWithFormat:@"%02d:%02d", cTime / 60, cTime % 60];
        int dTime = [[NSNumber numberWithDouble:[streamer duration]] intValue];
        self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", dTime / 60, dTime % 60];
    }
    if ([streamer duration] > 0 && fabs([streamer currentTime] - [streamer duration]) < 1.0) {
        [self NextAct];
    }
}

//- (void)_setupHintForStreamer
//{
//    NSUInteger nextIndex = _currentTrackIndex + 1;
//    if (nextIndex >= [_tracks count]) {
//        nextIndex = 0;
//    }
//    
//    [DOUAudioStreamer setHintWithAudioFile:[_tracks objectAtIndex:nextIndex]];
//}

- (void)resetStreamer
{
    [self cancelStreamer];
    NSString *title = [NSString stringWithFormat:@"%@ - %@", self.currentTrack.trackName, self.currentTrack.artistName];
    [self.TrackInfo setText:title];
    
    streamer = [DOUAudioStreamer streamerWithAudioFile:[Track initWithObj:self.currentTrack]];
    [streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];            //添加观察者对象
    [streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
    [streamer play];
    [self setArtWork];
    [self updateBufferingStatus];
//    [self setupHintForStreamer];
}

- (void)updateStatus
{
    UIImage *playImg = [Helper imageCompressForWidth:[UIImage imageNamed:@"player_btn_play_normal"] targetWidth:20];
    UIImage *pauseImg = [Helper imageCompressForWidth:[UIImage imageNamed:@"player_btn_pause_normal"] targetWidth:15];
    switch ([streamer status]) {
        case DOUAudioStreamerPlaying:
            [_buttonPlayPause setImage:pauseImg forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerPaused:
            [_buttonPlayPause setImage:playImg forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerIdle:
            [_buttonPlayPause setImage:playImg forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerFinished:
            break;
            
        case DOUAudioStreamerBuffering:
            break;
            
        case DOUAudioStreamerError:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(timerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [timer invalidate];
//    [streamer stop];
//    [self cancelStreamer];
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.currentIdx = self.currentPath.row;
    self.currentTrack = [self.TrackQueue objectAtIndex:self.currentIdx];
    [self ConfigureUI];
    self.navigationController.navigationBarHidden = YES;                                                 //隐藏导航栏
    //滑动返回
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    [self resetStreamer];
    [self.AlbumShow rotate360WithDuration:5
                              repeatCount:[self.currentTrack.duration intValue] / 1000 / 5
                               timingMode:i7Rotate360TimingModeLinear];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(timerAction:)
                                           userInfo:nil
                                            repeats:YES];
    [self.volumeSlider setValue:[DOUAudioStreamer volume]];
}

- (IBAction)PreTrack:(id)sender
{
    [self PreAct];
}

- (void)PreAct
{
    if (self.currentIdx - 1 >= 0) {
        self.currentTrack = [self.TrackQueue objectAtIndex:self.currentIdx - 1];
        self.currentIdx--;
        [self.AlbumShow stopAnimation];
        [self ConfigureUI];
        [self resetStreamer];
        [self.AlbumShow stopAnimation];
        [self.AlbumShow rotate360WithDuration:5
                                  repeatCount:[self.currentTrack.duration intValue] / 1000 / 5
                                   timingMode:i7Rotate360TimingModeLinear];
        [self.AlbumShow resumeAnimation];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(timerAction:)
                                               userInfo:nil
                                                repeats:YES];
    } else {
        [ShowAlert showErr:@"No more track!"];
    }
}

- (void)NextAct
{
    if (self.currentIdx + 1 < self.TrackQueue.count) {
        self.currentTrack = [self.TrackQueue objectAtIndex:self.currentIdx + 1];
        self.currentIdx++;
        [self.AlbumShow stopAnimation];
        [self ConfigureUI];
        [self resetStreamer];
        [self.AlbumShow rotate360WithDuration:5
                                  repeatCount:[self.currentTrack.duration intValue] / 1000 / 5
                                   timingMode:i7Rotate360TimingModeLinear];
        [self.AlbumShow resumeAnimation];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(timerAction:)
                                               userInfo:nil
                                                repeats:YES];
    } else {
        [ShowAlert showErr:@"No more track!"];
    }
}

- (IBAction)NextTrack:(id)sender
{
    [self NextAct];
}

- (void)actionSliderProgress:(id)sender
{
    [streamer setCurrentTime:[streamer duration] * [self.progressSlider value]];
}

- (void)actionSliderVolume:(id)sender
{
    [DOUAudioStreamer setVolume:[self.volumeSlider value]];
}

@end
