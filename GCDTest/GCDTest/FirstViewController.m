//
//  FirstViewController.m
//  GCDTest
//
//  Created by Haitang on 2018/3/8.
//  Copyright © 2018年 Haitang. All rights reserved.
//

#import "FirstViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GCDTest-Swift.h"
@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    Person.shared.name = @"12312";
    // Do any additional setup after loading the view from its nib.
//    [self GCDTest];
//    [self barrierTest];
//    [self groupTest];
    [self syncTest];
//    [self singleTest];
}
- (void)singleTest{

}

- (void)syncTest{
    dispatch_queue_t queue = dispatch_queue_create("serial", nil);
    NSLog(@"start%@",[NSDate date]);
    dispatch_sync(queue, ^{
        NSLog(@"sleep end %@",[NSDate date]);
    });
    NSLog(@"end%@",[NSDate date]);

}

- (void)groupTest{

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_async(group, queue, ^{
        dispatch_async(queue, ^{
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1520592255523&di=fdd6776fbd93709d534a625fdc5cd5cc&imgtype=0&src=http%3A%2F%2Fd.hiphotos.baidu.com%2Fzhidao%2Fpic%2Fitem%2F35a85edf8db1cb1302275b6cdf54564e92584b06.jpg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                NSLog(@"任务一");

            }];
        });
    });
    dispatch_group_async(group, queue, ^{
        dispatch_async(queue, ^{
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1520592255523&di=fdd6776fbd93709d534a625fdc5cd5cc&imgtype=0&src=http%3A%2F%2Fd.hiphotos.baidu.com%2Fzhidao%2Fpic%2Fitem%2F35a85edf8db1cb1302275b6cdf54564e92584b06.jpg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                NSLog(@"任务二");
            }];
        });
    });

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 合并图片
        NSLog(@"notification");
    });
}

- (void)barrierTest{
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        dispatch_async(queue, ^{
            sleep(1);

            NSLog(@"任务1");
        });

    });
    dispatch_async(queue, ^{
        dispatch_async(queue, ^{

        sleep(2);

        NSLog(@"任务2");
        });

    });
    dispatch_async(queue, ^{
        dispatch_async(queue, ^{

        sleep(3);
        NSLog(@"任务3");
        });
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"任务4");

    });
    dispatch_async(queue, ^{
        NSLog(@"任务5");

    });
    dispatch_async(queue, ^{
        NSLog(@"任务6");
    });



}

//任务1
void showStringForTask1 (void *obj) {
    sleep(3);
    NSString *objString = (__bridge NSString *)obj;
    NSLog(@"异步调度组任务1:%@ 是否主线程?:%@",objString,[NSThread currentThread].isMainThread?@"YES":@"NO");
}
//任务2
void showStringForTask2 (void *obj) {
    sleep(3);
    NSString *objString = (__bridge NSString *)obj;
    NSLog(@"异步调度组任务2:%@ 是否主线程?:%@",objString,[NSThread currentThread].isMainThread?@"YES":@"NO");
}
//任务3
void showStringForTask3 (void *obj) {
    sleep(3);
    NSString *objString = (__bridge NSString *)obj;
    NSLog(@"异步调度组任务3:%@ 是否主线程?:%@",objString,[NSThread currentThread].isMainThread?@"YES":@"NO");
}
//全部任务结束回调
void allTaskNofify(void *obj)
{
    NSLog(@"分组任务添加完毕 是否主线程:%@",[NSThread currentThread].isMainThread?@"YES":@"NO");
}
- (void)GCDTest{

    /**
     创建 并发队列talentQueue
     参数 "TalentC.dispatch.queue.test" 队列的标记 可自定义
     参数 DISPATCH_QUEUE_CONCURRENT 并发队列 (同时可选则 DISPATCH_QUEUE_SERIAL 串行队列)
     返回 dispatch_queue_t 队列对象 dispatch_object
     */
    dispatch_queue_t talentQueue = dispatch_queue_create("TalentC.dispatch.queue.test", DISPATCH_QUEUE_CONCURRENT);
    //创建调度组
    dispatch_group_t talentGroup = dispatch_group_create();
    /**
     创建任务1
     @"我是参数" 参数可以使任意数据类型
     showStringForTask1 任务函数 函数类型可以查看dispatch_function_t
     */
    dispatch_group_async_f(talentGroup, talentQueue, @"我是参数", showStringForTask1);
    //创建任务2
    dispatch_group_async_f(talentGroup, talentQueue, @"我是一只小蜜蜂哈哈哈", showStringForTask2);
    //创建任务3
    dispatch_group_async_f(talentGroup, talentQueue, @"再来一个任务吧", showStringForTask3);
    //组任务结果汇总
    dispatch_group_notify_f(talentGroup, talentQueue, nil, allTaskNofify);
    NSLog(@"分组任务添加完毕 是否主线程:%@",[NSThread currentThread].isMainThread?@"YES":@"NO");



//    /**
//     创建 并发队列talentQueue
//     参数 "TalentC.dispatch.queue.test" 队列的标记 可自定义
//     参数 DISPATCH_QUEUE_CONCURRENT并发队列 (同时可选则 DISPATCH_QUEUE_SERIAL 串行队列)
//     返回 dispatch_queue_t 队列对象 dispatch_object
//     */
//    dispatch_queue_t talentQueue = dispatch_queue_create("TalentC.dispatch.queue.test", DISPATCH_QUEUE_CONCURRENT);
//    //创建调度组
//    dispatch_group_t talentGroup = dispatch_group_create();
//    //创建任务
//    for (int i = 1; i <= 5; i ++) {
//        dispatch_group_async(talentGroup, talentQueue, ^{
//            dispatch_async(talentQueue, ^{
//                sleep(3);
//                NSString *string = [NSString stringWithFormat:@"任务%d",i];
//                NSLog(@"%@ 是否主线程:%@",string,[NSThread currentThread].isMainThread?@"YES":@"NO");
//            });
//        });
//    }
//    //分组结果通知
//    dispatch_group_notify(talentGroup, talentQueue, ^{
//        NSLog(@"thread: %p 是否主线程?:%@ 任务全部执行完毕*********",[NSThread currentThread],[NSThread currentThread].isMainThread?@"YES":@"NO");
//    });
//    NSLog(@"分组任务添加完毕 是否主线程:%@",[NSThread currentThread].isMainThread?@"YES":@"NO");



//    dispatch_queue_t queue = dispatch_queue_create("并行", DISPATCH_QUEUE_CONCURRENT);
//        dispatch_sync(queue, ^{
//            NSLog(@"任务二");
//        });
//        NSLog(@"任务一");


//    dispatch_queue_t queue = dispatch_queue_create("并行", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_barrier_sync(queue, ^{
//        dispatch_async(queue, ^{
//            NSLog(@"任务二");
//        });
//        dispatch_async(queue, ^{
//            NSLog(@"任务三");
//        });
//        //睡眠2秒
//        [NSThread sleepForTimeInterval:2];
//        NSLog(@"任务一");
//    });


//    dispatch_queue_t queue = dispatch_queue_create("com.demo.serialQueue", DISPATCH_QUEUE_SERIAL);
//    NSLog(@"1");
//    // 任务1
//    dispatch_async(queue, ^{
//        NSLog(@"2");// 任务2
//        dispatch_sync(queue, ^{
//            NSLog(@"3");// 任务3
//        });
//        NSLog(@"4");// 任务4
//    });
//    NSLog(@"5"); // 任务5
//
//
//
//    NSLog(@"1"); // 任务1
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"2"); // 任务2
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            NSLog(@"3"); // 任务3
//        });
//        NSLog(@"4"); // 任务4
//    });
//    NSLog(@"5"); // 任务5

//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"1"); // 任务1
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            NSLog(@"2"); // 任务2
//        });
//        NSLog(@"3"); // 任务3
//    });
//    NSLog(@"4"); // 任务4
//    while (1) { }
//    NSLog(@"5"); // 任务5
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
