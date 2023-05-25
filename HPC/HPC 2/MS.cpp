#include <iostream>
#include <omp.h>
using namespace std;
void merge(int* arr, int l, int m, int r) {
	int i, j, k;
	int n1 = m - l + 1;
	int n2 = r - m;

	int L[n1], R[n2];

	for (i = 0; i < n1; i++)
    	L[i] = arr[l + i];
	for (j = 0; j < n2; j++)
    	R[j] = arr[m + 1 + j];

	i = 0;
	j = 0;
	k = l;
	while (i < n1 && j < n2) {
    	if (L[i] <= R[j]) {
        	arr[k] = L[i];
        	i++;
    	}
    	else {
        	arr[k] = R[j];
        	j++;
    	}
    	k++;
	}

	while (i < n1) {
    	arr[k] = L[i];
    	i++;
    	k++;
	}

	while (j < n2) {
    	arr[k] = R[j];
    	j++;
    	k++;
	}
}

void mergeSort(int* arr, int l, int r) {
	if (l < r) {
    	int m = l + (r - l) / 2;
    	#pragma omp parallel sections
    	{
        	#pragma omp section
        	{
            	mergeSort(arr, l, m);
        	}
        	#pragma omp section
        	{
            	mergeSort(arr, m + 1, r);
        	}

    	}
        int num=omp_get_max_threads();
        cout<<num<<endl;
    	merge(arr, l, m, r);
	}
}

int main() {
    int *a,n;
    double start,stop;
    cout<<"\nEnter total no of elements:"<<endl;
    cin>>n;
    a=new int[n];
    cout<<"\nEnter elements:"<<endl;
    for(int i=0;i<n;i++){
   	 cin>>a[i];
    } 
	mergeSort(a, 0, n - 1);
	cout<<"Sorted array is:"<<endl;
	for (int i = 0; i < n; i++){
    	cout << a[i] << " ";
    }
    cout<<"\n"<<(stop-start);
	return 0;
}
