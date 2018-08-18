////  MMUIKit.h
//  MMUIKit
//
//  Created by Dwang on 2018/8/18.
//	QQ群:	577506623
//	GitHub:	https://github.com/CoderDwang
//  Copyright © 2018年 CoderDwang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 
 使用说明:
 
 /==================================== Cocoapods方式 ====================================/
 
 target 'project_name' do
 
 pod 'MMUIKit', :path => 'MMUIKit'
 
 end
 
 /==================================== end ====================================/
 
 
 
 /==================================== 手动方式 ====================================/
 
 需手动添加以下系统依赖
 
 CoreLocation.framework
 MobileCoreServices.framework
 UserNotifications.framework
 Security.framework
 CoreGraphics.framework
 SystemConfiguration.framework
 CoreTelephony.framework
 CoreFoundation.framework
 CFNetwork.framework
 JavaScriptCore.framework
 UIKit.framework
 Foundation.framework
 
 libsqlite3.tbd
 libicucore.tbd
 libc++.tbd
 libresolv.tbd
 libz.tbd
 
 tagrget--->Build Settings--->Other Linker Flags下增加 -ObjC 、 -all_load
 
 关闭bitcode
 
 /==================================== end ====================================/
 
 info.plist中需添加一个类型为Dictionary的主key，key值为MMKit，MMKit下需要下列参数
 
 //LeanCloud所需参数，本地属性，直接填写对应的值即可
 AVCloudAppKey      //LeanCloud服务key
 AVCloudAppid       //LeanCloud服务id
 AVCloudClassName   //LeanCloud查询的对象名称
 AVCloudObjectID    //LeanCloud查询的对象id
 
 //本地属性，直接填写时间即可，yyyy-MM-dd，yyyyMMdd
 beforeDate         //初始化LeanCloud时间，可不添加
 
 //后台属性，MMKit将会以下列key值查找其value值，value值因对应后台设置的返回字段，后台设置的属性类型需与要求类型相同
 bundle_identifier  //应用标示 @String
 hasExit            //是否使用退出按钮 @BOOL
 autoHiddenToolBar  //横屏时是否自动隐藏底部导航栏 @BOOL
 isOpen             //是否切换为Web控制器 @BOOL
 jpushKey           //极光推送key @String
 url                //Web控制器显示的网址 @String
 hasSaveImage       //是否开启长按保存图片功能 @BOOL
 
 
 启动MMKit
 
 @param selfClass 启动对象,传self即可
 @param launchOptions 启动参数，极光推送需要
 @param waitMsg 网络请求时的展示内容，可为image对象或string对象。推荐使用image对象，将启动页图片设为waitMsg
 @param templateController 模版主控制器/不使用时传nil
 @param templateBlock 某些只在模版中启动的内容
 
 void mmkit_setup(UIResponder *selfClass, NSDictionary *launchOptions, id waitMsg, UIViewController *templateController, void (^templateBlock)(void));
 
 */

//! Project version number for MMUIKit.
FOUNDATION_EXPORT double MMUIKitVersionNumber;

//! Project version string for MMUIKit.
FOUNDATION_EXPORT const unsigned char MMUIKitVersionString[];

#import "UIResponder+MMKit.h"

#import "Reachability.h"

#import "MBProgressHUD.h"

#import "NSDate+MMKit.h"

// In this header, you should import all the public headers of your framework using statements like #import <MMUIKit/PublicHeader.h>


