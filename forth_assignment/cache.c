#include <stdlib.h>
#include <stdio.h>
#include "cache.h"

/****************************
 * Roey Derman
 * 322467184
 * forth Exercise
 */


cache_t initialize_cache(uchar s, uchar t, uchar b, uchar E) {
    cache_t first;
    first.s = s;
    first.b = b;
    first.t = t;
    first.E = E;

    int S = 1 << first.s;
    int B = 1 << first.b;

    cache_line_t** array_cache = (cache_line_t**)malloc(S * sizeof(cache_line_t*));

    for (int i = 0; i < S; i++) {
        array_cache[i] = (cache_line_t*)malloc(E * sizeof(cache_line_t));
        for (int j = 0; j < E; j++) {
            array_cache[i][j].valid = 0;
            array_cache[i][j].tag = 0;
            array_cache[i][j].frequency = 0;

            // Allocate memory for the block
            array_cache[i][j].block = (uchar*)malloc(B * sizeof(uchar));
            for (int k = 0; k < B; k++) {
                array_cache[i][j].block[k] = 0;  // Initialize each byte in the block
            }
        }
    }

    first.cache = array_cache;
    return first;
}

uchar read_byte(cache_t cache, uchar* start, long int off){
    int B = 1 << cache.b;
    int flag = 0, min;
    int index_remove = 0;
    int real_offset = off;
    uchar* arr_num = (uchar*)malloc(B);

    // extract the first b bits
    uchar mask_b = (1 << cache.b) - 1;
    uchar extracted_b = off & mask_b;

    // find the first index i need to take from the RAM to fill in all the block in the cache
    for(int i=0; i<B; i++) {
        if(real_offset%B != 0){
            real_offset--;
        }
    }

    // find the number of numbers i need to take from the RAM
    for(int i=0; i<B; i++) {
        arr_num[i] = start[real_offset];
        real_offset++;
    }

    // extract the next s bits
    uchar mask_s = (1 << cache.s) - 1;
    uchar extracted_s = (off >> cache.b) & mask_s;

    // extract the next t bits
    uchar mask_t = (1 << cache.t) - 1;
    uchar extracted_t = (off >> (cache.b + cache.s)) & mask_t;



    for(int i=0; i<cache.E;i++) {
        // check if i find the right line in the cache that i need to update from the RAM,
        // and put the b bytes from the RAM in the cache
        if(cache.cache[extracted_s][i].tag == extracted_t && cache.cache[extracted_s][i].valid == 1) {
            for(int j=0; j<B; j++) {
                cache.cache[extracted_s][i].block[j] = arr_num[j];
            }
            cache.cache[extracted_s][i].tag = extracted_t;
            cache.cache[extracted_s][i].frequency++;
            cache.cache[extracted_s][i].valid = 1;
            index_remove = i;
            flag = 1;
            break;
        }
    }
    if (flag == 0) {
        // i need to check frequency
        min = cache.cache[extracted_s][0].frequency;
        for(int i=1; i<cache.E;i++) {
            if(cache.cache[extracted_s][i].frequency < min) {
                min = cache.cache[extracted_s][i].frequency;
                index_remove = i;
            }
        }
        // take B bytes from the RAM and put in the s set and index row in the cache
        for(int j=0; j<B; j++) {
            cache.cache[extracted_s][index_remove].block[j] = arr_num[j];
        }
        cache.cache[extracted_s][index_remove].tag = extracted_t;
        cache.cache[extracted_s][index_remove].frequency = 1;
        cache.cache[extracted_s][index_remove].valid = 1;
    }
    free(arr_num);
    return cache.cache[extracted_s][index_remove].block[extracted_b];

}

void write_byte(cache_t cache, uchar* start, long int off, uchar new) {
    int flag = 0;

    // extract the first b bits
    uchar mask_b = (1 << cache.b) - 1;
    uchar extracted_b = off & mask_b;

    // extract the next s bits
    uchar mask_s = (1 << cache.s) - 1;
    uchar extracted_s = (off >> cache.b) & mask_s;

    // extract the next t bits
    uchar mask_t = (1 << cache.t) - 1;
    uchar extracted_t = (off >> (cache.b + cache.s)) & mask_t;


    for(int i=0; i<cache.E;i++) {
        // check if i find the right line,
        // and change the byte in the b bit to new char, and change also in the RAM
        if(cache.cache[extracted_s][i].tag == extracted_t && cache.cache[extracted_s][i].valid == 1) {
            // put the new char in the b bit of the s set and the index row
            cache.cache[extracted_s][i].block[extracted_b] = new;
            // put new in the off offset in the RAM
            start[off] = new;
            cache.cache[extracted_s][i].tag = extracted_t;
            cache.cache[extracted_s][i].frequency++;
            cache.cache[extracted_s][i].valid = 1;
            flag = 1;
            break;
        }
    }
    // if the value didn't find in the cache, i just need to update the value in the RAM
    if (flag == 0) {
        start[off] = new;

    }
}


void print_cache(cache_t cache) {
    int S = 1 << cache.s;
    int B = 1 << cache.b;

    for (int i = 0; i < S; i++) {
        printf("Set %d\n", i);
        for (int j = 0; j < cache.E; j++) {
            printf("%1d %d 0x%0*lx ", cache.cache[i][j].valid,
                   cache.cache[i][j].frequency, cache.t, cache.cache[i][j].tag);
            for (int k = 0; k < B; k++) {
                printf("%02x ", cache.cache[i][j].block[k]);
            }
            puts("");
        }
    }

    int E = cache.E;

//    // Free each cache line's block
    for (int i = 0; i < S; i++) {
        for (int j = 0; j < E; j++) {
            free(cache.cache[i][j].block);  // Free the block memory
        }
        free(cache.cache[i]);  // Free the cache line array
    }

    free(cache.cache);  // Finally, free the top-level cache array
}

int main() {
    int n;
    printf("Size of data: ");
    scanf("%d", &n);
    uchar* mem = malloc(n);
    printf("Input data >> ");
    for (int i = 0; i < n; i++)
        scanf("%hhd", mem + i);
    int s, t, b, E;
    printf("s t b E: ");
    scanf("%d %d %d %d", &s, &t, &b, &E);
    cache_t cache = initialize_cache(s, t, b, E);

    while (1) {
        scanf("%d", &n);
        if (n < 0) break;
        read_byte(cache, mem, n);
    }
    puts("");
    print_cache(cache);

    free(mem);
}