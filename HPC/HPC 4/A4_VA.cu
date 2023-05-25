#include<iostream>
#include<cuda.h>
using namespace std;

void fill_array(int *arr, int size){
    for(int i=0; i<size; i++){
        arr[i] = rand() % 100;
    }
}

void add_cpu(int *arr1, int *arr2, int *result, int size){
    for(int i=0; i<size; i++){
        result[i] = arr1[i] + arr2[i];
    }
}

void print_array(int *arr, int size){
    for(int i=0; i<size; i++){
        cout<<arr[i]<<" ";
    }
    cout<<endl;
}

__global__ void add(int *arr1, int *arr2, int *result, int size){
    int id = blockIdx.x;
    result[id] = arr1[id] + arr2[id];
}

int main(){
    int size;
    cout<<"Enter size of vector: ";
    cin>>size;

    int *arr1_cpu = new int[size];
    int *arr2_cpu = new int[size];
    int *result_cpu = new int[size];

    fill_array(arr1_cpu, size);
    cout<<"Array 1: ";
    print_array(arr1_cpu, size);

    fill_array(arr2_cpu, size);
    cout<<"Array 2: ";
    print_array(arr2_cpu, size);

    int *arr1_gpu, *arr2_gpu, *result_gpu;
    
    /* cudaMalloc() allocates memory from Global memory on GPU */
    cudaMalloc((void **)&arr1_gpu, size*sizeof(int));
    cudaMalloc((void **)&arr2_gpu, size*sizeof(int));
    cudaMalloc((void **)&result_gpu, size*sizeof(int));

    /* cudaMemcpy() copies the contents from destination to source. Destination is GPU and source is CPU */
    cudaMemcpy(arr1_gpu, arr1_cpu, size*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(arr2_gpu, arr2_cpu, size*sizeof(int), cudaMemcpyHostToDevice);
    
    cudaEvent_t start, stop;
    float elapsedTime;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    /* call to kernel. Here 'size' is number of blocks, 1 is the number of threads per block */
    add<<<size,1>>>(arr1_gpu, arr2_gpu, result_gpu, size);

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsedTime, start, stop);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    /* Here we are copying content from GPU(Device) to CPU(Host) */
    cudaMemcpy(result_cpu, result_gpu, size*sizeof(int), cudaMemcpyDeviceToHost);

    cout<<"\nGPU result:\n";
    print_array(result_cpu, size);
    cout<<"Elapsed Time = "<<elapsedTime<<" milliseconds"<<endl;

    cudaFree(arr1_gpu);
    cudaFree(arr2_gpu);
    cudaFree(result_gpu);

    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    add_cpu(arr1_cpu, arr2_cpu, result_cpu, size);

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsedTime,start,stop);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    cout << "\nCPU result:\n";
    print_array(result_cpu, size);
    cout<<"Elapsed Time = "<<elapsedTime<<" milliseconds" << endl;

    return 0;
}