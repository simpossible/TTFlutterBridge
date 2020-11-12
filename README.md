## TTFlutterBridge

#### 简介

TTFlutterBridge 方便OC更好的与flutter进行通信。基于现有的flutter 插件开发方法，每个插件需要在OC层进行 method 分发，注册。做了一些不必要的操作，可读性也会变低。TTFlutterBridge通过OC反射的方式将dart方法与OC方法一一映射

