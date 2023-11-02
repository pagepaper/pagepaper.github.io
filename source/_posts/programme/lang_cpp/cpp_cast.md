---
title: C++标准类型转换
urlname: fb7cd73e06d1c676855e174abb24c2f2
categories : 
  - [C++]
tags: [C++]
date: 2007-07-18 15:45:00
updated: 2007-07-18 15:45:00
---
## C++ Primer的强烈建议
强制类型转换关闭或挂起了正常的类型检查。强烈建议避免使用强制类型转换，不依赖类型转换也能写出很好的C++程序。

这个建议在如何看待 reinterpret_cast 的使用时非常重要。此类强制转换总是非常危险的。相似地，使用价格const_cast也总是预示着设计权限。设计合理的系统应不需要使用强制转换抛弃const特性。其他的强制转换，如static_cast和dynamic_cast，各有各的用途，但都不应频繁使用。每次使用强制转换前，程序员应该仔细考虑是否还有其他不同的方法可以达到同一目的。如果非强制转换不可，则应限制强制转换值的作用域，并且记录所有假定涉及的类型，这样能减少错误发生的机会。

## const_cast\<type\>(expression)
该运算符将转换掉expression的const属性。

通过下面的代码段展示const_cast的使用场景：
``` c++
void print(char * s)
{
	printf("%s\n", s);
}

std::string s = "motadou.cnblogs.com";

print(s.c_str()); //编译失败，因为s.c_str()结果为const *，与print函数的类型不匹配。

print(const_cast<char *>(s.c_str()); //成功
```
使用const_cast需要注意的问题：
该类型转换符除了添加或删除const属性外，执行其他任何类型转换，都会引起编译错误。

## static_cast\<type-id\>(expression)
该运算符把expression转换为type-id类型，但没有运行时类型检查来保证转换的安全性。它主要有如下几种用法：
* (1)基类和子类之间指针或引用的转换
> 上行转换(子类指针或引用-->基类指针或引用)是安全的，类型不匹配时编译报错；
> 下行转换(基类指针或引用-->子类指针或引用)时，由于没有动态类型检查，所以是不安全的。建议使用dynamic_cast。
* (2)基本数据类型之间的转换
如把int转换成char，把int转换成enum。这种转换的安全性也要开发人员来保证。
* (3)把void *指针转换成目标类型的指针
* (4)把任何类型的指针转换成void *类型

使用static_cast需要注意如下几个问题：
(1)所谓下行转换的不安全性，指的是如果类CA、CB均继承自CBase，用个基类指针表示CA*指针，然后使用static_cast将该基类指针转换为CB*指针，直接使用这个CB*指针访问类CB内的数据成员将存在风险。比如：
``` c++
#include <iostream>

class CBase{};
class CA : public CBase
{
public:
	void print(){ std::cout << "==CA::print==" << std::endl; }
};

class CB : public CBase
{
public:
	void print(){ std::cout << "==CB::print==" << psz_name << std::endl; }
	char * psz_name;
};

int main()
{
	CBase * pa = new CA();
	CB * pb = static_cast(pa);
	pb->print();
	
	return 0;
}
```
上述代码能够顺利的通过编译，真正执行程序时会发生什么？使用指针pb调用CB::print，由于CB的psz_name并没有分配空间，事实上是个野指针，非法访问野指针肯定导致程序coredump。

(2)static_cast不能转换无关类型（非基类和子类）的指针。比如：
``` c++
char c_menu = 'c';
```

//下面的类型转换错误，编译提示：invalid static_cast from type 'char*' to type 'signed char*'
``` c++
signed char * psc_menu = static_cast<signed char *>(&c_menu);
```
char *和signed char *不是同一类型的指针，static_cast无法转换故编译报错。

(3)static_cast不能转换掉expression的const、volatile、__unaligned属性。

## dynamic_cast\<type-id\>(expression)
该运算符把expression转换为type-id类型，转换时进行类型检查来保证转换的安全性。它主要有如下几种用法：
(1)将基类类型对象的引用或指针安全地转换为同一继承层次中其他类型的引用或指针。转换时进行类型检查，如果发现绑定到引用或者指针的对象不是目标类型的对象，则转换失败。

使用dynamic_cast需要注意如下几个问题：
> * (1)类必须有虚函数，否则编译报错(编译器将提示不含有虚函数)。原因是转换过程中需要运行时类型信息，该信息存储在类的虚函数表中，只有定义虚函数，类才有虚函数表。
> * (2)与dynamic_cast一起使用的指针必须是有效的--它必须为0或者指向一个对象。
> * (3)type-id和expression要么同是引用，要么同是指针。
> * (4)上行转换，dynamic_cast与static_cast的效果相同。
> * (5)下行转换，dynamic_cast进行运行时类型检查，类型符合则成功转换，否则转换失败。失败表现为：转换指针类型时，dynamic_cast返回结果NULL；转换引用类型时，抛出std::bad_cast异常。
> * (6)相同基类不同子类之间的交叉转换均为失败，表现与上述相同。

## reinterpret_cast\<type\>(expression)
该操作符只进行简单的比特位拷贝，将expression的所有比特位拷贝给type-id一份。可以说仅仅是重新解释了给出的对象的比特模型。
该操作符和Ｃ语言的强制转换，最为类似。
所谓重新解释比特模型，我们可以这么理解：假设有个指向int类型的指针pint，使用double * pdouble = reinterpret_cast<double *>(pint)进行转换。实际只是将pint的4个字节拷贝给pdouble。我们知道pint指向的空间是4个字节，而理论上pdouble应该指向8个字节，但此时pdouble指向的其他4个字节将是非法数据。重新解释比特模型，就是把int值的空间，当做double类型来使用。该操作符相当危险，因此必须谨慎使用。

使用reinterpret_cast需要注意如下几个问题： 
> * (1)上面提到static_cast不能进行无关类型的转换，reinterpret_cast可以做到，但需注意转换的安全性。 
> * (2)reinterpret_cast本质上依赖于机器。为了安全地使用reinterpret_cast，要求程序员完全理解所涉及的数据类型，以及编译器实现强制类型转换的细节。