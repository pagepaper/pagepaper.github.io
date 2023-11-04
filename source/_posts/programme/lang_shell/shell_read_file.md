---
title: shell文件读取
urlname: 5884f704c266996e0c594a2c54226762
categories : 
  - [编程开发]
  - [Shell]
tags: [Shell]
date: 2007-04-22 15:01:01
updated: 2007-04-22 15:01:01
---
## SHELL读取文件的方法
``` bash
//使用read命令读取一行数据
while read myline
do
	echo "LINE:"$myline
done < datafile.txt
```
<p>
``` bash
#使用read命令读取一行数据
cat datafile.txt | while read myline
do 
	echo "LINE:"$myline
done
```
<p>
``` bash
#读取一行数据
cat datafile.txt | while myline=$(line)
do 
	echo "LINE:"$myline
done
```
<p>
``` bash
#读取一行数据
while myline=$(line)
do 
	echo "LINE:"$myline
done < datafile.txt
```
<p>
``` bash
#使用read命令读取变量数据
cat datafile.txt | while read paraa parab parac
do
	echo "PARAA:"$paraa
	echo "PARAB:"$parab
	echo "PARAC:"$parac
done
```
<p>
``` bash
#使用read命令读取变量数据
while read paraa parab parac
do
	echo "PARAA:"$paraa
	echo "PARAB:"$parab
	echo "PARAC:"$parac
done < datafile.txt
```

<!--more-->

## read命令的使用方法
read命令从标准输入读取一行，并把输入行的每个字段（以指定的分隔符分隔）的值赋给命令行上的变量。

read [-ers] [-u fd] [-t timeout] [-p prompt] [-a array] [-n nchars] [-d delim] [name ...] 

参数解析：
| 参数 | 作用 |
| ---- | ---- |
| -e |  |
| -r	| 指定读取命令把“\”(反斜杠)做为输入行的一个普通字符，而非控制字符。 |
| -s	| 安静模式。如果指定该参数且从终端读入数据，那么输入的时候将不回显在屏幕上。 |
| -u <fd>|	指定读入数据的文件描述符，不再使用默认的标准输入。 |
| -t <timeout>	| 等待标准输入的超时时间，单位为秒。如果在指定的时间内没有输入，即时返回。 |
| -p <prompt>	| 打印提示符，等待输入，并将输入赋值给REPLY变量或者指定的变量。 |
| -a <array>	| 读入一组词，依次赋值给数组array。 |
| -n <nchars>	| 读取指定的字符数。如果已读取n个字符，马上返回，下次从返回点继续读取；如果已到行结束，无论满不满足n个字符都返回。 |
| -d <delim>	| 指定行结束符，读到该字符就当做一行的结束。 |
| name ... | 	指定read变量。read读取一行数据后，分隔行数据为各个字段，然后将字段依次赋给指定的变量。如果分隔后的字段数目比指定的变量多，那么将把剩余的全部字段值都赋给最后的那个变量；反之，剩余的变量被赋值为空字符串。如果read没有指定变量，系统使用默认的REPLY作为缺省变量名。 |

<strong>使用重定向读取数据</strong>
``` bash
exec 6< datafile.txt
while read -u 6 myline
do
	echo "LINE:"$myline
done
```

变量分隔符
read命令默认的分隔符是空格，多个空格被当做一个空格处理。我们也可以使用IFS（内部字段分隔符）指定的的字符作为分隔符。假如有如下内容的一个文件，它以“$”来分隔变量，希望把每个变量区别开来，可以使用如下脚本：

> baidu$google$tencnt$sina
> 123456789

使用read命令读取变量数据
``` bash
while read paraa parab parac parad
do
	echo "PARAA:"$paraa
	echo "PARAB:"$parab
	echo "PARAC:"$parac
	echo "PARAD:"$parad
done < datafile.txt
```

执行脚本的输出如下：
> PARAA:baidu
> PARAB:google
> PARAC:tencent
> PARAD:sina
> PARAA:123456789
> PARAB:
> PARAC:
> PARAD:


## 参考资料
1、http://www.linuxsense.org/archives/63.html
