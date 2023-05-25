#include<iostream>
#include<omp.h>
using namespace std;

void merge(int arr[], int low, int mid, int high){
    int temp[high-low+1];
    int i, j, k, m;
    j = low;
    m = mid + 1;
    for (i = low; j <= mid && m <= high; i++){
        if (arr[j] <= arr[m]){
            temp[i] = arr[j];
            j++;
        }
        else{
            temp[i] = arr[m];
            m++;
        }
    }
    if (j > mid){
        for (k = m; k <= high; k++){
            temp[i] = arr[k];
            i++;
        }
    }
    else{
        for (k = j; k <= mid; k++){
            temp[i] = arr[k];
            i++;
        }
    }
    for (k = low; k <= high; k++)
        arr[k] = temp[k];
}

void mergesort(int arr[], int low, int high){
    int mid;
    if(low < high){
        mid = (low+high)/2;

        mergesort(arr, low, mid);
        mergesort(arr,mid+1,high);
        merge(arr, low, mid, high);
    }
}

void pMergesort(int arr[], int low, int high){
    int mid;
    if(low < high){
        mid = (low+high)/2;

        #pragma omp parallel sections num_threads(2) 
        {
            #pragma omp section
            {
                pMergesort(arr,low,mid);
            }
      
            #pragma omp section
            {
                pMergesort(arr,mid+1,high);
            }
        }

        merge(arr,low,mid,high);
    }
}

int main(){

    int n = 100;
    int a[n];
    double start_time, end_time;

    // Create an array of n numbers, with digits from n to 1 in descending order
    for(int i = 0, j = n; i < n; i++, j--) a[i] = j;

    // Create a copy
    int b[n];
    for(int i = 0; i < n; i++) b[i] = a[i];

    // Measure Sequential Time
    start_time = omp_get_wtime();
    mergesort(a, 0, n-1);
    end_time = omp_get_wtime();
    for (int i = 0; i < n; i++){
        cout << a[i] << " ";
    }
    cout << "\nTime taken by sequential algorithm: " << end_time - start_time << " seconds\n";

    // Measure Parallel time
    start_time = omp_get_wtime();
    pMergesort(b, 0, n-1);
    end_time = omp_get_wtime();
    for(int i = 0; i < n; i++){
        cout << b[i] << " ";
    }
    cout << "\nTime taken by parallel algorithm: " << end_time - start_time << " seconds\n";

    // Unfortunately parallel algorithms only do well on large scales.
    // In this case sequential may always do better than parallel.
    // This is because parallel algorithms have the overhead of creating threads.
    return 0;
}