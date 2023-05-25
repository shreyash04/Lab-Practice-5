#include<iostream>
#include<cstdlib>
#include<cuda.h>
using namespace std;

void matrix_multiplication_cpu(int *A, int *B, int *C, int C_rows, int C_cols, int common){
    int it = 0;
    for(int row = 0; row < C_rows; row++){
        for(int col = 0; col < C_cols; col++){
            C[it] = 0;
            for(int k = 0; k < common; k++){
                C[it] += A[row*common + k] * B[C_cols*k + col];
            }
            it++;
        }
    }
}

__global__ void matrix_multiply(int *A, int *B, int *C, int C_rows, int C_cols, int common)
{
    int col = blockIdx.x;
    int row = blockIdx.y;
    int k;
  
    C[C_cols*row + col] = 0;
    for(k=0; k<common; k++){
        C[C_cols*row + col] += A[row*common + k] * B[C_cols*k + col];
    }
}


int main(){

    int A_rows, A_cols, B_rows, B_cols, C_rows, C_cols;
    cout<<"Enter A rows: ";
    cin>>A_rows;
    cout<<"Enter A cols: ";
    cin>>A_cols;
    B_rows = A_cols;
    cout<<"B rows: "<<B_rows<<endl;
    cout<<"Enter B cols: ";
    cin>>B_cols;
    C_rows = A_rows, C_cols = B_cols;
    
    int *A = new int[A_rows*A_cols];
    int *B = new int[B_rows*B_cols];
    int *C = new int[C_rows*C_cols];

    int k = 0;
    for(int i = 0 ; i < A_rows; i++){
        for(int j = 0; j < A_cols; j++){
            A[k] = rand() % 100;
            k++;
        }
    }

    k = 0;
    for(int i = 0 ; i < B_rows; i++){
        for(int j = 0; j < B_cols; j++){
            B[k] = rand() % 10;
            k++;
        }
    }

    int *mat1_gpu, *mat2_gpu, *result_gpu;

    cout<<"\nMatrix 1\n";
    k = 0;
    for(int i = 0 ; i < A_rows; i++){
        for(int j = 0; j < A_cols; j++){
            cout<<A[k]<<" ";
            k++;
        }
        cout<<endl;
    }

    cout<<"\nMatrix 2\n";
    k = 0;
    for(int i = 0 ; i < B_rows; i++){
        for(int j = 0; j < B_cols; j++){
            cout<<B[k]<<" ";
            k++;
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

    matrix_multiply<<<grid, 1>>>(mat1_gpu, mat2_gpu, result_gpu, C_rows, C_cols, A_cols);

    cudaEventRecord(gpu_stop);
    cudaEventSynchronize(gpu_stop);
    cudaEventElapsedTime(&gpu_elapsed_time, gpu_start, gpu_stop);
    cudaEventDestroy(gpu_start);
    cudaEventDestroy(gpu_stop);

    cudaMemcpy(C, result_gpu, C_rows*C_cols*sizeof(int), cudaMemcpyDeviceToHost);
    cout << "\nGPU result:\n";
    k = 0;
    for(int i = 0 ; i < C_rows; i++){
        for(int j = 0; j < C_cols; j++){
            cout<<C[k]<<" ";
            k++;
        }
        cout<<endl;
    }
    cout<<"GPU Elapsed time is: "<<gpu_elapsed_time<<" milliseconds"<<endl;

    cudaEventCreate(&gpu_start);
    cudaEventCreate(&gpu_stop);
    cudaEventRecord(gpu_start);

    matrix_multiplication_cpu(A, B, C, C_rows, C_cols, A_cols);

    cudaEventRecord(gpu_stop);
    cudaEventSynchronize(gpu_stop);
    cudaEventElapsedTime(&gpu_elapsed_time, gpu_start, gpu_stop);
    cudaEventDestroy(gpu_start);
    cudaEventDestroy(gpu_stop);

    cout<<"\nCPU result:\n";
    k = 0;
    for(int i = 0 ; i < C_rows; i++){
        for(int j = 0; j < C_cols; j++){
            cout<<C[k]<<" ";
            k++;
        }
        cout<<endl;
    }
    cout<<"CPU Elapsed time is: "<<gpu_elapsed_time<<" milliseconds"<<endl;

    cudaFree(mat1_gpu);
    cudaFree(mat2_gpu);
    cudaFree(result_gpu);

    return 0;
}