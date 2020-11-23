## TTFlutterBridge

#### 简介

TTFlutterBridge 方便OC更好的与flutter进行通信。基于现有的flutter 插件开发方法，每个插件需要在OC层进行 method 分发，注册。做了一些不必要的操作，可读性也会变低。TTFlutterBridge通过OC反射的方式将dart方法与OC方法一一映射。以 dart开头支持数组参数的一一解析对应，也支持将字典参数的解析对应，如果不需要解析可以 以 _dart 作为方法的开头。 _dart 方法的优先级高于 dart。


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
* 工程中需要有 FlutterPluginRegistrant 的组件（在有plugin的工程中 执行build命令会自动生成），如果没有可以创建一个空白就行。TTFlutterBridge 会 hook 对应的方法实现自动注册
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
* 实现dart接口 -  自动解析 
    ```
        以dartAsync开头的方法默认为异步接口，result回调由自己控制。 接受参数可以为 ["a"] 或者 {"string":"a"} 或者 "a"
        - (void)dartAsyncCapitalizedString:(FlutterResult)result string:(NSString *)str {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              result([str capitalizedString]);
          });
        }
        
        //以dart开头的方法 如dartXXX 将默认为同步接口。接受参数为 ["a"] 或者 {"lowercaseString":"a"} 或者 "a"
        - (NSString *)dartLowercaseString:(NSString *)str {
            return [str lowercaseString];
        }
        
        //可以 使用with 分隔符，方法名为 Lowercase。接受参数为 ["a"] 或者 {"string":"a"} 或者 "a"
        - (NSString *)dartLowercaseWithString:(NSString *)str {
            return [str lowercaseString];
        }
        
        //不需要解析的时候会将 param 直接传到第一个值
        - (void)_dartAsyncCapitalizedString:(FlutterResult)result string:(NSString *)str {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              result([str capitalizedString]);
          });
        }
        
        // 
        - (NSString *)_dartLowercaseString:(NSString *)str {
            return [str lowercaseString];
        }
        
    ```
    
