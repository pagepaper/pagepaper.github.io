---
title: 编译安装OpenSSH
date: 2015-07-10 13:07:58
updated: 2015-07-10 13:07:58
categories : 
  - [软件使用]
  - [OpenSSH]
tags: [OpenSSH,OpenSSL,SSH,SSL]
urlname: 5c75ddd6ecde6f27c4a75fd895b847f6
---
OpenSSH是SSH(Secure SHell)协议的免费开源实现，SSH协议族可以用来进行远程控制， 或在计算机之间传送文件。OpenSSH是用于远程登录、命令执行以及文件传输的SSH协议的完整实现，它支持SSH协议的V1.3、V1.5和V2。自OpenSSH-V2.9 以来，默认的SSH协议是V2，使用RSA 钥匙。OpenSSH提供了服务端后台程序和客户端工具，用来加密远程控制和文件传输过程中的数据，并由此来代替原来的类似服务。

程序主要包括了几个部分：
> * ssh - rlogin与Telnet的替代方案。
> * scp、sftp - rcp的替代方案，将文件复制到其他电脑上。
> * sshd - SSH服务器。
> * ssh-keygen - 产生RSA或DSA密钥，用来认证用。
> * ssh-agent、ssh-add - 帮助用户不需要每次都要输入密钥密码的工具。
> * ssh-keyscan - 扫描一群机器，并记录其公钥。

在Centos、Ubuntu或者Debian等发行版上，我们可以使用yum或者apt提供的软件源直接安装。本文主要讲解的是使用源代码+手工编译+手工安装的方式来编译安装OpenSSH。

<!--more-->

## 下载OpenSSH源代码
据我所知，OpenSSH有四个下载源代码的入口：
**第一：Stable Releases代码包**
该代码包包含了预先配置的configure文件(<font color="#FF0000">如官方所说：Releases include a pre-built copy of the configure script</font>)。

从Relase版本的发行说明页面，可以找到源代码的发行版本的源代码包。
发行说明页面链接：[https://www.openssh.com/releasenotes.html](https://www.openssh.com/releasenotes.html)

![](/images/5c75ddd6ecde6f27c4a75fd895b847f6/7.png)

**第二：Stable Releases代码包**
该代码包包含了预先配置的configure文件(<font color="#FF0000">如官方所说：Releases include a pre-built copy of the configure script</font>)。
下载地址：[https://www.openssh.com/portable.html#downloads](https://www.openssh.com/portable.html#downloads)

我们使用所列的HTTP镜像网站下载。
![](/images/5c75ddd6ecde6f27c4a75fd895b847f6/5.png)

<p />

选择阿里云镜像网站：[https://mirrors.aliyun.com/pub/OpenBSD/OpenSSH/portable/](https://mirrors.aliyun.com/pub/OpenBSD/OpenSSH/portable/)
![](/images/5c75ddd6ecde6f27c4a75fd895b847f6/6.png)

**第三：使用Github仓库提供的Tags版本**
Github的代码仓库没有提供Relase版本，提供了一些Tag版本，从Tags页面我们下载Tag版本。
该代码包没有预先生成的configure脚本，需要我们自己生成(<font color="#FF0000">如官方所说：you'll need autoconf installed to build the configure script</font>)。
Tag页面：[https://github.com/openssh/openssh-portable/tags](https://github.com/openssh/openssh-portable/tags)

![](/images/5c75ddd6ecde6f27c4a75fd895b847f6/8.png)

**第四：git clone当前main分支**
该代码包没有预先生成的configure脚本，需要我们自己生成(<font color="#FF0000">如官方所说：you'll need autoconf installed to build the configure script</font>)。
``` bash
$ git clone https://github.com/openssh/openssh-portable # or https://anongit.mindrot.org/openssh.git
```

## 编译OpenSSH
使用上述几种方式下载我们所需代码包之后，我们本地以代码包"openssh-portable-V_8_9_P1.tar.gz"为例，将其拷贝到服务器之后，相继执行如下命令：

``` bash
$ tar -zxf openssh-portable-V_8_9_P1.tar.gz
$ cd openssh-portable-V_8_9_P1
$ autoconf
$ ll configure ## 查看configure文件是否正常生成
$ ./configure
```
<font color="#FF0000">**注意：Releases代码包提供了configure文件，所以无需使用autoreconf来生成configure文件，而Tags或者Git Clone版本需要执行autoreconf。**</font>
<p />

![](/images/5c75ddd6ecde6f27c4a75fd895b847f6/1.png)

> 我们发现configure也生成了，但执行./configure命令的时候报错了，提示下面的错误：
> ![](/images/5c75ddd6ecde6f27c4a75fd895b847f6/2.png)
>  ``` bash
   ./configure: line 5859: syntax error near unexpected token `-pipe'
   ./configure: line 5859: `       OSSH_CHECK_CFLAG_COMPILE(-pipe)'
>  ```
> 
> 从网上了找了下，错误的解决方法，提示不适用autoconf命令，[但可以使用<font color="#FF0000">**autoreconf**</font>命令来解决](http://lists.mindrot.org/pipermail/openssh-bugs/2016-May/016330.html) 
>
> ![](/images/5c75ddd6ecde6f27c4a75fd895b847f6/3.png)

使用<font color="#FF0000">**autoreconf**</font>命令再次产生configure文件，使用此文件进行配置，可以正常生成Makefile。
``` bash
$ ./configure
```
<p/>

![](/images/5c75ddd6ecde6f27c4a75fd895b847f6/4.png)

正确配置完毕之后，生成了我们需要的Makefile文件，然后我们执行make

``` bash
kevintian@dev:~/objs/openssh-portable-V_8_9_P1$ pwd
/home/kevintian/objs/openssh-portable-V_8_9_P1
kevintian@dev:~/objs/openssh-portable-V_8_9_P1$ ll Makefile
-rw-rw-r-- 1 kevintian kevintian 167350 Nov  5 11:48 Makefile
kevintian@dev:~/objs/openssh-portable-V_8_9_P1$ make
```
至此可以正确编译出我们所需可执行程序。
![](/images/5c75ddd6ecde6f27c4a75fd895b847f6/9.png)


## 参考资料
1.https://baike.baidu.com/item/OpenSSH/1137789
