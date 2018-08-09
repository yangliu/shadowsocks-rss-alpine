## 自己使用的酸酸乳服务器docker版本


### 注意：

1.	便宜的OpenVZ因为内核基本上达不到docker运行的最低要求，所以就不要尝试了！Amazon EC2和Google GCP都没问题，不推荐阿里云海外版是因为可能被...你懂的：）
2.	密码请到Dockerfile里寻找。
3. 不推荐直接pull下来使用，最好的方式就是自己修改Dockerfile，把端口、密码替换成你自己的
4. 每周修改一次端口和密码，改变特征有病治病，没病强身
5. 使用非周知端口可以明显减少干扰，我是通过控制台日志看到的


### 更新日志：
- 2018.8.9:
  1. 大幅度简化，改用 VOLUME，加载外部 config.json 来配置酸酸乳 (by yangliu)

- 2018.3.9：
	1. 全面更新到SSRR最新代码，以后只使用ShadowsocksR作为默认服务器
	2. 内部使用了SSRR的git代码库地址，所以自己每次构建就是最新代码，除非遇到代码库关停或者重大更新（例如配置文件增加新字段等），否则原则上不再更新，请自己构建吧
	3. sed 替换遇到特殊字符会截断，所以密码不要填写带有特殊字符的密码，大小写加数字15-20位足够玩了

### <del>懒人使用方法（强烈不推荐）：
<del>docker pull s0fx2/shadowsocks-rss-alpine

<del>docker run -d --name rss -it -p 666:666 s0fx2/shadowsocks-rss-alpine

### 自己构建：

git clone https://github.com/s0fx2/shadowsocks-rss-alpine.git

- 修改 SSR_SERVER_PORT 端口号
- 修改 SSR_PASSWORD 加密密码
- 修改 SSR_METHOD 加密方法
- 修改 SSR_PROTOCOL 协议插件
- 修改 SSR_OBFS 混淆方式
- FAST_OPEN 根据宿主内核做调整，能运行docker的一般都支持，但是需要你自己确认，默认是开启的

docker build -t some_name_your_build .
docker run -d --name rss_name -p your_port:your_port some_name_your_build


### 推荐的加密方法：

如果使用 `auth_chain_X` 系列协议插件，则不加密，默认就是如此


### 推荐的协议插件：

`auth_chain_a`（推荐）：对首个包的认证部分进行使用Encrypt-then-MAC模式以真正免疫认证包的CCA攻击，预防各种探测和重防攻击，数据流自带RC4加密，同时此协议支持单端口多用户，不同用户之间无法解密数据，每次加密密钥均不相同，具体设置方法参见breakwa11的博客。使用此插件的服务器与客户机的UTC时间差不能超过24小时，即只需要年份日期正确即可，针对UDP部分也有加密及长度混淆。使用此插件建议加密使用none。此插件不能兼容原协议，支持服务端自定义参数，参数为10进制整数，表示最大客户端同时使用数，最小值支持直接设置为1，此插件能实时响应实际的客户端数量（你的客户端至少有一个连接没有断开才能保证你占用了一个客户端数，否则设置为1时其它客户端一连接别的就一定连不上）。

`auth_chain_b`（推荐）：与auth_chain_a几乎一样，但TCP部分采用特定模式的数据包分布（模式由密码决定），使得看起来像一个实实在在的协议，使数据包分布分析和熵分析难以发挥作用。如果你感觉当前的模式可能被识别，那么你只要简单的更换密码就解决问题了。此协议为测试版本协议，不能兼容原协议。

`auth_chain_c`（推荐）：与auth_chain_b相比，尽力使得数据包长度分布归属到模式中，让包分布看起来更规整。但此版本与auth_chain_b相比对带宽有更多的浪费。

`auth_chain_d`（推荐）：与auth_chain_c相比，在一定程度上增加了各种密码生成的模式的最大适用长度，这样就不需要在极端情况下再临时生成随机数，降低大包传输时的计算量，提高下载极限速度。

推荐使用auth_chain_X系列插件，在以上插件里混淆能力较高，而抗检测能力最高，即使多人使用也难以识别封锁。同时如果要发布公开代理，以上auth插件均可严格限制使用客户端数（要注意的是若为`auth_sha1_v4_compatible`，那么用户只要使用原协议就没有限制效果），而`auth_chain_X`协议的限制最为精确。


### 推荐的混淆方式：

`tls1.2_ticket_auth`：伪装为tls请求。参数配置与http_simple一样

### 其他参数请自行添加变量
其他内容请自己Google文档，或者去原开发者页面查看
