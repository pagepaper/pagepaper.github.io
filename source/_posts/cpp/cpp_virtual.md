---
title: c++语法之虚
urlname: e184ac74b250b5e84824e9e520fb5e8f
categories : 
  - [编程开发]
date: 2007-07-13 16:45:00
updated: 2007-07-13 16:45:00
---
导语：C++中用“虚”的来命名的概念，涉及:
* <font color="#FF0000">虚函数</font>
* <font color="#FF0000">虚析构函数</font>
* <font color="#FF0000">纯虚函数</font>
* <font color="#FF0000">虚基类</font>

本文简要的说明下在面临什么样的问题下使用相应的技术、这些概念又是如何解决问题的。

## 虚函数
<font color="#E3940B">要解决的问题</font>
在一般的类继承关系中，当使用基类对象指针指向派生类对象时，通过基类对象的指针引用的是基类中的同名函数，而不是派生类中的同名函数！

<font color="#E3940B">解决方案</font>
如果需要通过基类的指针指向派生类的对象，并访问某个与基类同名的成员（如果是函数，其原型完全相同），那么首先在基类中将这个同名函数说明为虚函数。
虚函数允许派生类取代基类所提供的实现。编译器确保当对象为派生类时，取代者（译注：即派生类的实现）总是被调用，即使对象是使用基类指针访问而不是派生类的指针。这样就允许基类的算法被派生类取代，即使用户不知道派生类的细节。

<font color="#E3940B">虚函数语法规则</font>
``` c++
class class_name
{
public:
	virtual 函数类型 函数名(形参表)
	{
		.......
	}
};
``` 
virtual关键字来限定成员函数，虚函数声明只能出现在类声明中的函数原型声明中，而不能在成员的函数体实现的时候。

派生类中可以不显式给出虚函数的声明，系统根据以下规则来判断一个函数成员是不是虚函数：
> * 1.该函数是否与基类的虚函数有相同的名称；
> * 2.该函数是否与基类的虚函数有相同的参数个数及相同的对应参数类型；
> * 3.该函数是否与基类的虚函数有相同的返回值或者满足赋值兼容规则的指针、引用型的返回值。

如果从名称、参数及返回值三个方面检查以后，派生类的函数满足了上述条件，就被自动确定为虚函数。

对虚函数的说明：
> * 1.虚函数仅适用于有继承关系的类对象, 所以只有类的成员函数才能说明为虚函数。
> * 2.静态成员函数不能是虚函数。
> * 3.内联函数不能是虚函数。
> * 4.构造函数不能是虚函数。
> * 5.析构函数可以是虚函数。

## 虚析构函数

在C++中，不能声明虚构造函数，但是可以声明虚析构函数。

虚析构函数的作用：
当你可能通过基类指针删除派生类对象时，如果一个类的析构函数是虚函数，那么，由它派生而来的所有子类的析构函数也是虚函数。析构函数设置为虚函数之后，在使用指针引用时可以动态联编，实现运行时的多态，保证使用基类类型的指针就能够调用适当的析构函数针对不同的对象进行清理工作。

## 纯虚函数（抽象类的基础）
<font color="#E3940B">要解决的问题:</font>
有些函数只需给出其在基类中的声明，不需在其类中进行定义。

<font color="#E3940B">解决方案</font>
纯虚函数是一个在基类中说明的虚函数，它在该基类中没有定义具体的操作内容，要求各派生类根据实际需要定义自己的实现。

<font color="#E3940B">纯虚函数的语法规则</font>

``` c++
class class_name
{
public:
	virtual 函数类型 函数名（参数表）= 0;
	………
};
```

<font color="#E3940B">抽象类</font>
> * 1.带有纯虚函数的类是抽象类。抽象类的作用是通过它为一个类族建立一个公共的接口，使他们能够有效地发挥多态特性。抽象类只是声明了一族派生类的共同接口，而接口的完整实现，即纯虚函数的函数体，要由派生类自己定义。
> * 2.如果抽象类的派生类中给出全部纯虚函数的实现，就不再是抽象类；否则仍然是一个抽象类。
> * 3.抽象类不能实例化，不能声明一个抽象类的对象，但可以声明一个抽象类的指针或引用。通过指向并访问派生类对象。

## 虚基类(虚拟继承)
首先要明确：虚基类并不是带有虚函数的基类。

<font color="#E3940B">面临的问题:</font>
在不使用虚基类的情况下，如果某个派生类的部分或全部直接基类是从另外一个共同的基类派生而来的，那么在派生类的对象中，这些从共同基类继承的同名数据在内存中拥有多个拷贝，同一函数名会有多个映射。

我们使用如下这个例子进行分析：
``` c++
#include<iostream>
using namespace std;
 	 
class B0
{
public:
    B0(int a):nv(a){}
    int nv;
    void fun()
    {
        cout<<"fun B0" << endl;
    }
};
	 
class B1:public B0
{
public:
    B1(int a, int b):B0(a),nv1(b){}
    int nv1;
};

class B2:public B0
{
public:
    B2(int a, int c):B0(a),nv2(c){}
    int nv2;
};

class D1:public B1,public B2
{
public:
    D1(int a, int b, int c, int d):B1(a,b),B2(a,c),nvd(d){}
    int nvd;
    void fund()
    {
        cout <<"fund D1" << endl;
    }
};
 	 
int main()
{
    D1 myd(1, 2, 3, 4);
   
    myd.fun();
    return 0;
}
```
使用g++ -o test test.cpp，编译该程序，报错如下：

> g++ -o test test.cpp
> test.cpp: In function 'int main()':
> test.cpp:44: request for member 'fun' is ambiguous
> test.cpp:10: candidates are: void B0::fun()
> test.cpp:10:                 void B0::fun()


我们来分析下报错的原因。按照该程序的继承关系，D1继承关系、成员构成及存储分布图如下所示：
![](/images/e184ac74b250b5e84824e9e520fb5e8f/1.jpg)

由于void fun()包含在B1和B2中，在使用D1的对象调用该函数时，编译器无法进行决议来确定到底该调用哪个类中的void fun()，所以出现编译错误的情况。虽然我们可以使用作用域分辨符进行指定，如使用myd.B1::fun()或者myd.B2::fun()，可以编译通过执行也正确，但这样做仍然浪费了内存空间。为了解决这个问题，我们使用虚拟继承技术将程序改造如下：
``` c++
#include<iostream>
using namespace std;
 	 
class B0
{
public:
    B0(int a):nv(a){}
    int nv;
    void fun()
    {
        cout<<"fun B0" << endl;
    }
};
 	 
class B1:virtual public B0
{
public:
    B1(int a, int b):B0(a),nv1(b){}
    int nv1;
};

class B2:virtual public B0
{
public:
    B2(int a, int c):B0(a),nv2(c){}
    int nv2;
};
 	 
class D1:public B1,public B2
{
public:
    D1(int a, int b, int c, int d):B0(a),B1(a,b),B2(a,c),nvd(d){}
    int nvd;
    void fund()
    {
        cout <<"fund D1" << endl;
    }
};
	 
	 
int main()
{
    D1 myd(1, 2, 3, 4);
    
    myd.fun();
    return 0;
}
```
按照该程序的继承关系，D1继承关系、成员构成及存储分布图如下所示：
![](/images/e184ac74b250b5e84824e9e520fb5e8f/2.jpg)

<font color="#E3940B">这两段程序有着两个地方的区别：</font>
> 区别一：
> 程序1：class B1:public B0 class B2:public B0
> 程序2：class B1:virtual public B0 class B2:virtual public B0
我们在B1类和B2类继承B0类时，在前面加上virtual关键字就可以实现虚拟继承，使用虚拟继承后，当系统碰到多重继承的时候就会自动先加入一个B0的拷贝，当再次请求一个B0的拷贝的时候就会被忽略，保证继承类成员函数的唯一性。

> 区别二：
> 程序1：D1(int a, int b, int c, int d):B1(a,b),B2(a,c),nvd(d){}
> 程序2：D1(int a, int b, int c, int d):B0(a),B1(a,b),B2(a,c),nvd(d){}
建立一个对象时，如果这个对象中含有从虚基类继承来的成员，则虚基类的成员是由最远派生类构造函数（在这里是D1类）进行初始化的，而且只有最远派生类的构造函数会调用虚基类的构造函数，该派生类的其他基类（B1和B2）对虚基类构造函数的调用都自动被忽略。

<font color="#E3940B">作用域分辨符</font>
如果某个派生类的部分或全部直接基类是从另外一个共同的基类派生而来，在这些直接基类中，从上一级基类继承来的成员就拥有相同的名称，因此派生类中也产生同名现象，对这种类型的同名成员也要使用作用域分辨符来唯一标示，而其必须用直接基类来进行限定。
