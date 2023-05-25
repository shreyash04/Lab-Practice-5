#include <iostream>
#include <omp.h>

using namespace std;

void bubble_sort(int *a, int n){
    for(  int i = 0;  i < n;  i++ ){  	 
   	    int first = i % 2; 	 
   	    #pragma omp parallel for shared(a,first)
   	    for(  int j = first;  j < n-1;  j += 2  ){  	
            if(a[j]> a[j+1]  ){  	 
     		    swap(a[j],a[j+1]);
   		    }  	
   	    }  	
    }
}
void swap(int &a, int &b){
    int test;
    test=a;
    a=b;
    b=test;
}
int main() {
    int *a,n;
    cout<<"\nEnter total no of elements:"<<endl;
    cin>>n;
    a=new int[n];
    cout<<"\nEnter elements:"<<endl;
    for(int i=0;i<n;i++)
    {
   	 cin>>a[i];
    } 
    bubble_sort(a,n); 
    cout<<"\nSorted array:"<<endl;
    for(int i=0;i<n;i++)
    {
   	 cout<<a[i]<<endl;
    }

    return 0;
}