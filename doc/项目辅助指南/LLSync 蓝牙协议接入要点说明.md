> 本文档作为腾讯连连 App 接入纯蓝牙 LLSync 协议设备的开发要点说明。

# 名词解释：

| 缩略词 | 解释 |
|:----|:----|
| LLSync | 腾讯连连 Sync协议 |
| BLE | 低功耗蓝牙 |
| LLDevice | 蓝牙 Sync 设备管理属性 |
| LLData | 蓝牙 Sync 数据属性 |
| LLEvent | 蓝牙 Sync 事件属性 |
| LLOTA | 蓝牙 Sync OTA属性 |


# 目录

1. 设备参数
2. LLSync TLV 格式
3. LLSync Profile 说明    
- 3.1 LLDeviceInfo 
- 3.2 LLData
- 3.3 LLEvent
- 3.4 LLOTA
- 3.5 UUID 说明    

4.  LLSync Advertisement

5.  BLE 通信数据流 

-     5.1 子设备绑定 
-     5.2 子设备连接 
-     5.3 子设备解绑  
-     5.4 数据模板协议交互 
-     5.5 设备信息上报    
-     5.6 设备OTA       


6. 蓝牙辅助配网

-     6.1  概述
-     6.2  蓝牙辅助配网流程
-     6.3  传输格式

# 1、设备参数

| 参数 | 要求 |
|:----|:----|
| BLE ATT MTU | = 23 |
| BLE协议 | = BLE 4.2 |


# 2、LLSync TLV格式

   腾讯云物联网为接入平台定义一套[数据模板协议](https://cloud.tencent.com/document/product/1081/34916)，将设备的接入形式通过JSON模板标准化。多数BLE设备受资源限制，较难承载JSON格式的数据交互，针对此定义了TLV格式的二进制数据包来表示数据模板，最大程度的减少资源占用。如无特殊说明，本文所有数据均使用网络序传输。

   LLSync TLV二进制数据包中有用户数据、数据长度和数据类型，TLV格式被广泛应用在LLData数据包和LLEvent数据包中。

   **LLSync TVL格式:**

| 字段 | Type | Length | Value |
|:----|:----|:----|:----|
| 长度 | 1 Byte | N Bytes | N Bytes |
| 说明 | Type字段定义 | 可选 | 无 |


<font color = red>说明：Type 字段决定 Length 字段是否存在。</font>

 **Type字段说明:**

<table>
  <tr>
    <th class="align-left">Bit</th>
    <th class="align-left">7</th>
    <th class="align-left">6</th>
    <th class="align-left">5</th>
    <th class="align-left">4</th>
    <th class="align-left">3</th>
    <th class="align-left">2</th>
    <th class="align-left">1</th>
    <th class="align-left">0</th>
  </tr>
  <tr>
    <td>字段</td>
    <td colspan="3">数据类型定义</td>
    <td colspan="5">ID定义</td>
  </tr>
</table>


<font color = red>说明：Type 字段高 3 Bits表示数据类型，低 5 Bits表示 ID。</font>

 **数据类型定义：**

| 数据类型 | 值值 | 数据长度 | 数据范围 |
|:----|:----|:----|:----|
| 布尔 | 0 | 1 Byte | 0/1 |
| 整数 | 1 | 4 Bytes | -2^31 ~ 2^31 - 1 |
| 字符串 | 2 | N(<= 2048)Bytes | 用户自定义数据 |
| 浮点数 | 3 | 4 Bytes | 1.2E-38 ~ 3.4E+38 |
| 枚举 | 4 | 2 Bytes | 0 ~ 2^16 - 1 |
| 时间 | 5 | 4 Bytes | 0 ~ 2^64 - 1 |
| 结构体 | 6 | N(<= 2048)Bytes | TLV格式数据 |


**ID 含义说明：**

   在不同的数据包中 ID 含义不同：

    1、 属性(property)数据包中表示属性ID(property id)。      

    2、事件(event)数据包中表示事件的参数ID(params id)。

    3、行为(action)数据包中表示行为的 input id 或 output id。

<font color = red> 说明及限值：</font>

     _1、__**ID 值为控制台创建产品模板的属性序号。**_ 

     _2、数据 ID 占据 5Bits，最大值为31__**。**_

     _3、_只有**字符串和结构体类型**拥有**Length字段**。其他类型长度固定， TLV中省略Length字段。

           示例如下：

           · 00 01表示id = 0， value = 1的布尔数据。此处省略了Length字段。

           · 41 00 05 68 65 6C 6C 6F表示 id = 1，length = 5，value = hello的字符串数据。此处Length字段为00 05。

           · C2 00 0A 00 01 41 00 05 68 65 6C 6C 6F 表示 id = 2，length = 10的结构体数据。其成员1是 id = 0，value = 1的布尔数据，成员2是id = 1，length = 5，value = hello的字符串数据。此处结构体Length字段为00 0A，字符串Length字段为00 05。 

      _4、结构体不支持嵌套，结构体成员只能是其他数据类型。_  

​

#  3、LLSync Profile 说明

##        Profile总架构如图：

![image-1](https://ask.qcloudimg.com/developer-images/article/7364147/i8t23gnk8e.png)

<font color = red> LLSync Profile包含4个 characteristics：</font>

**LLDeviceInfo**：设备信息写入特征值，用于设备连接、绑定和身份确认。

**LLData**：数据模版操作特征值，用于通知设备端执行数据模版操作。

**LLEvent**：事件上报特征值，用于设备端向小程序上报数据。

**LLOTA**：升级数据特征值，用于控制设备进行版本更新。

<font color = red> 注意： **对应操作需要写入对应的 characteristics 。**</font>

LLSync数据包最大长度为 **2048** 字节，包括数据包头和用户数据。同时支持数据分片，当数据包长度大于ATT MTU时，LLSync 协议会将数据分片发送，接收方收到分片数据后需要将数据组包后处理。

## 3.1 LLDeviceInfo   

