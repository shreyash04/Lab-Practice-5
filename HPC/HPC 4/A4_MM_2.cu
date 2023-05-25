#include<iostream>
#include<cstdlib>
#include<cmath>
#include<cuda.h>
using namespace std;

#define A_rows 2
#define A_cols 3
#define B_rows 3
#define B_cols 2
#define C_rows 2
#define C_cols 2

void matrix_multiplication_cpu(int a[A_rows][A_cols], int b[B_rows][B_cols], int c[C_rows][C_cols]){
    for(int i = 0; i < C_rows; i++){
        for(int j = 0; j < C_cols; j++){
            int sum = 0;
            for(int k = 0; k < A_cols; k++){
                sum += a[i][k] * b[k][j];
            }
            c[i][j] = sum;
        }
    }
}

__global__ void matrix_multiply(int *a, int *b, int *c)
{
    int x = blockIdx.x;
    int y = blockIdx.y;
    int i;
  
    c[C_cols*y + x] = 0;
    for(i=0; i<A_cols; i++){
        c[C_cols*y + x] = c[C_cols*y + x] + a[A_cols*y + i] * b[B_cols*i + x];
    }
}


int main(){

    int A[A_rows][A_cols];
    int B[B_rows][B_cols];
    int C[C_rows][C_cols];

    for(int i = 0 ; i < A_rows; i++){
        for(int j = 0; j < A_cols; j++){
            A[i][j] = rand() % 10;
        }
    }

    for(int i = 0 ; i < B_rows; i++){
        for(int j = 0; j < B_cols; j++){
            B[i][j] = rand() % 10;
        }
    }

    int *mat1_gpu, *mat2_gpu, *result_gpu;

    cout<<"\nMatrix 1\n";
    for(int i = 0 ; i < A_rows; i++){
        for(int j = 0; j < A_cols; j++){
            cout<<A[i][j]<<" ";
        }
        cout<<endl;
    }

    cout<<"\nMatrix 2\n";
    for(int i = 0 ; i < B_rows; i++){
        for(int j = 0; j < B_cols; j++){
            cout<<B[i][j]<<" ";
        }
        cout<<endl;
    }

    cudaMalloc((void **)&mat1_gpu, A_rows*A_cols*sizeof(int));
    cudaMalloc((void **)&mat2_gpu, B_rows*B_cols*sizeof(int));
    cudaMalloc((void **)&result_gpu, C_rows*C_cols*sizeof(int));

    cudaMemcpy(mat1_gpu, A, A_rows*A_cols*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(mat2_gpu, B, B_rows*B_cols*sizeof(int), cudaMemcpyHostToDevice);

    /* Here we are defining two dimensional Grid(collection of blocks) structure. 
    Syntax is dim3 grid(no. of columns, no. of rows) */
    dim3 grid(B_cols, A_rows);

    float gpu_elapsed_time;
    cudaEvent_t gpu_start, gpu_stop;

    cudaEventCreate(&gpu_start);
    cudaEventCreate(&gpu_stop);
    cudaEventRecord(gpu_start);

    matrix_multiply<<<grid, 1>>>(mat1_gpu, mat2_gpu, result_gpu);

    cudaEventRecord(gpu_stop);
    cudaEventSynchronize(gpu_stop);
    cudaEventElapsedTime(&gpu_elapsed_time, gpu_start, gpu_stop);
    cudaEventDestroy(gpu_start);
    cudaEventDestroy(gpu_stop);

    cudaMemcpy(C, result_gpu, C_rows*C_cols*sizeof(int), cudaMemcpyDeviceToHost);
    cout << "\nGPU result:\n";
    for(int i = 0 ; i < C_rows; i++){
        for(int j = 0; j < C_cols; j++){
            cout<<C[i][j]<<" ";
        }
        cout<<endl;
    }
    cout<<"GPU Elapsed time is: "<<gpu_elapsed_time<<" milliseconds"<<endl;

    cudaEventCreate(&gpu_start);
    cudaEventCreate(&gpu_stop);
    cudaEventRecord(gpu_start);

    matrix_multiplication_cpu(A, B, C);

    cudaEventRecord(gpu_stop);
    cudaEventSynchronize(gpu_stop);
    cudaEventElapsedTime(&gpu_elapsed_time, gpu_start, gpu_stop);
    cudaEventDestroy(gpu_start);
    cudaEventDestroy(gpu_stop);

    cout<<"\nCPU result:\n";
    for(int i = 0 ; i < C_rows; i++){
        for(int j = 0; j < C_cols; j++){
            cout<<C[i][j]<<" ";
        }
        cout<<endl;
    }
    cout<<"CPU Elapsed time is: "<<gpu_elapsed_time<<" milliseconds"<<endl;

    cudaFree(mat1_gpu);
    cudaFree(mat2_gpu);
    cudaFree(result_gpu);

    return 0;
}