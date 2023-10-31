---
title: 编译器扩展deprecated
date: 2007-09-09 13:07:58
updated: 2007-09-09 13:07:58
categories : 
  - [编程开发]
tags:
urlname: fffb60d4cfb96748b3e07d9013dab01d
---
## 背景
当前的工作与SVN有关，今天使用SVN库编写了一个小程序，编译代码时发现编译器告警：“warning: 'svn_client_ls2' is deprecated (declared at”。
``` bash
svn@linux-rwdx:~/objs/motadou> make
g++ webdav.cpp -o webdav -I/home/svn/apps/svn/include/subversion-1 -I/home/svn/apps/neon/include/neon -I/home/svn/apps/apr-util/include/apr-1 -I/home/svn/apps/apr/include/apr-1 -I/home/svn/apps/sqlite/include -I/home/svn/apps/ssl/include/openssl\
-L/home/svn/apps/svn/lib -lsvn_client-1 -lsvn_wc-1 -lsvn_fs-1 -lsvn_fs_fs-1 -lsvn_fs_util-1 -lsvn_ra-1 -lsvn_ra_neon-1 -lsvn_ra_local-1 -lsvn_repos-1 -lsvn_delta-1 -lsvn_diff-1 -lsvn_subr-1  -L/home/svn/apps/neon/lib -lneon -L/home/svn/apps/apr-util/lib -laprutil-1 -L/home/svn/apps/apr/lib -lapr-1 -pthread /home/svn/apps/sqlite/lib/libsqlite3.a -L/home/svn/apps/ssl/lib -lssl -lcrypto -lz

webdav.cpp: In function 'int svn_list(Handle&, const std::string&)':
webdav.cpp:120: warning: 'svn_client_ls2' is deprecated (declared at /home/svn/apps/svn/include/subversion-1/svn_client.h:4942)
webdav.cpp:120: warning: 'svn_client_ls2' is deprecated (declared at /home/svn/apps/svn/include/subversion-1/svn_client.h:4942)
```

于是查看“/home/svn/apps/svn/include/subversion-1/svn_client.h”文件中对函数svn_client_ls2的声明，发现该函数之前有这么一个宏定义“SVN_DEPRECATED”。继续跟踪下去，发现SVN_DEPRECATED是这样定义的：

``` c
#ifndef SVN_DEPRECATED
# if !defined(SWIGPERL) && !defined(SWIGPYTHON) && !defined(SWIGRUBY)
#  if defined(__GNUC__) && (__GNUC__ >= 4 || (__GNUC__==3 && __GNUC_MINOR__>=1))
#   define SVN_DEPRECATED __attribute__((deprecated))
#  elif defined(_MSC_VER) && _MSC_VER >= 1300
#   define SVN_DEPRECATED __declspec(deprecated)
#  else
#   define SVN_DEPRECATED
#  endif
# else
#  define SVN_DEPRECATED
# endif
#endif
```

<font color="#FF0000">很明显这个告警表明"svn_client_ls2"在程序中，某个接口已经有替代接口或者不推荐继续使用，所以在编译的时候给出报警提醒开发者注意。</font>之所以可以在编译期给出报警，主要是使用了“__attribute__((deprecated))”特性，我在ARM网站上发现有这样一段提示：
> 可以使用 deprecated 变量属性声明不提倡使用的变量，而不会导致编译器发出任何警告或错误。但是，对 deprecated 变量的任何访问都会生成警告，但仍会进行编译。警告指出了使用和定义变量的位置。这有助于确定不提倡使用特定定义的原因。


<font color="#FF0000">使用该属性，我们可以在我们对外提供库中，提前向使用方预告接口的废止，让开发者尽早转向替代接口。</font>对该编译器扩展申明的变量或者函数，我们要明白：
> * 如果该变量或者函数没有被第三方开发者使用，那么即使开发者使用了包含该函数的库去编译代码，也不会出现任何警告或者错误。
> * 如果开发者在代码中引用了被“__attribute__((deprecated))”声明的变量或者函数，那么编译器此时才会出现警告，来提示函数已经过期。

## 测试使用该属性
``` c++
// 保存当前为：test.cpp
// 编译：g++ -o test test.cpp
// 运行：./test
 
#include <iostream>
 
__attribute__((deprecated)) void GetSystemInfo()
{
    std::cout << "test __attribute__((deprecated))" << std::endl;   
}
 
int main()
{
    GetSystemInfo();
 
    return 0;
}
```

我们编译下这个文件，看看是否在编译期提醒我们“GetSystemInfo”这个接口已经过期了。

![](/images/fffb60d4cfb96748b3e07d9013dab01d/1.png)

编译时报警告：“test.cpp:10:16: warning: ‘void GetSystemInfo()’ is deprecated (declared at test.cpp:3) [-Wdeprecated-declarations]”，提醒我们代码文件中第10行调用的GetSystemInfo已经过期。即使提醒了我们函数已经过期，但我们使用过期函数仍然编译成功，也可成功运行。
