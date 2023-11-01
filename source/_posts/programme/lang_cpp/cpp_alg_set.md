---
title: STL之交集、并集、差集
urlname: 83d668164ccdb07908cc1146d8c6050d
categories : 
  - [编程开发]
date: 2007-07-25 17:45:00
updated: 2007-07-25 17:45:00
---
简单介绍STL对集合操作有标准的算法：
* 交集set_intersection
* 并集set_union
* 差集set_difference
* 对称差集set_symeetric_difference。

针对这里提及的四个集合运算必须特别注意：
> * 1、第一个算法需保证第一集合和第二集合有序，并从小到大排序，内部使用默认“<”操作符比较元素大小；
> * 2、第二个算法需保证第一集合和第二集合有序，排序方式参照Compare确定，内部使用Compare比较元素大小。

## set_intersection(交集)
``` c++
template <class InputIterator1, class InputIterator2, class OutputIterator>
OutputIterator set_intersection(InputIterator1 first1, InputIterator1 last1,
                    InputIterator2 first2, InputIterator2 last2,
                    OutputIterator result);

template <class InputIterator1, class InputIterator2, class OutputIterator, class Compare>
OutputIterator set_intersection(InputIterator1 first1, InputIterator1 last1,
                    InputIterator2 first2, InputIterator2 last2,
                    OutputIterator result, Compare comp);
```
该函数用于求两个集合的交集，结果集合中包含所有同时属于第一个集合和第二个集合的元素。例如：集合{1,2,3,7,9}和{3,4,5,7}的交集为{3,7}。
函数返回值：结果集合的结束位置迭代器。
参数：第一个集合的开始位置，第一个集合的结束位置，第二个参数的开始位置，第二个参数的结束位置，结果集合的插入迭代器。对于第二个算法，Compare指定用于比较元素大小的仿函数。

## set_union(并集)
``` c++
template <class InputIterator1, class InputIterator2, class OutputIterator>
OutputIterator set_union(InputIterator1 first1, InputIterator1 last1,
                    InputIterator2 first2, InputIterator2 last2,
                    OutputIterator result);

template <class InputIterator1, class InputIterator2, class OutputIterator, class Compare>
OutputIterator set_union(InputIterator1 first1, InputIterator1 last1,
                    InputIterator2 first2, InputIterator2 last2,
                    OutputIterator result, Compare comp);
```
该函数用于求两个集合的交集，结果集合中包含所有同时属于第一个集合和第二个集合的元素。例如：集合{1,2,3,7,9}和{3,4,5,7}的并集为{1,2,3,4,5,7}。

## set_difference(差集)
``` c++
template <class InputIterator1, class InputIterator2, class OutputIterator>
OutputIterator set_difference(InputIterator1 first1, InputIterator1 last1,
                    InputIterator2 first2, InputIterator2 last2,
                    OutputIterator result);

template <class InputIterator1, class InputIterator2, class OutputIterator, class Compare>
OutputIterator set_difference(InputIterator1 first1, InputIterator1 last1,
                    InputIterator2 first2, InputIterator2 last2,
                    OutputIterator result, Compare comp);
```
该函数用于求两个集合的差集，结果集合中包含所有属于第一个集合但不属于第二个集合的元素。例如：集合{1,2,3,7,9}和{3,4,5,7}的差集为{1,2,9}。

## set_symeetric_difference(对称差集)
``` c++
template<class InputIterator1, class InputIterator2, class OutputIterator>
OutputIterator set_symmetric_difference(InputIterator1 first1, InputIterator1 last1,
                    InputIterator2 first2, InputIterator2 last2,
                    OutputIterator result);

template<class InputIterator1, class InputIterator2, class OutputIterator, class Compare&gt
OutputIterator set_symmetric_difference(InputIterator1 first1, InputIterator1 last1,
                    InputIterator2 first2,
                    InputIterator2 last2,
                    OutputIterator result, Compare comp);
```
数学上，两个集合的对称差集是只属于其中一个集合，而不属于另一个集合的元素组成的集合。也就是说对称差集是去除同时出现在两个集合中的元素后，两集合其他元素组成的集合。例如：集合{1,2,3,7,9}和{3,4,5,7}的对称差为{1,2,4,5,9}。集合论中的这个运算相当于布尔逻辑中的异或运算。集合A和B的对称差通常表示为AΔB。

## 交集、合集、差集、对称差集使用方法
``` c++
#include <iostream>
#include <algorithm>
#include <vector>

void print_vector(const std::string & s_name, const std::vector & vec)
{
    typedef typename std::vector::size_type size_type;
    std::cout << s_name << ": ";
    for (size_type i = 0; i < vec.size(); i++)
    std::cout << vec[i] << (i == vec.size() - 1?"\n":",");
}

int main()
{
    int a[] = {1,2,3,7,9};
    std::vector v_less_1(a, a + 5);
    int b[] = {3,4,5,7};
    std::vector v_less_2(b, b + 4);
    
    std::vector vr_less;
    std::set_intersection(v_less_1.begin(), v_less_1.end(), 
        v_less_2.begin(), v_less_2.end(),
        std::insert_iterator<std::vector>(v_less, v_less.begin())
    );
    print_vector("v_less", v_less);
    
    std::vector vr_less;
    std::set_difference(v1.begin(), v1.end(), 
        v2.begin(), v2.end(), 
        std::insert_iterator<std::vector>(v_less, v_less.begin()), std::less())
    );
    print_vector("v_less", v_less);
    
    std::vector v_greater;
    std::set_difference(v1.begin(), v1.end(), 
        v2.begin(), v2.end(),
        std::insert_iterator<std::vector >(v_greater, v_greater.begin()), std::greater())
    );
    print_vector("v_greater", v_greater);
    
    return 0;
}
```