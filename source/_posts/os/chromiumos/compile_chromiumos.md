---
title: ChromiumOS编译研究总结
date: 2021-07-10 17:43:34
updated: 2021-07-10 17:43:34
categories : 
  - [ChromiumOS]
tags: [ChromiumOS,操作系统]
urlname: b8ae9a1bbf1692666f30446dcb0100b5
---
ChromiumOS是谷歌的一款云操作系统，秉承了Chrome浏览器快速、简洁、安全的特性。相比Windows、Mac OS等传统的本地操作系统来说，一种新的、应用“云计算”来实现大部分功能、本地计算机只存储少量信息的新操作系统模式渐渐崭露头角。Chromium OS就是这样的一款轻量型、云计算为主的操作系统。目前Google与多家一线终端制造商合作开发出了基于ChromiumOS的ChromeBook系列产品，比如三星的Series 5系列。

本文目标
目标1：原生ChromiumOS的编译步骤、方法和注意事项
目标2：更换原生ChromiumOS的开机动画
目标3：简述ChromiumOS的编译原理

## ChromiumOS的相关资源
|网站|链接|
| ---- | ---- |
|Chromium官方网站|https://www.chromium.org |
|ChromiumOS官方网站|https://www.chromium.org/chromium-os |
|ChromiumOS代码|https://chromium.googlesource.com/chromiumos |
|ChromiumOS文档入口|https://chromium.googlesource.com/chromiumos/docs/ |
|ChromiumOS文档|https://chromium.googlesource.com/chromiumos/docs/+/HEAD/README.md |
|ChromiumOS磁盘映像结构|https://chromium.googlesource.com/chromiumos/docs/+/HEAD/disk_format.md |
|ChromiumOS启动|https://www.chromium.org/chromium-os/chromiumos-design-docs/boot-design |

<!--more-->

## 编译ChromiumOS

**0x01 确认环境依赖**
* Ubuntu Linux (version 18.04 - Bionic)(需64位系统)
* 一个具有sudo权限的账号
* 大内存机器（本次编译是在编译机上架设的虚拟机，该虚拟机尽量把CPU都选上，内存开辟到20G以上，磁盘在100G以上）

**0x02 安装依赖软件，安装git，python等软件**
``` bash
$ sudo apt-get install git gitk git-gui curl xz-utils python3-pkg-resources python3-virtualenv python3-oauth2client
```

Git安装完毕之后使用如下命令配置Git
``` bash
$ git config --global user.email "you@example.com"
$ git config --global user.name "Your Name"
```

如果不进行配置，在下载代码时，可能会出现如下的错误：

![](/images/b8ae9a1bbf1692666f30446dcb0100b5/1.png)

**0x03 安装Google的代码下载工具depot_tools**
``` bash
$ mkdir -p /home/chrome/apps/depot_tools

$ cd /home/chrome/apps/depot_tools

$ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
```

代码下载完毕之后，我们将depot_tools放到系统目录中。

``` bash
$ sudo vi /etc/profile

# 将如下的命令加入到/etc/profile
$ export PATH=/home/chrome/apps/depot_tools:$PATH

$ source /etc/profile
```

**0x04 设置sudoers超时时间**
如果不想每次启动新终端都重新输入密码，在配置文件中禁止tty_tickets即可，但此举使得所有进程都使用同一个sudo任务，具体参看跨终端sudo。
``` bash
$ cd /tmp
$ cat > ./sudo_editor <<EOF
#!/bin/sh
echo Defaults \!tty_tickets > \$1          # Entering your password in one shell affects all shells
echo Defaults timestamp_timeout=180 >> \$1 # Time between re-requesting your password, in minutes
EOF
$ chmod +x ./sudo_editor
$ sudo EDITOR=./sudo_editor visudo -f /etc/sudoers.d/relax_requirements
```

上述方法为官方教程，但我实验过后发现如下问题：

![](/images/b8ae9a1bbf1692666f30446dcb0100b5/2.jpg)

unchanged？也就是说，没有改变，没有生效？？！！看来官方教程也有错误。所以我用了其他的方法。

> 新方法如下所述：
> **第一步**，先设置visudo的编辑器，Ubuntu默认采用nano作为visudo的编辑器，我用不习惯，先变成vi再说（如果你习惯了nano，那么不用做这一步）。
> 使用如下命令编辑/etc/sudoers文件。
> ``` bash
  $ sudo vi /etc/sudoers
> ```
> 打开文件之后，在文件中加入如下一行命令即可：
> ``` bash
> Defaults editor=/usr/bin/vi, env_editor
> ```
> 
> 添加内容之后，如下图所示：
> ![](/images/b8ae9a1bbf1692666f30446dcb0100b5/3.jpg)
>
> **第二步**，我们使用如下命令编辑 /etc/sudoers这个文件。
> ``` bash
  $ sudo visudo
> ```
> 从第一步来看，既然我们可以使用vi命令来编辑这个文件，为什么还要用“sudo visudo”呢？
> 答案：千万不要使用普通的编辑命令如vi来修改sudoers文件。由于该文件的特殊性，错误的语法将导致你无法在系统里获取提升权限。正确的修改方式是使用visudo命令。visudo命令将打开一个文字编辑器，但是在保存文件的时候，将会验证sudoers文件的语法。这将防止你配置错误导致sudo命令受阻。
> 
> **第三步**，打开文件之后，我们在文件中添加如下内容。
> ```
> Defaults !tty_tickets
 
> Defaults timestamp_timeout=180
> ```
> 添加内容之后，如下图所示：
> ![](/images/b8ae9a1bbf1692666f30446dcb0100b5/4.png)
> 退出编辑，不需要使用其他的命令，修改的配置即刻生效！

**0x05 下载源代码**
按照官方指引，官方希望大家把ChromiumOS的代码下载到当前用户home目录的根节点下。比如当前的用户为chrome，那么我们应当将源代码下载到 /home/chrome/chromiumos目录。当然，这里修改成你的账户名。
所以我们创建一个目录：
``` bash
$(outside) mkdir -p /home/chrome/chromiumos

$(outside) cd /home/chrome/chromiumos

# 初始化下载列表
$(outside) repo init -u https://chromium.googlesource.com/chromiumos/manifest

# 开始下载代码，下载线程设置的不能多也不能少。。。
$(outside) repo sync -j4
```

根据网速的不同，下载有可能需要几个小时不等，需要慢慢耐心等待。下面是一些下载过程中的截图，供参考。
![](/images/b8ae9a1bbf1692666f30446dcb0100b5/5.png)
![](/images/b8ae9a1bbf1692666f30446dcb0100b5/6.png)

**0x06 下载构建环境**
``` bash
$(outside) cros_sdk
```

注意：
1.cros_sdk不需要经常下载，基本上下载一次即可。
2.如需删除chroot，请使用cros_sdk --delete正确删除它。

**0x07 构建编译脚本**
``` bash
# 以下所有的步骤，都在chroot之后，如果你退出了，再次编译时，务必使用cros_sdk再次进入chroot
$(outside) cros_sdk

$(inside) export BOARD=amd64-generic

$(inside) setup_board --board=${BOARD}
```

**0x08 编译各种资源包**
``` bash
# 设置密码：当我们编译成功后，进入ChromiumOS之后，可以进入命令界面
# 在命令界面需要Login，这里就是设置Login的密码，Login账号是默认的：chronos
$(inside) ./set_shared_user_password.sh 

# 开始编译资源包
$(inside) ./build_packages --board=${BOARD}
```

编译资源包需要的时间也不少，在当前的编译机上，大概需要60m到80m之间。

**0x09 构建映像**
``` bash
$(inside) ./build_image --board=${BOARD} --noenable_rootfs_verification
```

构建完成之后，生成的映像文件目录：
![](/images/b8ae9a1bbf1692666f30446dcb0100b5/7.png)

latest是指向最新映像包的软连接，进入该目录之后，我们会看到生成好的映像文件。
![](/images/b8ae9a1bbf1692666f30446dcb0100b5/8.png)

<font color="#FF0000">/home/chrome/chromiumos/src/build/images/amd64-generic/latest/chromiumos_image.bin</font>
该文件就是我们最终需要的映像文件，将其拷贝出来，在其他机器上使用U盘烧录工具，写入U盘，然后我们使用U盘引导系统，进行体验。

## 更换开机动画
首先，先说明两个目录：
<font color="#FF0000">/home/chrome/chromiumos/src/platform/chromiumos-assets</font>
该目录下是我们的代码目录，我们使用修改后的序列图替换本处的图片。系统会自动编译该目录，然后将该目录下的图片放到编译后的正确的目录（也就是下面这个目录）。

<font color="#FF0000">/home/chrome/chromiumos/chroot/build/amd64-generic/usr/share/chromeos-assets</font>
该目录下的存放真实的启动序列图，你的图片到底有没有编译进来，可以到这个目录来验证。

所以，我们先使用如下的命令，告诉编译系统，使用本地资源包，而不是从网上下载。
``` bash
$(inside) cros_workon --board=${BOARD} start chromeos-base/chromiumos-assets
```

上述命令执行完之后，我们继续使用如下的命令构建映像。
``` bash
# 如果在以前代码的基础上构建的，已经设置过密码，可以忽略
$(inside) ./set_shared_user_password.sh

$(inside) ./build_packages --board=${BOARD}

$(inside) ./build_image --board=${BOARD} --noenable_rootfs_verification
```

参考图，从下图的红色框标注的地方，我们可以发现，编译系统知道我们修改了本次，所以它会从本地构建。
![](/images/b8ae9a1bbf1692666f30446dcb0100b5/9.png)

执行完build_packages命令之后，我们可以到下述目录去看看看我们的资源包是不是替换了。
![](/images/b8ae9a1bbf1692666f30446dcb0100b5/10.png)

## 将系统安装从USB安装到运行机的硬盘上
**0x01 使用U盘引导进入ChromiumOS的图形界面（比如那个选择wifi的地方）**

**0x02 在进入图形界面之后，使用组合键：Ctrl + Alt + F2，进入命令界面**
![](/images/b8ae9a1bbf1692666f30446dcb0100b5/11.jpg)

账户：chronos
密码：编译时使用./set_shared_user_password.sh设置的密码

**0x03 登录系统之后，使用如下命令将系统从U盘安装到运行机的硬盘上**
``` bash
$sudo /usr/sbin/chromeos-install --dst /dev/mmcblk1
```

安装成功之后，提示移除U盘重启机器。拔掉U盘，重新启动机器，系统从硬盘启动，进入ChromiumOS。

至此，我们已经完整的编译出了一个ChromiumOS，并且将其安装到硬盘上。

## 综上所有命令
``` bash
$ (outside) mkdir -p /home/chrome/chromiumos 

$ (outside) cd /home/chrome/chromiumos 

$ (outside) repo init -u https://chromium.googlesource.com/chromiumos/manifest

$ (outside) repo sync -j4

$ (outside) cros_sdk 

$ (inside) export BOARD=amd64-generic 

$ (inside) setup_board --board=${BOARD} 

$ (inside) cros_workon --board=${BOARD} start chromeos-base/chromiumos-assets 

$ (inside) ./set_shared_user_password.sh 

$ (inside) ./build_packages --board=${BOARD} 

$ (inside) ./build_image --board=${BOARD} --noenable_rootfs_verification 
```

## 参考资料：
1.https://baike.baidu.com/item/Chromium%20OS/7569945?fr=ge_ala
2.https://chromium.googlesource.com/chromiumos/docs/+/HEAD/developer_guide.md
3.https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up
4.https://chromium.googlesource.com/chromiumos/docs/+/HEAD/tips-and-tricks.md#How-to-make-sudo-a-little-more-permissive
