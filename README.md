# Alipan SDK for Ruby

[![Gem Version](https://badge.fury.io/rb/alipan-sdk.svg)](https://badge.fury.io/rb/alipan-sdk)

## 关于

阿里云盘SDK  方便Ruby客户端程序调用

## 快速开始

### 鉴权配置

登录官网[阿里云盘开发者门户](https://www.alipan.com/developer/f)  按照开发文档获取access_token

### 安装Alipan SDK for Ruby

```bash
gem install alipan-sdk
```

并在你的程序中或者`irb`命令下包含:

```bash
require 'alipan'
```

### 创建Client
client = Alipan::Client.new({:access_token=>"xxx"})

`access_token`是您的鉴权信息


**请妥善保管您的access_token  泄露之后可能影响您的数据安全**

### 获取drive
drive = client.get_drive

### 获取object
objects = drive.list_objects

## 更多

更多文档请查看:

[阿里云盘开发者门户](https://www.alipan.com/developer/f)
