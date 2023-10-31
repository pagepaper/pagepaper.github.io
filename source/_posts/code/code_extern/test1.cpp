//保存该文件为：test1.cpp
#include <stdio.h>
extern "C"
{
int f(void)
{
	return 1;
}
}

int main()
{
 	f();
	return 0;
}
