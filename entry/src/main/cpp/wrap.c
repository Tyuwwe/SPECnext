#include <stdlib.h>
#include <assert.h>
#include <stdint.h>
// #include <mach/mach.h>
// #include <mach/mach_time.h>
#include <stdio.h>
#include <stdbool.h>

#define HEADER_SIZE sizeof(queue_header_t)
typedef struct queue_header {
#define MAGIC 0xfeedface
    uint32_t magic;
#ifdef DEBUG
    uint32_t debug;
#endif
    struct queue_header *next;
    struct queue_header *prev;
} queue_header_t;
/**
 Layout of the header
 +------------------+ <--- base address
 |    HEADER     |
 |--------------------| <--- start of user memory
 |       USER       |
 |    MEMORY    |
 |                        |
 +------------------+
 */
bool __wrap = true;
// root node never be deleted
queue_header_t *head = NULL, *tail = NULL;
uint64_t __overhead = 0;

// #ifdef __cplusplus
//     #define __real_malloc malloc
//     #define __real_calloc calloc
//     #define __real_realloc realloc
//     #define __real_free free
// #else
//     void* __real_calloc(size_t nmemb, size_t size);
//     void __real_free(void* ptr);
//     void* __real_malloc(size_t size);
//     void* __real_realloc(void* ptr, size_t size);
// #endif
void* __real_calloc(size_t nmemb, size_t size);
void __real_free(void* ptr);
void* __real_malloc(size_t size);
void* __real_realloc(void* ptr, size_t size);

/**
    @param ptr  the pointer point to the header of the allocated block
 */
static void __madd(void *ptr) {
    assert(ptr != head);
    queue_header_t *header = (queue_header_t*)ptr;
    header->next = NULL;
    header->prev = NULL;
    header->magic = MAGIC;
#ifdef DEBUG
    header->debug = 0;
#endif
    
    header->prev = tail->prev; 
    header->next = tail;
    tail->prev->next = header;
    tail->prev = header;
}

/**
    @param ptr pointer point to the header of the allocated block that needs to be deleted.
    O(1) delete.
 */
static int __mdel(void *ptr) {
    assert(ptr != head);
    queue_header_t *header = (queue_header_t*)ptr;
    if(header->magic != MAGIC) return -1;

    // in between
    header->prev->next = header->next;
    header->next->prev = header->prev;

    header->magic = 0xFFFFFFFF;
	 return 0;
}

void *__wrap_malloc(size_t size) {
    if(!__wrap) return __real_malloc(size);
#ifdef DEBUG
    header->debug = header->debug << 3 | 0b001;
#endif
    size += HEADER_SIZE;
	void* ptr = __real_malloc(size);
//     uint64_t start = mach_absolute_time();
    if(ptr == NULL) return NULL;
    queue_header_t *header = (queue_header_t*)ptr;
    __madd(header);
//     uint64_t end = mach_absolute_time();
//     __overhead += end - start;
	return ptr + HEADER_SIZE;
}

void *__wrap_calloc(size_t num, size_t size) {
    if(!__wrap) return __real_calloc(num, size);
#ifdef DEBUG
    header->debug = header->debug << 3 | 0b010;
#endif
    size = (num * size) + HEADER_SIZE;
	void* ptr = __real_calloc(1, size);
//     uint64_t start = mach_absolute_time();
    if(ptr == NULL) return NULL;
    queue_header_t *header = (queue_header_t*)ptr;
    __madd(header);
//     uint64_t end = mach_absolute_time();
//     __overhead += end - start;
    return ptr + HEADER_SIZE;
}


/**
 old_base    new_size
 NULL         X                  =  alocate a new block, equivalent to malloc(new_size)
 X                NULL           =  not allow
 X                X                 =   {
                        1. extend block
                        2. malloc new block malloc(new_size) copy from old block to new block, free old block
                    }
 */

void *__wrap_realloc (void *old_base, size_t new_size) {
    if(!__wrap) return __real_realloc(old_base, new_size);
    assert(new_size != 0); // Implemation define

    new_size += HEADER_SIZE;
    old_base = old_base ? (old_base - HEADER_SIZE) : NULL;
    void *ptr = __real_realloc(old_base, new_size);
    if(ptr == NULL) return NULL;
    
//     uint64_t start = mach_absolute_time();
    if(old_base == NULL) {
        // same as malloc(new_size)
        queue_header_t *header = (queue_header_t*)ptr;
        __madd(header);
#ifdef DEBUG
        header->debug = header->debug << 3 | 0b101;
#endif
    } else if(ptr != old_base) {
        // we need to update the reference since the base had changed
        queue_header_t *header = (queue_header_t*)ptr;
        assert(header->magic == MAGIC);
        header->prev->next = header;
        header->next->prev = header;
#ifdef DEBUG
        header->debug = header->debug << 3 | 0b110;
#endif
    }
    else {
        // else jsut extended the block, no need to change
        queue_header_t *header = (queue_header_t*)ptr;
#ifdef DEBUG
        header->debug = header->debug << 3 | 0b111;
#endif
    }
//     uint64_t end = mach_absolute_time();
//     __overhead += end - start;
	return ptr + HEADER_SIZE;
}

void __wrap_free(void *ptr) {
    if(!__wrap) return __real_free(ptr);
//     uint64_t start = mach_absolute_time();
    if(ptr == NULL) return;
    queue_header_t *header = (queue_header_t*)(ptr - HEADER_SIZE);
    int ret = __mdel(header);
//     uint64_t end = mach_absolute_time();
//     __overhead += end - start;
    if(ret == -1) return;
    __real_free(header);
}

void __freelist() {
    queue_header_t *block = head->next;
    queue_header_t *tmp;
    while(block != tail) {
        tmp = block->next;
        __real_free(block);
        block = tmp;
    }
    
    __real_free(head);
    __real_free(tail);
}

void __init() {
    head = (queue_header_t*)__real_malloc(HEADER_SIZE);
    tail = (queue_header_t*)__real_malloc(HEADER_SIZE);
    
    head->next = tail;
    head->prev = tail;
    tail->next = head;
    tail->prev = head;
    __overhead = 0;
}
