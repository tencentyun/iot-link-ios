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
-    5.6 设备OTA   


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

  1、属性(property)数据包中表示属性ID(property id)。      
  
   2、事件(event)数据包中表示事件的参数ID(params id)。      
   
  3、行为(action)数据包中表示行为的 input id 或 output id。

<font color = red> 说明及限值：</font>
   
   1、**ID 值为控制台创建产品模板的属性序号。**   
   
   2、数据 ID 占据 5Bits，最大值为31。   
   
   3、只有**字符串和结构体类型**拥有**Length字段**。其他类型长度固定， TLV中省略Length字段。     示例如下：            
      · 00 01表示id = 0， value = 1的布尔数据。此处省略了Length字段。   
      · 41 00 05 68 65 6C 6C 6F表示 id = 1，length = 5，value = hello的字符串数据。此处Length字段为00 05。   
      · C2 00 0A 00 01 41 00 05 68 65 6C 6C 6F 表示 id = 2，length = 10的结构体数据。其成员1是 id = 0，value = 1的布尔数据，成员2是id = 1，length = 5，value = hello的字符串数据。此处结构体Length字段为00 0A，字符串Length字段为00 05。    
   
   4、结构体不支持嵌套，结构体成员只能是其他数据类型。     

​

#  3、LLSync Profile 说明

##        Profile总架构如图：

<table>
  <tr>
    <th colspan="8" class="align-center">LLSync Profile</th>
  </tr>
  <tr>
    <td colspan="8">LLSync Profile</td>
  </tr>
  <tr>
    <td colspan="4">UUID</td>
    <td colspan="4">0xFFE0</td>
  </tr>
  <tr>
    <td colspan="4">Primary</td>
    <td colspan="4">Service</td>
  </tr>
  <tr>
    <td colspan="2">LLDeviceInfo</td>
    <td colspan="2">LLEvent</td>
    <td colspan="2">LLData</td>
    <td colspan="2">LLOTA</td>
  </tr>
  <tr>
    <td>UUID</td>
    <td>0xFFE1</td>
    <td>UUID</td>
    <td>0xFFE2</td>
    <td>UUID</td>
    <td>0xFFE3</td>
    <td>UUID</td>
    <td>0xFFE3</td>
  </tr>
  <tr>
    <td>Properties</td>
    <td>Write</td>
    <td>Properties</td>
    <td>Notify</td>
    <td>Properties</td>
    <td>Write</td>
    <td>Properties</td>
    <td>WriteWtihNoRsp</td>
  </tr>
</table>   


<font color = red> LLSync Profile包含4个 characteristics：</font>

**LLDeviceInfo**：设备信息写入特征值，用于设备连接、绑定和身份确认。

**LLData**：数据模版操作特征值，用于通知设备端执行数据模版操作。

**LLEvent**：事件上报特征值，用于设备端向小程序上报数据。

**LLOTA**：升级数据特征值，用于控制设备进行版本更新。

<font color = red> 注意： **对应操作需要写入对应的 characteristics 。**</font>

LLSync数据包最大长度为 **2048** 字节，包括数据包头和用户数据。同时支持数据分片，当数据包长度大于ATT MTU时，LLSync 协议会将数据分片发送，接收方收到分片数据后需要将数据组包后处理。

## 3.1 LLDeviceInfo   

LLDeviceInfo有两种格式的数据包:    

LLSync协议版本等于0:

| 字段 | 类型 | 数据 |
|:---:|:---:|:---:|
| 长度 | 1 Byte | N Bytes |
| 说明 | 类型定义 | 数据格式定义 |


LLSync协议版本大于 0:

| 字段 | 类型 | 长度 | 数据 |
|:---:|:---:|:---:|:---:|
| 长度 | 1 Byte | 2 Bytes | N Bytes |
| 说明 | 类型定义 | 长度格式定义 | 数据格式定义 |


**类型定义**：

| 数据类型 | 值 |
|:---:|:---:|
| 时间同步 | 0 |
| 连接鉴权 | 1 |
| 绑定成功 | 2 |
| 绑定失败 | 3 |
| 解绑请求 | 4 |
| 连接成功 | 5 |
| 连接失败 | 6 |
| 解绑成功 | 7 |
| 解绑失败 | 8 |
| MTU设置结果 | 9 |
| 绑定确认超时 | 0x0A |


**数据格式定义:**   数据格式字段由具体的数据类型定义。

| 数据类型 | 数据格式 | 说明 |
|:---:|:---:|:---:|
| 0 | 4 Bytes Nonce + <br>4 Bytes Unix TS | 向设备端发送计算签名所需信息 |
| 1 | 4 Bytes Unix Ts + <br>20 Bytes Hmac-sha1 | Local Psk对Ts签名得到Hmac-sha1 |
| 2 | 1 Byte bind result + <br>4 Bytes local psk + <br>8 Bytes bind string | App 生成Local Psk和Bind String。<br>App 记录Local psk和Bind string与设备的对应关系 |
| 3 | N/A | 绑定失败 |
| 4 | 20 Bytes Hmac-sha1 | 使用Local Psk对“UnbindRequest”签名得到Hmac-sha1 |
| 5 | N/A | 连接成功 |
| 6 | N/A | 连接失败 |
| 7 | N/A | 解绑成功 |
| 8 | N/A | 解绑失败 |
| 9 | 2 Bytes Result | 小程序设置MTU的结果 |
| 0x0A | N/A | 等待绑定确认超时 |


**长度格式定义：**   

由于ATT MTU限制，当数据包长度大于 ATT MTU 时，LLSync 会对数据报文进行分片。

长度字段的15～14 Bits用来表示分片标记，13 Bit用来表示确认绑定，11～0 Bits表示数据长度，数据长度最大值为2^11 – 1字节[,]()已经可满足绝大多数使用场景。**长度格式定义适用于本文档中所有涉及到数据分片的length字段。**

<table>
  <tr>
    <th class="align-center">Bit</th>
    <th class="align-center">15</th>
    <th class="align-center">14</th>
    <th class="align-center">13</th>
    <th class="align-center">12</th>
    <th class="align-center">11</th>
    <th class="align-center">10</th>
    <th class="align-center">···</th>
    <th class="align-center">1</th>
    <th class="align-center">0</th>
  </tr>
  <tr>
    <td>说明</td>
    <td colspan="2">分片记录标记</td>
    <td>绑定标记</td>
    <td>​</td>
    <td colspan="5">数据长度</td>
  </tr>
</table>


**分片标记定义:**

| 分片值 | 00 | 01 | 10 | 11 |
|:---:|:---:|:---:|:---:|:---:|
| 说明 | 不分片 | 分片，首包 | 分片，中间包 | 分片，尾包 |


**长度计算方式：分片标记 << 14 ｜ 绑定标记 << 13 | 数据长度。**   

**绑定标记：**   

| Bind Flag | 说明 |
|:---:|:---:|
| 0 | 同意绑定 |
| 1 | 拒绝绑定 |


​

<font color = red>_说明：_</font>

_1._ _数据分为 2 包时，只有分片首包和尾包。_   

_2._ _数据长度指的是本包内有效载荷的长度，不包含长度字段本身占用的长度。_   

_3._ _连接鉴权期间LLSync认为设备使用的ATT\_MTU固定是23。_   

_4._ _绑定标记只有启用安全绑定功能时才有效，其他场景默认为0。_   

5. _数据分片是将较长的用户数据分割为多个短数据包后进行传输，每个短数据包的传输格式都需要符合本文档中相应的报文格式。_   

_示例：完整的连接鉴权信息共 24 字节，如下：_   

_0xA1,0xA2,0xA3,0xA4,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0xB7,0xB8,0xB9,0xBA,0xBB,0xBC,0xBD,0xBE,0xBF,0xC0,0xC1,0xC2,0xC3。_   

_当ATT MTU为23字节时，单包用户数据长度最大为20字节。因此需要将连接鉴权信息分为2包发送，第一包数据如下：_   

_0x01,0x40,0x11,0xA1,0xA2,0xA3,0xA4,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5, 0xB6,0xB7,0xB8,0xB9,0xBA,0xBB,0xBC_

_其中，0x01表示连接鉴权信息，0x40，0x11表示分片数据的第一包，数据长度17字节。_   

_第二包数据如下：_   

_0x01,0xC0,0x07,0xBD,0xBE,0xBF,0xC0,0xC1,0xC2,0xC3_   

_其中，0x01表示连接鉴权信息，0xC0，0x07表示分片数据最后一包，数据长度7字节。_   

​

## 3.2  LLData   

LLData用于操作数据模版，不同的业务数据包中字段含义略有不同。   

**LLData 格式定义：**   

| 字段 | Fixed header | Payload |
|:---:|:---:|:---:|
| 长度 | 1 Byte | N Bytes |
| 说明 | Fixed header定义 | Payload定义 |


**Fixed header定义:**

<table>
  <tr>
    <th class="align-center">Bit</th>
    <th class="align-center">7</th>
    <th class="align-center">6</th>
    <th class="align-center">5</th>
    <th class="align-center">4</th>
    <th class="align-center">3</th>
    <th class="align-center">2</th>
    <th class="align-center">1</th>
    <th class="align-center">0</th>
  </tr>
  <tr>
    <td>说明</td>
    <td colspan="2">数据模版类型定义</td>
    <td>数据作用定义</td>
    <td colspan="5">ID 定义</td>
  </tr>
</table>


数据模版操作包括属性、事件、行为三类，通过7 ～ 6 Bits标记。Bit 5用来标记是物联网平台下发的请求报文还是物联网平台对设备的应答报文。Bits 4 ～ 0 表示数据模版的ID。

**数据模板类型定义：**   

| 字段 | 数值 |
|:---:|:---:|
| property | 0 |
| event | 1 |
| action | 2 |


**数据作用定义：**   

| 字段 | 数值 | 说明 |
|:---:|:---:|:---:|
| Request | 0 | 向设备下发请求 |
| Reply | 1 | 应答设备请求 |


**ID定义：**

<table>
  <tr>
    <th class="align-center">数据模版类型</th>
    <th class="align-center">数据作用</th>
    <th class="align-center">ID</th>
    <th class="align-center">说明</th>
  </tr>
  <tr>
    <td rowspan="3">0</td>
    <td>0</td>
    <td>0</td>
    <td>N/A</td>
  </tr>
  <tr>
    <td rowspan="2">1</td>
    <td>0</td>
    <td>表示report\_reply方法</td>
  </tr>
  <tr>
    <td>2</td>
    <td>表示get\_status\_reply方法</td>
  </tr>
  <tr>
    <td>1</td>
    <td>1</td>
    <td>event id</td>
    <td>表示事件id</td>
  </tr>
  <tr>
    <td>2</td>
    <td>0</td>
    <td>action id</td>
    <td>表示行为 id</td>
  </tr>
</table>


<font color = red>_说明：event id/action id在不得超过31_ </font>   

**Payload定义：**

不同的Fixed header对应的Payload格式不同。   

**Payload格式定义：**   

<table>
  <tr>
    <th class="align-center">数据模版类型</th>
    <th class="align-center">数据模版类型</th>
    <th class="align-center">ID</th>
    <th class="align-center">Payload</th>
  </tr>
  <tr>
    <td rowspan="3">0</td>
    <td>0</td>
    <td>0</td>
    <td>TLV格式</td>
  </tr>
  <tr>
    <td rowspan="2">1</td>
    <td>0</td>
    <td>Reply\_Result定义</td>
  </tr>
  <tr>
    <td>2</td>
    <td>TLV格式</td>
  </tr>
  <tr>
    <td>1</td>
    <td>1</td>
    <td>event id</td>
    <td>Reply\_Result定义</td>
  </tr>
  <tr>
    <td>2</td>
    <td>0</td>
    <td>action id</td>
    <td>TLV格式</td>
  </tr>
</table>


**Reply\_Result定义:**    

| 数值 | 说明 |
|:---:|:---:|
| 0 | 成功 |
| 1 | 失败 |
| 2 | 数据解析错误 |


## 3.3 LLEvent   

LLEvent用于设备主动上报报文，主要用于对LLDeviceInfo、LLData和LLOTA的回复。   

**LLEvent格式定义：**   

| 字段 | type | length | value |
|:---:|:---:|:---:|:---:|
| 长度 | 1 byte | 2 bytes | N bytes |
| 说明 | 类型定义 | 长度定义 | 无 |


**Event类型定义：**   

| 字段 | 类型值 | 说明 |
|:---:|:---:|:---:|
| 属性上报 | 0 | 数据模版中的report |
| 控制回复 | 1 | 数据模版中的control\_reply |
| 获取最新信息 | 2 | 数据模版中的get\_status |
| 事件上报 | 3 | 数据模版中的event\_post |
| 行为响应 | 4 | 数据模版中的action\_reply |
| 绑定鉴权信息 | 5 | 绑定后设备返回的信息 |
| 连接鉴权信息 | 6 | 连接后设备返回的信息 |
| 解绑鉴权信息 | 7 | 解绑后设备返回的信息 |
| 设备信息 | 8 | 上报MTU长度和协议版本 |
| 升级请求回复 | 9 | 回复设备升级请求 |
| 升级数据包回复 | 10 | 回复升级数据包 |
| 升级校验结果回复 | 11 | 回复升级文件的校验结果 |
| MTU协商结果上报 | 12 | 上报最终协商确定的MTU |
| 等待绑定时间上报 | 13 | 等待绑定确认的最大时间 |


## 3.4 LLOTA   

LLOTA用于对设备进行版本更新。   

**LLOTA格式定义：**      

| 字段 | type | length | value |
|:---:|:---:|:---:|:---:|
| 长度 | 1 byte | 1 byte | N byte |
| 说明 | 类型定义 | 无 | ​ |


**OTA类型定义：**   

| 类型定义 | 值值 |
|:---:|:---:|
| 升级请求 | 0 |
| 升级数据包 | 1 |
| 升级结束通知 | 2 |


## 3.5 UUID说明：   

   LLSync Bluetooth Base UUID为 00000000-65d0-4e20-b56a-e493541ba4e2。按照BLE协议，16 Bits UUID和128 Bits UUID转换关系为：

   128 Bits value = 16 Bits value \* 2^96 + BluetoothBaseUUID   

   即 0000xxxx-65d0-4e20-b56a-e493541ba4e2 中的xxxx替换为16 Bits UUID，例如 Service 16 BitsUUID FFE0 转换为128 Bits 的UUID 为 0000ffe0-65d0-4e20-b56a-e493541ba4e2，Characteristic的UUID的转换类似。    

​

## 4. LLSync Advertisement定义    

   自定义广播数据按照BlueTooth协议要求，添加到0xFF Manufacturer Specific Data的字段当中，company ID使用0xFEE7（Tencent Holdings Limited），0xFEE7和0xFEBA均为腾讯申请的Company ID。   

**广播包格式：**

<table>
  <tr>
    <th class="align-center">说明</th>
    <th colspan="2" class="align-center">设备状态</th>
    <th colspan="2" class="align-center">设备标识</th>
    <th colspan="2" class="align-center">附加标识</th>
  </tr>
  <tr>
    <td>状态</td>
    <td>长度</td>
    <td>取值</td>
    <td>长度</td>
    <td>取值</td>
    <td>长度</td>
    <td>取值</td>
  </tr>
  <tr>
    <td>未绑定</td>
    <td>1</td>
    <td rowspan="3">设备状态定义</td>
    <td>6</td>
    <td>MAC地址</td>
    <td>10</td>
    <td>Product ID</td>
  </tr>
  <tr>
    <td>绑定中</td>
    <td>1</td>
    <td>6</td>
    <td>MAC地址</td>
    <td>10</td>
    <td>Product ID</td>
  </tr>
  <tr>
    <td>已绑定</td>
    <td>1</td>
    <td>6</td>
    <td>设备标识计算</td>
    <td>8</td>
    <td>绑定标识计算</td>
  </tr>
</table>


_**说明：未绑定和绑定中广播内容相同。当启用 BLE\_QIOT\_BUTTON\_BROADCAST 功能后，可以控制在未绑定状态下不广播，当通过按键或其他操作进入绑定中状态后才开启广播。**_

**设备状态定义：**   

<table>
  <tr>
    <th class="align-left">Bit</th>
    <th class="align-center">7</th>
    <th class="align-center">6</th>
    <th class="align-center">5</th>
    <th class="align-center">4</th>
    <th class="align-center">3</th>
    <th class="align-center">2</th>
    <th class="align-center">1</th>
    <th class="align-center">0</th>
  </tr>
  <tr>
    <td>说明</td>
    <td colspan="4">协议版本</td>
    <td colspan="2">Reserved</td>
    <td colspan="2">绑定状态</td>
  </tr>
</table>


_**说明： LLSync SDK版本号见 BLE\_QIOT\_LLSYNC\_PROTOCOL\_VERSION 定义。**_   

**绑定状态说明：**   

| 状态 | 值值 | 说明 |
|:----|:----|:----|
| 未绑定 | 0 | 初始状态，可以选择不发送BLE Advertisement以省电 |
| 绑定中 | 1 | 按下绑定触发按键，在超时之前处于绑定中，超时前按照要求发送广播包 |
| 已绑定 | 2 | 正确完成绑定状态，需要持续发送广播包 |


**设备标识计算：**   

Temp = md5sum(蓝牙设备的product\_id | 蓝牙设备的device\_name)   

设备标识 Result = Temp 前8位 ^ Temp 后8位   

比如：蓝衣设备的ProductID 为 ABCDEFGHIJ, DeviceName 为 Dev01   

那么 Temp = md5sun(\*ABCDEFGHIJ\*) = {0x61,0x2a,0xf7,0x9d,0x50,0x17,0x93,0x87,0x2a,0x4a,0x97,0xe8,0xcb,0xe4,0x5a,0x10}   

Result 为 {0x4b,0x60,0x60,0x75,0x9b,0xf3,0xc9,0x97}   

**绑定标识计算：**    

<font color = red>网关或小程序在绑定成功时提供，计算方式和设备标识符一致。</font>

**广播包示例如下：**   

**<0xFEE7> 0x00 CBD52F25B5E1 51444131505A4C424E42**

<0xFEE7> : 公司ID，腾讯为0xFEE7或0xFEBA   

0x00: 状态   

CBD52F25B5E1：蓝牙MAC地址   

51444131505A4C424E42：ProductID或标识符     

61-bit service UUIDs: 0xFFE0 开头 

