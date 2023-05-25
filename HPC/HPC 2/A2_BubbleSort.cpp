#include<iostream>
#include<omp.h>
using namespace std;


void bubble(int a[], int n){
    int i, j;
    for(i = 0; i < n-1; i++){
        for(j = 0; j < n-i-1; j++){
            if(a[j] > a[j+1])
                swap(a[j], a[j+1]);
        }
    }
}

void pBubble(int a[], int n){
    bool swapped;
    for(int i = 0; i < n; i++){            
        int first = i % 2;
        swapped = false;
        #pragma omp parallel for shared(a, first)
        for(int j = first; j < n-1;  j += 2){       
            if(a[j] > a[j+1]){       
                swap(a[j], a[j+1]);
                swapped = true;
             }       
            }  
        if(!swapped) break;
    }
}

int main(){
    
    // Difference in speeds for parallel and sequential will only come about when n is large.
    int n = 10000;
    int a[n];
    double start_time, end_time;

    // Create an array of n numbers, with digits from n to 1 in descending order
    for(int i = 0, j = n; i < n; i++, j--) a[i] = j;
    
    // Create a copy 
    int b[n];
    for(int i = 0; i < n; i++) b[i] = a[i];


    // Measure Sequential Time
    start_time = omp_get_wtime(); 
    bubble(a,n);
    end_time = omp_get_wtime();
    for(int i=0; i<n; i++){
        cout<<a[i]<<" ";
    }
    cout << "\nTime taken by sequential algorithm: " << end_time - start_time << " seconds\n";

    //Measure Parallel time
    start_time = omp_get_wtime(); 
    pBubble(b,n);
    end_time = omp_get_wtime(); 
        for(int i=0; i<n; i++){
        cout<<b[i]<<" ";
    }
    cout << "\nTime taken by parallel algorithm: " << end_time - start_time << " seconds\n";

    // Unfortunately parallel algorithms only do well on large scales.
    // In this case sequential may always do better than parallel.
    // This is because parallel algos have the overhead of creating threads.
    return 0;
}