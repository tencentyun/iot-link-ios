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



### 5.1 子设备绑定

场景：BLE终端尚未绑定，需要先进行绑定才可以连接   

![image_binding](https://ask.qcloudimg.com/developer-images/article/7364147/2gymm8rqfh.png)

**1、往LLDeviceInfo上写入Unix TS**   

<table>
  <tr>
    <th class="align-left">Type</th>
    <th colspan="2" class="align-left">Value</th>
  </tr>
  <tr>
    <td>​</td>
    <td>Nonce</td>
    <td>Timestamp</td>
  </tr>
  <tr>
    <td>0x00</td>
    <td>4  Bytes nonce</td>
    <td>4 Bytes timestamp</td>
  </tr>
</table>


**2、出于设备安全考虑，LLSync SDK支持安全绑定功能，绑定前需要设备端确认。**   

 · 该功能是可选功能，通过配置SDK的BLE\_QIOT\_SECURE\_BIND可以启用安全绑定功能。若不启用该功能则设备进入绑定验证签名流程(见步骤3)；   

 · 若启用安全绑定功能，设备端需要等待用户确认后才可以继续绑定流程。   

启用安全绑定功能时，设备端需要先通过LLEvent告知App绑定过程的最大超时时间，用户超时未操作时结束绑定流程。   

| Type | Length | Value |
|:----|:----|:----|
| 0x0D | 2 Bytes length | 2 Bytes Wait Time |


_说明：绑定确认超时时间单位为秒，占用2字节。默认60秒。_   

    启用安全绑定功能后，用户选择确认绑定、拒绝绑定时，设备端会通过验证签名报文(见步骤3)上报App用户操作结果。   

如果用户不做操作导致绑定超时或者在App上取消绑定，App 会通过LLDeviceInfo报文通知设备。   

| Type | Result |
|:----|:----|
| 0x0A | 0/1 |


_说明：_   

   _1._ _Result 为 0 表示用户在App上点击取消，为 1 表示连接超时。_   

   _2._ App_通知设备超时，是考虑到节约设备资源。设备也可以依靠自身能力检测绑定超时。_   

**3、设备验证签名后返回的LLEvent数据包。**

<table>
  <tr>
    <th class="align-left">Type</th>
    <th class="align-left">Length </th>
    <th colspan="2" class="align-left">Value</th>
  </tr>
  <tr>
    <td>​</td>
    <td>​</td>
    <td>sign info</td>
    <td>device name</td>
  </tr>
  <tr>
    <td>0x05</td>
    <td>2 Bytes length</td>
    <td>20 Bytes sign info</td>
    <td>N Bytes device name</td>
  </tr>
</table>


_说明：_   

 _1._ _sign info是通过设备的psk对设备信息签名得到，签名算法使用hamc-sha1。_   

_2._ _deviceinfo = product id + devicename + ; + nonce + ; + expiration time_   

_3._ _expiration time = timestamp + 60_   

_4._ _计算签名时对于 nonce 和 timestamp，将其转换为字符串类型后再计算签名，避免大小端问题导致的签名错误。示例：timestamp = 0x5f3279fa，转换为对应数值的字符串为“1597143546”   。_

_5._ _启用安全绑定功能后，Length字段需要指定**绑定标记**。_   

**4. 往FFE1写入绑定成功结果格式见下表**      

<table>
  <tr>
    <th class="align-left">Type</th>
    <th colspan="3" class="align-left">Value</th>
  </tr>
  <tr>
    <td>​</td>
    <td>Result</td>
    <td>Local Psk</td>
    <td>绑定标识符</td>
  </tr>
  <tr>
    <td>0x02</td>
    <td>02</td>
    <td>4 Bytes Local Psk</td>
    <td>8 Bytes</td>
  </tr>
</table>


_说明:_    

_1._ _**Local Psk和绑定标识符由App生成。**_   

_2._ _Result表示绑定状态，绑定成功固定为0x02。_   

**5. 往FFE1写入绑定失败结果格式见下表**   

| type | value |
|:----|:----|
| 0x03 | 1 Byte Reply\_Result |


_说明：_

_1._ _BLE终端不会校验网关/小程序的身份，存在BLE终端被恶意绑定的可能，BLE终端可以配置通过按键进入待绑定状态，默认2分钟有效。_   

_2._ _设备连接成功之后，不会再广播beacon，小程序/网关无法再次扫描。_   

_如果绑定成功，需要在设备上存储 Local Psk 用于后续的网关 + 子设备连接鉴权。_   

​

### _5.2_ 子设备连接   

场景：设备广播Beacon标识设备已绑定，需要进行连接   

​

![llsync_linking](https://ask.qcloudimg.com/developer-images/article/7364147/lcqdop7co8.png)

_说明：如果是App，写入上线结果认为是写入App和设备的连接结果。_   

**1、往LLDeviceInfo写入签名信息数据格式见下表**   

<table>
  <tr>
    <th class="align-left">Type</th>
    <th colspan="2" class="align-left">Value</th>
  </tr>
  <tr>
    <td>​</td>
    <td>Timestamp</td>
    <td>Sign info</td>
  </tr>
  <tr>
    <td>0x01</td>
    <td>4 Bytes timestamp</td>
    <td>20 Bytes sign info</td>
  </tr>
</table>


**2、 设备验证签名后返回的LLEvent格式数据包**   

<table>
  <tr>
    <th class="align-left">Type</th>
    <th class="align-left">Length</th>
    <th colspan="2" class="align-left">Value</th>
  </tr>
  <tr>
    <td>​</td>
    <td>​</td>
    <td>Sign info</td>
    <td>Device name</td>
  </tr>
  <tr>
    <td>0x06</td>
    <td>2 Bytes length</td>
    <td>20 Bytes sign info</td>
    <td>N Bytes device name</td>
  </tr>
</table>


_说明：_   

_1._ _sign info是使用Local Psk对设备信息进行签名，算法选择hmac-sha1。设备信息包括 expiration time + product id + device name，其中expiration time = timestamp + 60。_   

_2.计算签名时对于timestamp，将其转换为字符串类型后再计算签名，避免大小端问题导致的签名错误。示例：timestamp = 0x5f3279fa，转换为对应数值的字符串为“1597143546” 。_   

​

_**5.3**_ **子设备解绑**   

场景：子设备已经绑定且完成连接，App 端请求解绑。   

![llsync_ unbind](https://ask.qcloudimg.com/developer-images/article/7364147/t2wzkys8ur.png)

**1、 往LLDeviceInfo写入解绑请求**   

| Type | Value |
|:----|:----|
| 0x04 | 20  Bytes sign info |


_说明：sign info是使用Local Psk对固定字符串“UnbindRequest”进行签名，算法选择hmac-sha1。_   

_**2、**_ **验签后返回的LLEvent信息数据格式如下表。**   

| Type | Length | Value |
|:----|:----|:----|
| 0x07 | 2 Bytes length | 20 Bytes sign info |


_说明：sign info是使用Local Psk对固定字符串“UnbindResponse”进行签名，算法选择hmac-sha1。_   

_**3、**_**往LLDeviceInfo写入解除绑定成功。**   

| Type |
|:----|
| 0x07 |


**4、往LLDeviceInfo写入解除绑定失败。**   

| Type |
|:----|
| 0x08 |


​

### 5.4 数据模板协议交互       

#### 5.4.1 设备属性上报      

​

![llsync_property_report](https://ask.qcloudimg.com/developer-images/article/7364147/gpa4rgstlx.png)

1、 设备属性上报LLEvent 数据格式，对应数据模版的Report操作。    

| Type | Length | Property Value |
|:----|:----|:----|
| 0x00 | 2 Bytes length | TLV数据 |


Property Value中可以包含多个Property的数据。示例：      

| 数值 | 描述 |
|:----|:----|
| 00 | Type |
| 00, 0F | Length |
| 00，01 | Propert Power Switch = 1 |
| 81，00，01 | Property Color = 1 |
| 22，00，00，00，23 | Property Brightness = 0x23 |
| 43，00，02，31，32 | Property Name = “12” |


2、属性上报结果通过LLData通知设备，对应数据模版的report\_reply操作      

| Header | Value |
|:----|:----|
| 0x20 | 1 Byte Reply\_Result |


​

#### 5.4.2 设备远程控制   

​

![llsync_device_report](https://ask.qcloudimg.com/developer-images/article/7364147/om9ekbfxst.png)

1、 通过LLData远程控制设备，对应数据模版的control操作。   

| Type | Length | Property Value |
|:----|:----|:----|
| 0x00 | 2 Bytes length | TLV数据 |


Property Value中可以包含多个Property的数据。示例：    

| 数值 | 描述 |
|:----|:----|
| 00 | Type |
| 00，0F | Length |
| 00，01 | Property Power Switch = 1 |
| 81，00，01 | Property Color = 1 |
| 22，00，00，00，23 | Property Brightness = 0x23 |
| 43，00，02，31，32 | Property Name = “12” |


2、 设备通过LLEvent上报操作结果，对应数据模版的control\_reply操作。   

| Type | Length | Value |
|:----|:----|:----|
| 0x01 | 2 Bytes length | 1 Byte Reply\_Result |


​

#### 5.4.3 获取设备最新信息      

​

![](https://ask.qcloudimg.com/developer-images/article/7364147/6yt423kfsq.png)

1、 设备通过LLEvent获取最新信息，对应数据模版的get\_status操作。   

| Type |
|:----|
| 0x02 |


2、 小程序通过LLData下发最新信息，对应数据模版的get\_status\_reply操作。   

| Type | Result | Length | Property Value |
|:----|:----|:----|:----|
| 0x22 | 1 Byte Reply\_Result | 2 Bytes value length | TLV数据 |


Property Value中可以包含多个property的数据。   

| 数值 | 描述 |
|:----|:----|
| 22 | Type |
| 00 | Reply\_Result = 成功 |
| 00，0F | Length |
| 00，01 | Property Power Switch = 1 |
| 81，00，01 | Property Color = 1 |
| 22，00，00，00，23 | Property Brightness = 0x23 |
| 43，00，02，31，32 | Property Name = “12” |


#### 5.4.4 设备事件上报   

​

![](https://ask.qcloudimg.com/developer-images/article/7364147/7f4krjc4s6.png)

1、设备通过LLEvent上报事件，对应数据模版中的event\_post操作。   

| Type | Length | Event id | Event value |
|:----|:----|:----|:----|
| 0x03 | 2 Bytes length | 1 Byte event id | TLV数据 |


Event value中可以包含多个event 参数。示例：   

| 数值 | 描述 |
|:----|:----|
| 03 | Type |
| 00，11 | Length |
| 02 | Event id |
| 40， 00，08， 31，32，33，34，35，36，37，38 | Event Param Name = “12345678” |
| 21，00，00，04，00 | Event Param Error Code = 0x400 |


2、通过LLData返回操作结果，对应数据模版中的event\_reply操作。    

| Type | Value |
|:----|:----|
| ​ | 1 Byte Reply\_Result |


_说明：假设event id = 0，那么Type字段应该是0x60。_   

#### 5.4.5 设备行为调用    

​

![](https://ask.qcloudimg.com/developer-images/article/7364147/y6ktj2iaod.png)

1、通过LLData向设备发起行为调用请求，对应数据模版中的action操作。   

| Type | Length | Action Value |
|:----|:----|:----|
| ​ | 2 Bytes length | TLV数据 |


_说明：假设action id = 0，那么Type字段应该是0x80。_   

Action value中可以包含多个 input 参数。示例。   

| 数值 | 描述 |
|:----|:----|
| 80 | Type |
| 00, 0B | Length |
| 20，00，00，00，04 | input id interval = 0x04 |
| 41，00，04，31，32，33，34 | input id message = “1234” |


2、设备通过LLEvent上报行为调用结果，对应数据模版中的action\_reply操作。   

<table>
  <tr>
    <th class="align-left">Type</th>
    <th class="align-left">Length</th>
    <th colspan="3" class="align-left">Value</th>
  </tr>
  <tr>
    <td>​</td>
    <td>​</td>
    <td>Response params</td>
    <td>Response params</td>
    <td>Response params</td>
  </tr>
  <tr>
    <td>0x04</td>
    <td>2 Bytes length</td>
    <td>1 Byte Reply\_Result</td>
    <td>1 Byte action id</td>
    <td>TLV数据</td>
  </tr>
</table>


Response param中可以包含多个 response 参数。示例。   

| 数值 | 描述 |
|:----|:----|
| 04 | Type |
| 00，0F | Length |
| 00 | Reply Result = 成功 |
| 00 | action id = 0 |
| 00，01 | Response Result = 1 |
| 41， 00，08， 31，32，33，34，35，36，37，38 | Response message = “12345678” |


### 5.5 设备信息上报   

1、连接成功后，设备通过LLEvent主动向小程序/网关上报设备信息，包括协议版本号，设备需要设置的MTU大小和设备固件版本号。   

<table>
  <tr>
    <th class="align-left">Type</th>
    <th class="align-left">Length</th>
    <th colspan="4" class="align-left">Value</th>
  </tr>
  <tr>
    <td>​</td>
    <td>​</td>
    <td rowspan="2">LLSync version</td>
    <td rowspan="2">MTU Filed</td>
    <td colspan="2">Firmware version</td>
  </tr>
  <tr>
    <td>​</td>
    <td>​</td>
    <td>Length</td>
    <td>Payload</td>
  </tr>
  <tr>
    <td>0x08</td>
    <td>2 Bytes</td>
    <td>1 Byte</td>
    <td>2 Bytes</td>
    <td>1 Byte</td>
    <td>N (<=32) Bytes</td>
  </tr>
</table>


_说明：_

_1._ _版本号与_**LLSync Advertisement**_中必须一致。_

_示例，08 00 09 02 00 14 05 30 2e 30 2e 31，LLSync版本号为2，mtu大小设置为0x14，固件版本号长度5字节，固件版本号为”0.0.1”  。_   

**MTU Filed**定义：   

<table>
  <tr>
    <th class="align-left">Bit</th>
    <th class="align-left">15</th>
    <th class="align-left">14</th>
    <th class="align-left">···</th>
    <th class="align-left">11</th>
    <th class="align-left">10</th>
    <th class="align-left">…</th>
    <th class="align-left">0</th>
  </tr>
  <tr>
    <td>说明</td>
    <td>mtu flag</td>
    <td colspan="3">Reserved</td>
    <td colspan="3">MTU大小</td>
  </tr>
</table>


_说明：_

_1._ _Bits 0 – Bits 10用来表示设备端通信使用的 MTU 大小mtu\_size；_   

_2._ _Bits 15 用来向小程序表示是否设置 MTU。当mtu flag为 1 时，小程序需要按照设备上传的mtu\_size 进行MTU设置；当mtu flag为0时，小程序不设置 MTU ，使用mtu\_size进行分片。_   

_需要App去设置 MTU 的原因是：在安卓手机上如果小程序不显式设置 MTU，双方会使用默认MTU为23进行通信；在IOS上不存在该问题。_   

_3._ _Bits 11 – Bits 14预留。_   

​

2.、App收到设备信息上报后，需要检查**mtu flag**。当mtu flag设置为1时：    

安卓系统上，App需要调用 MTU 设置接口修改 MTU，并通过LLDeviceInfo通知设备端设置结果。   

| Type | Value |
|:----|:----|
| 0x09 | 2 Byte Result |


_说明：_

_1._ _0表示设置成功，0xFFFF表示设置失败，其他表示设置成功的MTU值。_   

_2._ _当前App只能获取到设置成功失败，无法获取到设置成功的具体MTU值。_   

IOS系统上，App无法设置MTU，在蓝牙连接时IOS系统会设置MTU，LLSync SDK可以直接上报IOS系统设置的MTU给App用来通信。   

​

3、在手机上设置 MTU 后，由于App无法得知设置成功的MTU数值，因此还需要设备通过LLEvent将最终的MTU 数值上报给App，最终完成**MTU的协商**。   

| Type | Length | Value |
|:----|:----|:----|
| ​ | ​ | MTU size |
| MTU size | MTU size | 2 Bytes |


_说明：_

_1._ _在安卓上App设置 MTU 失败时，设备端上报MTU = 20，即默认ATT\_MTU – 3。_

_2._ _在安卓上App设置 MTU 成功，设备端会将蓝牙SDK获取到最新MTU值上报给App。_

_在IOS上，当IOS系统设置MTU后，设备端会将蓝牙SDK获取到最新MTU值上报给App。_    

​

### 5.6 设备OTA    

设备OTA流程图如下，设备端只关心和小程序的数据交互。包括：   

1、 设备端主动上报版本号   

2、 小程序下发升级请求   

3、 设备端应答升级请求   

4、小程序下发升级数据包   

5、设备端应答升级数据包   

6、小程序通知下发结束   

7、设备端上报文件校验结果   

​

![](https://ask.qcloudimg.com/developer-images/article/7364147/jbcec9m6at.png)

#### 5.6.1 固件版本上报      

设备通过 LLEvent 进行固件版本号上报，见 4.5 中一并上报。   

#### 5.6.2 升级请求包    

App通过 LLOTA 下发升级请求包到设备。   

<table>
  <tr>
    <th class="align-left">Type</th>
    <th class="align-left">Length</th>
    <th colspan="4" class="align-left">Value</th>
  </tr>
  <tr>
    <td>​</td>
    <td>​</td>
    <td>File size</td>
    <td>File crc</td>
    <td>File version len</td>
    <td>File version</td>
  </tr>
  <tr>
    <td>0x00</td>
    <td>File size</td>
    <td>4 Bytes</td>
    <td>4 Bytes</td>
    <td>1 Byte</td>
    <td>1 ~ 32 Bytes</td>
  </tr>
</table>


_说明：_

_1._ _约定使用CRC32 进行文件校验。_   

_2._ _升级请求包分片规则请参见_ **_LLEvent 分片规则_**_。_   

_示例：_   

 _00 00 0e 00 00 00 ff 18 70 16 3c 05 30 2e 30 2e 31，文件大小为0xFF，文件CRC为0x1870163C，文件版本为0.0.1_   

 _对上述数据应用分片规则，可以分为三包：_   

 _00 40 04 00 00 00 ff_   

 _00 80 04 18 70 16 3c_   

 _00 c0 06 05 30 2e 30 2e 31_   

 _也可以分为两包:_   

 _00 40 08 00 00 00 ff 18 70 16 3c_   

 _00 c0 06 05 30 2e 30 2e 31_   

 _分包数量也可以大于三包，大于三包时会有多个0x00,0x80开头的数据包。_   

_分包数量取决于数据长度和ATT MTU大小，LLSync会自动处理分包和组包，用户无需关心。_   

#### 5.6.3 升级请求应答包   

设备通过 LLEvent 对升级请求作出应答。   

<table>
  <tr>
    <th class="align-left">Type</th>
    <th class="align-left">Length</th>
    <th colspan="2" class="align-left">Value</th>
  </tr>
  <tr>
    <td>​</td>
    <td>​</td>
    <td>Indicate</td>
    <td>Payload</td>
  </tr>
  <tr>
    <td>0x09</td>
    <td>2 Bytes</td>
    <td>1 byte</td>
    <td>N Bytes</td>
  </tr>
</table>


升级请求应答包中value由1字节indicate和N字节的payload构成。   

1、indicate表示升级请求的请求结果。   

2、payload是请求结果的延伸字段。   

**indicate定义**：   

| Bit | 说明 |
|:----|:----|
| 0 | 0: 禁止升级  1: 允许升级     |
| 1 | 0: 不支持断点续传 1: 支持断点续传 |
| 2 ～ 7 | Reserved |


不同的indicate字段会有不同的payload。    

**当允许升级时payload定义如下：**   

| 字段 | 说明 |
|:----|:----|
| 1 byte total package numbers | 单次循环中可以连续传输的数据包个数，取值范围0x00 ~ 0xFF。 |
| 1 byte package length | 单个数据包大小，取值范围 0x00 ~ 0xF0 |
| 1 byte data retry time | 数据包的超时重传周期，单位：秒 |
| 1 byte device reboot time | 设备重启最大时间，单位：秒 |
| 4 bytes last received file size | 断点续传前已接收文件大小 |
| 1 byte package send interval | 小程序连续两个数据包的发包间隔 |


_说明：_   

_1._ _不支持断点续传时，已接收文件大小恒为0。_   

_2._ _小程序连续 5 个超时重传周期内没有收到设备端回应，认为升级失败。_   

_3._ _设备重启最大时间是设备下载成功后重启设备，小程序等待设备上报新版本号的最大时间，超出此时间小程序认为升级失败。_

_4._ _升级请求应答包分片规则请参见_ **_LLEvent 分片规则_**_。_   

_示例：_   

 _0a 00 09 03 10 0f 05 14 00 00 00 00，表示设备端允许升级且支持断点续传，单次循环传输0x10个数据包，每个数据包数据长度为0x0F，数据包超时设置为5秒，设备重启时间最大为20秒，断点续传前文件大小为0。_     

**当禁止升级时payload表示禁止升级的原因**：   

| 错误码 | 说明 |
|:----|:----|
| 2 | 设备电量不足 |
| 3 | 版本号错误 |


_示例：_   

 _0a 00 02 00 02,表示设备端禁止升级，因为设备电量过低。_   

#### 5.6.4 升级数据包   

App通过 LLOTA 下发升级数据包到设备。   

<table>
  <tr>
    <th class="align-left">Type</th>
    <th class="align-left">Length</th>
    <th colspan="2" class="align-left">Value</th>
  </tr>
  <tr>
    <td>​</td>
    <td>​</td>
    <td>Seq</td>
    <td>Payload</td>
  </tr>
  <tr>
    <td>0x01</td>
    <td>1 Byte</td>
    <td>1 Byte</td>
    <td>N Bytes</td>
  </tr>
</table>


_说明：_   

_1._ _length字段表示seq和payload的长度之和。_   

_2._ _seq表示数据包在单次循环中的序列号，从0开始，每一包数据增加1，直到total package numbers – 1结束，单次循环结束后重新从0开始。_   

_示例：_   

 _01 10 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01，表示seq为0x01的数据包，数据总长度为0x10，有效数据长度为0x0F，即0x0F个0x01。_   

#### 5.6.5 升级数据应答包   

设备通过 LLEvent 对升级数据包作出应答。   

<table>
  <tr>
    <th class="align-left">Type</th>
    <th class="align-left">Length</th>
    <th colspan="2" class="align-left">Value</th>
  </tr>
  <tr>
    <td>​</td>
    <td>​</td>
    <td>Next Seq</td>
    <td>File size</td>
  </tr>
  <tr>
    <td>0x0A</td>
    <td>2 Bytes</td>
    <td>1 byte</td>
    <td>4 Bytes</td>
  </tr>
</table>


_说明：_   

_1._ _next seq是设备收到的数据包的seq的下一个seq，file size是设备已接收的正确文件的大小。_   

_2._ _设备收到单个循环的所有数据包后，使用next seq和file size对此次循环作出应答，小程序收到应答后再发送下一循环的数据包数据包。_   

_3._ _设备收到错误的seq时，发送应答包给小程序请求重传，小程序根据设备上报的next seq和file size重新传输数据，小程序应该从file size处开始传输，seq等于next seq。_   

_4._ _当传输出错时，在一个数据重传周期内，设备端只会上报一次数据应答包。_   

_5._ _连续5个数据重传周期内没有收到正确的数据包，设备端认为升级失败，用户可以控制断开连接。_   

_6._ _升级数据包最后一个循环中数据包可能不足total package numbers，设备会根据文件大小计算，以便在收到最后一个数据包时仍然可以发送数据应答包。_   

_示例：_   

 _0b 00 05 0f 00 00 00 f0，表示设备端收到的最后一个数据包的seq为0x0F，设备当前接收的正确文件的大小为0xF0。_      

#### 5.6.6 升级数据结束通知包     

小程序通过 LLOTA 通知设备升级数据包下发结束。   

| Type |
|:----|
| 0x02 |


_说明：App文件下发结束后通知设备端进行固件检查并上报结果。_   

#### 5.6.7 上报固件检查结果      

设备通过 LLEvent 上报升级文件的校验结果。   

| type | length | value |
|:----|:----|:----|
| 0x0B | 2 Bytes | 校验结果定义 |


**校验结果定义：**   

| Bit | 说明 |
|:----|:----|
| 7 | 1 ： 校验通过   0 ： 校验失败  |
| 6 ～ 0 | 0 ： 文件CRC错误  1 ： flash操作失败   2 ： 文件内容错误 |


_说明：_   

_1._ _使用 1 字节表示校验结果，Bit 7 表示校验是否通过，如果文件校验错误，Bit 6 ～ 0表示具体的错误原因。_

_示例：0c 00 01 80，表示文件校验通过。_  

