#include <sys/time.h>
#include "type.h"
#include <iostream>
#include <ctime>
#include <cstdio>


using namespace std;

__global__ void mainIteration(int m, UINT64 total_weight, int blockSize, int gridSize, 
			      UINT64 idxOffset, int profit, int *dev_array1, int *dev_array2,
			      int *dev_cap, int *dev_weight, int item){
	int thread = blockIdx.x * blockDim.x + threadIdx.x;
	//for all possible MKP vector capacities between 0 and cap
	
	for (UINT64 idx = thread; idx < total_weight; idx += (blockSize*gridSize) ){
		int maxprofit = dev_array1[idx];
		UINT64 idxdiff = idx - idxOffset;
		int td = idx;
		int di, test = 1;
		UINT64 rr = total_weight;

		for (int i=m-1; i>=0; i--){
			rr /= (UINT64)(dev_cap[i] + 1);
			di = td / rr;
			if (di < dev_weight[i]){
				test = 0;
				break;
			}	
			td = td % rr;
		}		

		if(test){
			//T_(k)(d) = max(T_(k-1)(d), T_(k-1)(d-w_k)+p_k);
			//d-w_k
			maxprofit = max(maxprofit, dev_array1[idxdiff] + profit);
		}
		dev_array2[idx] = maxprofit;
		//printf("idx: %d, dev_array1: %d, dev_array2: %d, dev_array1[idx-idxOffset]: %d\n", idx, dev_array1[idx], maxprofit, dev_array1[idx-idxOffset]);		
	}
}

__global__ void mainIteration1(int m, UINT64 total_weight, int blockSize, int gridSize, 
			      UINT64 idxOffset, int profit, int *dev_array1, int *dev_array2,
			      int *dev_cap, int *dev_weight, int item){
	int thread = blockIdx.x * blockDim.x + threadIdx.x;
	//for all possible MKP vector capacities between 0 and cap
	
	for (UINT64 idx = thread; idx < total_weight; idx += (blockSize*gridSize) ){
		
		int maxprofit = dev_array1[idx];
		
		if (idx >= dev_weight[0]){
			//T_(k)(d) = max(T_(k-1)(d), T_(k-1)(d-w_k)+p_k);
			//d-w_k
			maxprofit = max(maxprofit, dev_array1[idx - idxOffset] + profit);
		}
		dev_array2[idx] = maxprofit;
	}
}

__global__ void mainIteration2(int m, UINT64 total_weight, int blockSize, int gridSize, 
			      UINT64 idxOffset, int profit, int *dev_array1, int *dev_array2,
			      int *dev_cap, int *dev_weight, int item){
	int thread = blockIdx.x * blockDim.x + threadIdx.x;
	//for all possible MKP vector capacities between 0 and cap
	
	for (UINT64 idx = thread; idx < total_weight; idx += (blockSize*gridSize) ){
		
		int maxprofit = dev_array1[idx];
		UINT64 d0, d1;
		
		d0 = idx % (dev_cap[0]+1);
		d1 = idx / (dev_cap[0]+1);

		if(d0>=dev_weight[0] && d1>= dev_weight[1]){
			maxprofit = max(maxprofit, dev_array1[idx - idxOffset] + profit);
		}
		dev_array2[idx] = maxprofit;
	}
}

__global__ void mainIteration3(int m, UINT64 total_weight, int blockSize, int gridSize, 
			      UINT64 idxOffset, int profit, int *dev_array1, int *dev_array2,
			      int *dev_cap, int *dev_weight, int item){
	int thread = blockIdx.x * blockDim.x + threadIdx.x;
	//for all possible MKP vector capacities between 0 and cap
	
	for (UINT64 idx = thread; idx < total_weight; idx += (blockSize*gridSize) ){
		
		int maxprofit = dev_array1[idx];
		UINT64 d0, d1, d2, d;
		d = idx;
		d0 = d % (dev_cap[0]+1);
		d1 = (d / (dev_cap[0]+1) ) % (dev_cap[1]+1);
		d2 = (d / (dev_cap[0]+1) * (dev_cap[1]+1) );		
	
		if(d0>=dev_weight[0] && d1>=dev_weight[1] && d2>=dev_weight[2]){
			maxprofit = max(maxprofit, dev_array1[idx - idxOffset] + profit);
		}
		dev_array2[idx] = maxprofit;
	}
}

__global__ void mainIteration4(int m, UINT64 total_weight, int blockSize, int gridSize, 
			      UINT64 idxOffset, int profit, int *dev_array1, int *dev_array2,
			      int *dev_cap, int *dev_weight, int item){
	int thread = blockIdx.x * blockDim.x + threadIdx.x;
	//for all possible MKP vector capacities between 0 and cap
	
	for (UINT64 idx = thread; idx < total_weight; idx += (blockSize*gridSize) ){
		
		int maxprofit = dev_array1[idx];
		UINT64 d0, d1, d2, d3, d;

		d = idx;
		d0 = d % (dev_cap[0]+1);
		d1 = (d / (dev_cap[0]+1) ) % (dev_cap[1]+1);
		d2 = (d / (dev_cap[0]+1) * (dev_cap[1]+1) ) % (dev_cap[2]+1);		
		d3 = (d / (dev_cap[0]+1) * (dev_cap[1]+1) * (dev_cap[2]+1) );		

		if(d0>=dev_weight[0] && d1>=dev_weight[1] && d2>=dev_weight[2] && d3>=dev_weight[3]){
			maxprofit = max(maxprofit, dev_array1[idx - idxOffset] + profit);
		}
		dev_array2[idx] = maxprofit;
	}
}
/*
__global__ void mainIteration(int m, UINT64 total_weight, int blockSize, int gridSize, 
			      int idxOffset, int profit, int *dev_array1, int *dev_array2,
			      int *dev_cap, int *dev_weight, int item){
	int thread = blockIdx.x * blockDim.x + threadIdx.x;
	//for all possible MKP vector capacities between 0 and cap
	
	for (UINT64 idx = thread; idx < total_weight; idx += (blockSize*gridSize) ){
		
		int maxprofit = dev_array1[idx];
		int td = dev_array1[idx];
		int di, test = 1;
		
		for (int i=0; i<m; i++){
			di = idx % dev_cap[i];
			if (di < dev_weight[item * m + i]){
				test = 0;
				break;
			}	
			td = td / dev_cap[i];
		}		

		if(test){
			//T_(k)(d) = max(T_(k-1)(d), T_(k-1)(d-w_k)+p_k);
			//d-w_k
				maxprofit = max(maxprofit, dev_array1[idx - idxOffset] + profit);
		}
	}
}
*/

UINT64 MKPoffset(int *weight, int *cap, int m){
	UINT64 offset = 0;
	UINT64 ww = 1;
	for (int i=0; i<m; i++){
		offset += ((UINT64)weight[i] * ww);
		ww *= (UINT64)(cap[i] + 1);
	}

	return offset;
}

__global__ void printArray(int *dev_array1, int *dev_array2, int *dev_cap, int *dev_weight, 
				int m, int n, int total_weight){
	printf("m: %d, n: %d, total_weight: %d\n", m, n, total_weight);
	printf("dev_array1: ");
	for (int i=0 ; i<total_weight; i++)
		printf("%d ", dev_array1[i]);
	printf("\n");
	printf("dev_array2: ");	
	for (int i=0 ; i<total_weight; i++)
		printf("%d ", dev_array2[i]);
	printf("\n");
 	printf("dev_cap: ");
	for (int i=0; i<m; i++)
		printf("%d ", dev_cap[i]);
	printf("\n");
	printf("dev_weight: \n");
	for (int i=0; i<m; i++){
		for (int j=0; j<n; j++){
			printf("%d ", dev_weight[j*m+i]);
		}
		printf("\n");
	}
	printf("\n");
}

int DPiteration(int m, int n, int *weight, int *profit, int *cap){
	
	struct timeval tbegin, tend;	
	int maxvalue;
	//MKP is a table consist of all constraints and items. Constraints includes no-constraint; item includes 0 item.
	UINT64 total_weight = 1;
	for (int i=0; i<m; i++){
		total_weight *= (UINT64)(cap[i]+1);
	}
	
	int blockSize, gridSize;
	blockSize = 512;
	gridSize = 16;

	int *dev_array1 = NULL, *dev_array2 = NULL;
	int *dev_cap = NULL, *dev_weight = NULL;
	
	cudaMalloc(&dev_array1, total_weight*sizeof(int) );
	cudaMalloc(&dev_array2, total_weight*sizeof(int) );
	cudaMalloc(&dev_cap, m*sizeof(int) );
	cudaMalloc(&dev_weight, n*m*sizeof(int) );
	cudaMemset(dev_array1, 0, total_weight*sizeof(int));
	cudaMemset(dev_array2, 0, total_weight*sizeof(int));	
	cudaMemcpy(dev_cap, cap, m * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_weight, weight, n * m * sizeof(int), cudaMemcpyHostToDevice);

	gettimeofday(&tbegin, NULL);
	clock_t t = clock();
#ifdef debug
	printArray<<<1,1>>>(dev_array1, dev_array2, dev_cap, dev_weight, m, n, total_weight);
#endif
	for (int k=0; k<n; k++){
		UINT64 idxOffset = MKPoffset(&weight[k*m], cap, m);
#ifdef debug
		cout << "item: " << k << ", idxOffset: " << idxOffset << ", profit: " << profit[k] <<
			", weight: (" << weight[k*m+1] << ", " << weight[k*m] << ")"<< endl;
#endif
		switch(m){	
			case 1: mainIteration1<<<gridSize, blockSize>>>(m, total_weight, blockSize, gridSize, 
						       idxOffset, profit[k], dev_array1, dev_array2, 
						       dev_cap, &dev_weight[k], k);
			break;
			case 2: mainIteration2<<<gridSize, blockSize>>>(m, total_weight, blockSize, gridSize, 
						       idxOffset, profit[k], dev_array1, dev_array2, 
						       dev_cap, &dev_weight[k+k], k);
			break;
			case 3: mainIteration3<<<gridSize, blockSize>>>(m, total_weight, blockSize, gridSize, 
						       idxOffset, profit[k], dev_array1, dev_array2, 
						       dev_cap, &dev_weight[k+k+k], k);
			break;
			case 4: mainIteration4<<<gridSize, blockSize>>>(m, total_weight, blockSize, gridSize, 
						       idxOffset, profit[k], dev_array1, dev_array2, 
						       dev_cap, &dev_weight[k*4], k);
			break;	
			default: mainIteration<<<gridSize, blockSize>>>(m, total_weight, blockSize, gridSize, 
						       idxOffset, profit[k], dev_array1, dev_array2, 
						       dev_cap, &dev_weight[k*m], k);
			break;
		}
		
		cudaDeviceSynchronize();
		int *temp = dev_array1;
		dev_array1 = dev_array2;
		dev_array2 = temp;
	}
	cudaDeviceSynchronize();
	
	gettimeofday(&tend, NULL);
	t = clock() - t;

	double diff = (double)(tend.tv_sec-tbegin.tv_sec) + (double)(tend.tv_usec-tbegin.tv_usec)/1000000.0;	
	cout << "DP iteration on GPU run time: " << diff  << " second," 
		<< " clock ticks: " << t << endl;	
		
	cudaMemcpy(&maxvalue, &dev_array2[total_weight-1], sizeof(int), cudaMemcpyDeviceToHost);
	
	cudaFree(dev_array1);
	cudaFree(dev_array2);
	cudaFree(dev_cap);
	cudaFree(dev_weight);
	
	return maxvalue;
}


