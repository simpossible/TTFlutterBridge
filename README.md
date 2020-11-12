## TTFlutterBridge

#### 简介

TTFlutterBridge 方便OC更好的与flutter进行通信。基于现有的flutter 插件开发方法，每个插件需要在OC层进行 method 分发，注册。做了一些不必要的操作，可读性也会变低。TTFlutterBridge通过OC反射的方式将dart方法与OC方法一一映射。


#### 具体使用


##### dart 实现
* 创建Dart接口
    ```
        import 'dart:async';
        import 'package:flutter/services.dart';

        class TTTest {
          static const MethodChannel _channel =
          const MethodChannel('tttest');

         static Future<String> lowercaseString(String orgstring) async {
           String str = await _channel.invokeMethod('lowercaseString',[orgstring]);
           return str;
         }

         static Future<String> capitalizedString(String orgstring) async {
          String str = await _channel.invokeMethod('capitalizedString',[orgstring]);
           return str;
         }
        }
    ```
##### OC 实现
* 创建组件类继承自 TTFlutterPlugin
    ```
        #import <TTFlutterBridge/TTFlutterPlugin.h>
        @interface TestPlugin : TTFlutterPlugin
        @end
    ```
* 指定methodName
    ```
        @implementation TestPlugin

        + (NSString *)flutterMethodName {
            return @"tttest";
        }

        + (NSString *)pluginKey {
          return @"TestPlugin";
        }
        @end
    ```
* 实现dart接口 - 以dart开头的方法 如dartXXX 将默认为同步接口 以dartAsync开头的方法默认为异步接口，result回调由自己控制
    ```
        - (void)dartAsyncCapitalizedString:(FlutterResult)result string:(NSString *)str {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              result([str capitalizedString]);
          });
        }

        - (NSString *)dartLowercaseString:(NSString *)str {
            return [str lowercaseString];
        }
    ```
    
* 注册所有插件
    ```
        @implementation GeneratedPluginRegistrant

        + (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
            [TTFlutterPlugin registAllWithRegistry:registry];
        }

        @end
    ```