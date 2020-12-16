## API 请求域名配置指引

以下配置需要在[environment setEnvironment]之后调用, 调用位置可参考[APP SDK 创建引导](https://github.com/tencentyun/iot-link-ios/blob/master/doc/SDK开发/APP%20SDK创建引导.md)

1、登录前`请求API的host`配置
```
environment.oemAppApi = @"host";
```

2、登录后`请求API的host`配置
```
environment.oemTokenApi = @"host";
```

3、`WebSocket长连接host`配置
```
environment.wsUrl = @"host";
```