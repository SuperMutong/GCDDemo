//
//  ViewController.swift
//  GCDTest
//
//  Created by Haitang on 2018/3/8.
//  Copyright © 2018年 Haitang. All rights reserved.
//

import UIKit
struct TaskGenerater {
   static var index:Int = 0
    static var lock: Int = 0

   static func generate() -> Int {
        objc_sync_enter(self)
        TaskGenerater.index += 1
        let value = TaskGenerater.index
        objc_sync_exit(self)
        return value
    }
}


class ViewController: UIViewController {
    var index:Int = 0
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print(Person.shared.name ?? "123")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        GCDTest()
//        mainAsyncTest()
//        afterFunc()
//        groupFunc()
//        barrierFunc()
//        applyFunc()
//        queueSyncFunc()
//        lockFunc()
//        singleFunc()
//        asyncFunc()
//        groupWait()
//        suspend()
//        semaphoreFunc()
        sychronized()
    }

    func sychronized(){
        for _ in 0...2{
            DispatchQueue.global(qos: .default).async {
                for _ in 0...10{
                    print(TaskGenerater.generate())
                }
            }
        }
    }
    func semaphoreFunc(){
        let semaphore:DispatchSemaphore = DispatchSemaphore(value: 2)
        let queue:DispatchQueue = DispatchQueue.global(qos: .default)
        queue.async {
            let  result:DispatchTimeoutResult = semaphore.wait(timeout: DispatchTime.distantFuture)
            self.PrintLog("1 start")
            self.PrintLog(result)
            sleep(2)
            self.PrintLog("task 1 end")
            semaphore.signal()
        }
        queue.async {
            let  result:DispatchTimeoutResult = semaphore.wait(timeout: DispatchTime.distantFuture)
            self.PrintLog("2 start")

            self.PrintLog(result)
            sleep(2)
            self.PrintLog("task 2 end")
            semaphore.signal()
        }
        queue.async {
            let  result:DispatchTimeoutResult = semaphore.wait(timeout: DispatchTime.distantFuture)
            self.PrintLog("3 start")
            self.PrintLog(result)
            sleep(2)
            self.PrintLog("task 3 end")
            semaphore.signal()
        }
    }


    func suspend(){
//        let queue:DispatchQueue = DispatchQueue(label: "suspend" ,attributes:.concurrent)
        let queue:DispatchQueue = DispatchQueue.global(qos: .default)
        queue.async {
            sleep(5)
            self.PrintLog("After 5 seconds")
        }
        queue.async {
            sleep(5)
            self.PrintLog("After 5 seconds again")
        }

        self.PrintLog("sleep 1 second ...")
        sleep(1)

        self.PrintLog("suspend..")
        queue.suspend()

        self.PrintLog("sleep 10 second ...")
        sleep(10)

        self.PrintLog("resume")
        queue.resume()
    }

    func groupWait(){
        let group:DispatchGroup = DispatchGroup()
        let queue:DispatchQueue = DispatchQueue.global(qos: .default)
        
        queue.async(group: group) {
            //
//            DispatchQueue.main.async {
                print("main_start")
                sleep(2)
//                print("main_end")
//
//            }
            print("first group end")
        }
        group.wait(timeout: DispatchTime.distantFuture)

        queue.async(group: group) {

            print("second group start")
            sleep(2)
            print("second group end")
        }
        print("group end");
    }

    func asyncFunc(){
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "aaa")
        self.PrintLog("start")

        semaphore.wait(timeout:DispatchTime.distantFuture)
        queue.async {
            semaphore.signal()
            self.PrintLog("first")
        }
        self.PrintLog(semaphore)
        self.PrintLog("second \n ");

    }

    func singleFunc(){
        Person.shared.name = "Mutong"
    }
    func lockFunc(){
        objc_sync_enter(self)
        //需要执行的任务
        objc_sync_exit(self)
    }

    func queueSyncFunc(){
        let queue = DispatchQueue(label: "myqueue")
        self.PrintLog("start")
        queue.sync {
            self.PrintLog("sync 之前")
            queue.sync {
                self.PrintLog("sync中")
            }
            self.PrintLog("sync后")
        }
        self.PrintLog("end")
    }

    func applyFunc(){
//        let queue:DispatchQueue = DispatchQueue.global(qos: .default)
        let queue:DispatchQueue = DispatchQueue(label: "123")
        self.PrintLog(NSDate())
        DispatchQueue.concurrentPerform(iterations: 10) { (index) in
//            self.PrintLog("1")
//            self.PrintLog(index)
            print("1"+String(index))
            DispatchQueue.concurrentPerform(iterations: 5, execute: { (inde) in
                print("s"+String(inde))


            })
        }
        self.PrintLog(NSDate())


//        self.PrintLog(NSDate())
//        for var i in 0...1000000 {
////            self.PrintLog(i)
//        }
//        self.PrintLog(NSDate())

    }

    func barrierFunc(){
//        let queue = DispatchQueue(label: "queue", attributes:.concurrent)
        let queue = DispatchQueue.global(qos: .default)

        queue.async {
            
            print("sleep1")
        }
        queue.async {
            print("sleep2")
        }
        let write = DispatchWorkItem(flags: .barrier) {
            print("barrier")
        }
        queue.async(execute: write)

        queue.async {
            print("sleep3")
        }
        queue.async {
            print("sleep4")
        }
    }

    func groupFunc(){
        let group = DispatchGroup()
        let queueBook = DispatchQueue(label: "book")
        group.enter()
        queueBook.async(group: group) {
            // 下载图书
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
                    sleep(2)
                    print("sleep2")
                    group.leave()
                })
            }
        }
        group.enter()
        let queueVideo = DispatchQueue(label: "video")
        queueVideo.async(group: group) {
            // 下载视频
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
                    sleep(2)
                    print("sleep3")
                    group.leave()
                })
            }
        }
        group.notify(queue: DispatchQueue.main) {
            // 下载完成
            print("完成");
        }


    }

    func afterFunc(){
        self.PrintLog("开始")
        DispatchQueue.main.async {
            self.PrintLog("sleep start")
            sleep(5)
            self.PrintLog("sleep end")
        }
        self.PrintLog("start")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.PrintLog("两秒后")
        }


    }

    @IBAction func GCDPush(_ sender: Any) {
        let firstVC:FirstViewController = FirstViewController()
        self.navigationController?.pushViewController(firstVC, animated: true)

    }

    func mainAsyncTest(){
        self.PrintLog(NSDate())
        DispatchQueue.main.async {
            sleep(5)
            self.PrintLog("sleep end")
            self.PrintLog(NSDate())
        }

        self.PrintLog(NSDate())

//        DispatchQueue.main.async {
//            sleep(1)
//            print("1")
//        }
//        DispatchQueue.main.async {
//            sleep(2)
//
//            print("2")
//        }
//        DispatchQueue.main.async {
//            sleep(3)
//
//            print("3")
//        }
//        DispatchQueue.main.async {
//            sleep(4)
//
//            print("4")
//        }

//        let glQueue = DispatchQueue.global(qos: .default)
//        glQueue.async {
//            self.PrintLog("start sleep")
//            sleep(2)
//            DispatchQueue.main.async {
//                self.PrintLog("UI 刷新")
//            }
//        }
    }

    func GCDTest(){
        DispatchQueue.main.async {

        }


        let concurrentQueue = DispatchQueue(label: "queuename", attributes:.concurrent)
        let serialQueue = DispatchQueue(label: "queuenam")
        let glQueue = DispatchQueue.global(qos: .default)

        glQueue.async {
            sleep(10)
            print("sleep2")
        }
        DispatchQueue.main.async {
            sleep(10)
            print("sleep2")
        }




    }
    func PrintLog<T>(_ message: T, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line){
        //文件名、方法、行号、打印信息
        //print("\(fileName as NSString)\n方法:\(methodName)\n行号:\(lineNumber)\n打印信息\(message)");

        print("时间:\(NSDate()) 方法:\(methodName)  行号:\(lineNumber)  打印信息:\(message)");
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


