---
title: c++语法之explicit
urlname: d841027d99af00846e5f621b77f1162b
categories : 
  - [编程开发]
date: 2007-07-16 16:45:00
updated: 2007-07-16 16:45:00
---
## 隐式类型转换带来的问题
我们首先看下面的这个例子，它可编译也可执行，最终结果是“TDemo::print 55”。有理由推断，实例化一个对象时，编译器自动将55这个整数转换成了“class TDemo”。类TDemo定义了一个单参数构造函数，而C++标准中，“单参数构造函数，可以完成从形参到该类型的一个隐式转换”，所以编译器能够完成从int类型到TDemo的类型转换。

``` c++
#include <iostream>

class TDemo
{
public:
    TDemo(int num);
    void print() const 
    { 
        std::cout << "TDemo::print "<< i_num << std::endl; 
    }

private:
    int i_num;
};

TDemo(int num):i_num(num){}

int main()
{
    TDemo demo = 55;
    demo.print();

    return 0;
}
```

## 禁止隐式类型转换
调用“TDemo demo = 55”实际就是“TDemo demo = TDemo(55)”，编译器隐式调用单参数构造函数生成一个TDemo临时对象，然后将该临时对象复制给demo变量。有时候并不希望编译器隐瞒我们，“私自”完成进行这种隐式转换，在需要转换的时候需要程序员明确使用显示转换，这样写下来的程序简单清晰，还可以规避很多由隐式转换引发的歧义和错误。这时就可以使用关键字explicit来禁止在需要隐式转换的上下文中使用单参数构造函数。
修改上面例子程序，单参数构造函数使用explicit来修饰，再次编译程序后，发现会提示错误：“error: conversion from `int' to non-scalar type `TDemo' requested”，也就禁止了隐式类型转换。

``` c++
#include <iostream>

class TDemo
{
public:
    explicit TDemo(int num);
    void print() const 
    { 
        std::cout << "TDemo::print "<< i_num << std::endl; 
    }

private:
    int i_num;
};

TDemo(int num):i_num(num){}

int main()
{
    TDemo demo = 55; //error: conversion from `int' to non-scalar 
                     //type `TDemo' requested
    demo.print();

    return 0;
}
```

## 使用explicit关键字注意事项
<font color="#FF0000">**explicit关键字只能用于类内部的构造函数声明上，在类的定义体外部所做的定义上不在重复它。**</font>也就是下面两种方式都是错误的：
``` c++
class TDemo
{
public:
    TDemo(int num);
};

//error: only declarations of constructors can be `explicit'
explicit TDemo::TDemo(int num):i_num(num){}
class TDemo
{
public:
    explicit TDemo(int num);
};

//error: only declarations of constructors can be `explicit'
explicit TDemo::TDemo(int num):i_num(num){}
```
