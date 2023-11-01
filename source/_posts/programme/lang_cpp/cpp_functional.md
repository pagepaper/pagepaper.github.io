---
title: c++11特性之函数对象（仿函数）
urlname: a226f61f7c5ea55f722ba139f6528cb2
categories : 
  - [c++]
tags: [c++,c++11]
date: 2018-03-12 14:39:00
updated: 2018-03-12 14:39:00
---
在C++11之前，要实现函数对象或者仿函数，主要参考《C++设计新思维》中的Loki库，它采用模板推导的方式来实现。虽然Loki可以模拟函数对象，但其代码看起来比较晦涩，使用又不方便。在C++11以后，开始原生支持函数对象，新标准中的用法简单清晰，所有的可调用对象有了统一的调用方式，极易上手。本文总结函数对象的各种使用方法。

## std::function的定义
``` c++
#include <functional>
template< class R, class... Args >
class function<R(Args...)>; // R表示返回值，Args表示函数参数
```

类模板std::function是通用多态函数封装器。std::function的实例能存储、复制及调用任何可调用目标，包括函数、lambda表达式、bind表达式或其他函数对象，还有指向成员函数指针和指向数据成员指针。
存储的可调用对象被称为std::function的目标。若 std::function不含目标，则称它为空。调用空std::function的目标导致抛出std::bad_function_call异常。

<!--more-->

## std::bind绑定器
std::bind用来将可调用对象与其参数一起进行绑定，绑定后的结果可以使用std::function进行保存。在绑定参数时，可以直接绑定函数的全部参数，也可以绑定部分参数。在绑定部分参数时，通过使用std::placeholders，来决定该位置上的参数为调用发生时的第几个参数。
比如：
``` c++
// 将本文件保存，例如文件名叫做function.cpp
// 编译：g++ -o test function.cpp -std=c++11
// 运行：./test
 
#include <functional>
#include <iostream>
 
void print_num(int i, int a)
{
    std::cout << i << "," << a << std::endl;
}
 
int main(int argc, char ** argv)
{
    // 示例1：绑定所有的两个参数
    // std::placeholders::_1 代表函数调用时的第一个参数
    // std::placeholders::_2 代表函数调用时的第二个参数
    std::function<void(int, int)> FuncA = std::bind(print_num, std::placeholders::_1, std::placeholders::_2);
 
    // 此时1对应std::placeholders::_1, 2对应std::placeholders::_2
    FuncA(1, 2);    // 执行后函数输出：1,2
 
    // 示例2：绑定部分参数
    // 我们默认print_num的第一个参数值始终为3，在实际调用时，仅需要传入第二个参数即可
    std::function<void(int, int)> FuncB = std::bind(print_num, 3, std::placeholders::_1);
 
    // 此时4对应std::palcehoders::_1
    FuncB(4,5); // 执行后函数输出：3,4，注意结果并不是4,5。因为在函数定义已经将3作为第一个参数的默认值。
     
    // 示例3：绑定部分函数
    std::function<void(int)> FuncC = std::bind(print_num, 3, std::placeholders::_1);
     
    FuncC(4);   // 执行后函数输出：3,4
 
    return 0;
}
```

## std::function与std::bind示例
``` c++
// 将本文件保存，例如文件名叫做function.cpp
// 编译：g++ -o test function.cpp -std=c++11
// 运行：./test
 
#include <functional>
#include <iostream>
 
struct Foo 
{
    Foo(int num) : num_(num) {}
     
    void print_num(int i) const { std::cout << "num_:" << num_  << ", i:" << i << std::endl; }
 
    int num_;
};
 
struct PrintNum 
{
    void operator()(int i) const
    {
        std::cout << i << std::endl;
    }
     
    static void print_num(int i , int a)
    {
        std::cout << i << "," << a << std::endl;
    }
};
 
void print_num(int i)
{
    std::cout << i << std::endl;
}
 
void print_num2(int i, int a)
{
    std::cout << i << "," << a << std::endl;
}
 
template <int T_SIZE>
void print_num3(int i, int a)
{
    std::cout << i << "," << a << ", T_SIZE:" << T_SIZE << std::endl;
}
 
void print_num4()
{
    std::cout << "print_num4" << std::endl;
}
 
int main()
{
    // 示例1：存储自由函数
    std::function<void(int)> FuncFree1 = print_num;
    FuncFree1(101);
 
    std::function<void(int, int)> FuncFree2 = print_num2;
    FuncFree2(102, 1021);
 
    std::function<void(int, int)> FuncFree3 = print_num3<102333>;
    FuncFree3(103, 1031);
 
    std::function<void(int, int)> FuncFree4 = PrintNum::print_num;
    FuncFree4(104, 1041);
 
    std::function<void()> FuncFree5 = print_num4;
    FuncFree5();
 
    // 示例2：存储 lambda
    std::function<void()> FuncLambda1 = []() { print_num(201); };
    FuncLambda1();
 
    std::function<void(int)> FuncLambda2 = [](int iNum) { print_num(iNum); };
    FuncLambda2(202);
 
    // 示例3：存储到成员函数的调用
    std::function<void(const Foo&, int)> FuncFunc = &Foo::print_num;
 
    const Foo xFoo3(300);
    FuncFunc(xFoo3, 3011);
    FuncFunc(302, 3021);    // 由302构造一个Foo对象
 
    // 示例4：存储到数据成员访问器的调用
    Foo xFoo4(400);
    std::function<int(Foo const&)> FuncData = &Foo::num_;
    std::cout << "num_:" << FuncData(xFoo4) << std::endl;
 
    // 示例5：存储到std::bind调用的结果
    std::function<void()> FuncBind1 = std::bind(print_num, 501);
    FuncBind1();
  
    // 示例6：存储到成员函数及对象的调用
    Foo xFoo6(600);
 
    std::function<void(int)> FuncObject  = std::bind(&Foo::print_num,  xFoo6, std::placeholders::_1);
    FuncObject(601);
 
    // 示例7：存储到成员函数和对象指针的调用
    Foo xFoo7(700);
 
    std::function<void(int)> FuncPointer = std::bind(&Foo::print_num, &xFoo7, std::placeholders::_1);
    FuncPointer(701);
 
    // 示例8：存储到函数对象的调用
    std::function<void(int)> FuncOperator = PrintNum();
    FuncOperator(801);
}
```

## 参考
https://zh.cppreference.com/w/cpp/utility/functional/function
https://blog.csdn.net/wangshubo1989/article/details/49134235