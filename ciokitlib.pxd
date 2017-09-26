
cdef extern from "mach/vm_region.h" nogil:
    ctypedef void *vm_region_info_t;

cdef extern from "mach/mach.h" nogil:
    ctypedef int boolean_t
    ctypedef int mach_msg_return_t
    ctypedef int mach_msg_option_t
    ctypedef int mach_msg_size_t
    ctypedef int mach_msg_timeout_t
    ctypedef int mach_msg_bits_t
    ctypedef int mach_port_seqno_t
    ctypedef int mach_msg_id_t
    ctypedef int mach_port_t
    ctypedef int mach_port_name_t
    ctypedef int mach_port_right_t
    ctypedef int mach_msg_trailer_type_t
    ctypedef int mach_msg_trailer_size_t
    ctypedef int kern_return_t
    ctypedef int ipc_space_t
    ctypedef int mach_msg_type_name_t
    ctypedef int mach_msg_copy_options_t
    ctypedef int mach_msg_descriptor_type_t
    ctypedef int mach_msg_type_number_t
    ctypedef unsigned int * uintptr_t;

    ctypedef unsigned long mach_vm_address_t; 
    ctypedef unsigned long mach_vm_size_t;
    ctypedef unsigned long vm_size_t;
    ctypedef unsigned long vm_address_t;

    ctypedef mach_port_t vm_map_t;
    ctypedef int vm_region_flavor_t;

    ctypedef mach_port_t memory_object_name_t;

    ctypedef struct mach_msg_header_t:
        mach_msg_bits_t msgh_bits
        mach_msg_size_t msgh_size
        mach_port_t msgh_remote_port
        mach_port_t msgh_local_port
        mach_port_name_t msgh_voucher_port
        mach_msg_id_t msgh_id

    mach_msg_return_t mach_msg(mach_msg_header_t *msg, mach_msg_option_t option, mach_msg_size_t send_size,
                               mach_msg_size_t rcv_size, mach_port_t rcv_name, mach_msg_timeout_t timeout,
                               mach_port_t notify)

    mach_msg_return_t mach_msg_send(mach_msg_header_t *msg)

    kern_return_t vm_region_64(vm_map_t target_task, vm_address_t *address, vm_size_t *size, vm_region_flavor_t flavor, vm_region_info_t info, mach_msg_type_number_t *infoCnt, mach_port_t *object_name);

cdef extern from "mach/task.h" nogil:
    ctypedef unsigned int uint32_t
    ctypedef unsigned long uint64_t
    ctypedef int int_32_t
    ctypedef uint32_t natural_t
    ctypedef int_32_t integer_t
    ctypedef mach_port_t task_t
    ctypedef mach_port_t task_port_t

cdef extern from "IOKit/IOTypes.h" nogil:
    ctypedef mach_port_t io_object_t
    ctypedef io_object_t io_service_t
    ctypedef io_object_t io_connect_t
    ctypedef io_object_t io_enumerator_t
    ctypedef io_object_t io_iterator_t
    ctypedef io_object_t io_registry_entry_t
    ctypedef uint32_t IOOptionBits; 

cdef extern from "CoreFoundation/CFDictionary.h" nogil:
    ctypedef void* CFDictionaryRef
    ctypedef void* CFMutableDictionaryRef 

cdef extern from "CoreFoundation/CFString.h" nogil:
    ctypedef void* CFStringRef

cdef extern from "CoreFoundation/CoreFoundation.h" nogil:
    ctypedef void* CFTypeRef
    ctypedef void* CFAllocatorRef
    ctypedef unsigned int CFStringEncoding
    cdef void CFRelease(void * cf)
    cdef CFStringRef CFStringCreateWithCString(CFAllocatorRef alloc, char *cStr, CFStringEncoding encoding)

cdef extern from "mach/mach_init.h" nogil:
    mach_port_t mach_task_self()
    mach_port_t mach_thread_self()

cdef extern from "IOKit/IOKitLib.h" nogil:
  kern_return_t IOServiceOpen(io_service_t    service, task_port_t	owningTask, uint32_t	type, io_connect_t  *	connect )
  io_service_t IOServiceGetMatchingService(mach_port_t masterPort, CFDictionaryRef matching);
  kern_return_t IOServiceGetMatchingServices(mach_port_t masterPort, CFDictionaryRef matching, io_iterator_t *existing)
  CFMutableDictionaryRef IOServiceNameMatching(const char *name)
  CFMutableDictionaryRef IOServiceMatching(const char *name)
  io_object_t IOIteratorNext(io_iterator_t iterator)
  kern_return_t IOObjectRelease(io_object_t object)
  kern_return_t IOConnectCallMethod(mach_port_t connection, uint32_t selector, const uint64_t *input, uint32_t inputCnt, const void *inputStruct, size_t inputStructCnt, uint64_t *output, uint32_t *outputCnt, void *outputStruct, size_t *outputStructCnt);
  kern_return_t IOServiceClose(io_connect_t connect);
  kern_return_t IOConnectMapMemory(io_connect_t connect, uint32_t memoryType, task_port_t intoTask, mach_vm_address_t *atAddress, mach_vm_size_t *ofSize, IOOptionBits options);
  kern_return_t IOConnectUnmapMemory(io_connect_t connect, uint32_t memoryType, task_port_t fromTask, mach_vm_address_t atAddress);
  kern_return_t IOConnectAddClient(io_connect_t connect, io_connect_t client);
  kern_return_t IOConnectSetCFProperty(io_connect_t connect, CFStringRef propertyName, CFTypeRef property);
  kern_return_t IORegistryEntrySetCFProperty(io_registry_entry_t entry, CFStringRef propertyName, CFTypeRef property);
  kern_return_t IOConnectTrap0(io_connect_t connect, uint32_t index);
  kern_return_t IOConnectTrap1(io_connect_t connect, uint32_t index, uint32_t p1);
  kern_return_t IOConnectTrap2(io_connect_t connect, uint32_t index, uint32_t p1, uint32_t p2);
  kern_return_t IOConnectTrap3(io_connect_t connect, uint32_t index, uint32_t p1, uint32_t p2, uint32_t p3);
  kern_return_t IOConnectTrap4(io_connect_t connect, uint32_t index, uint32_t p1, uint32_t p2, uint32_t p3, uint32_t p4);
  kern_return_t IOConnectTrap5(io_connect_t connect, uint32_t index, uint32_t p1, uint32_t p2, uint32_t p3, uint32_t p4, uint32_t p5);
  kern_return_t IOConnectTrap6(io_connect_t connect, uint32_t index, uint32_t p1, uint32_t p2, uint32_t p3, uint32_t p4, uint32_t p5, uint32_t p6);
  kern_return_t IOConnectSetNotificationPort(io_connect_t connect, uint32_t type, mach_port_t port, uintptr_t reference);
  kern_return_t IOConnectGetService(io_connect_t connect, io_service_t *service);
  kern_return_t IOConnectCallAsyncMethod(mach_port_t connection, uint32_t selector, mach_port_t wake_port, uint64_t *reference, uint32_t referenceCnt, const uint64_t *input, uint32_t inputCnt, const void *inputStruct, size_t inputStructCnt, uint64_t *output, uint32_t *outputCnt, void *outputStruct, size_t *outputStructCnt);

cdef extern from "servers/bootstrap.h" nogil:
    mach_port_t bootstrap_port
    kern_return_t bootstrap_look_up(mach_port_t bp, const char * service_name, mach_port_t *sp)

cdef extern from "mach/vm_prot.h" nogil:
    ctypedef int vm_prot_t;

cdef extern from "mach/vm_inherit.h" nogil:
    ctypedef unsigned int vm_inherit_t;

cdef extern from "mach/vm_behavior.h" nogil:
    ctypedef int vm_behavior_t;

cdef extern from "mach/vm_region.h" nogil:
    cdef struct vm_region_basic_info:
      vm_prot_t protection;
      vm_prot_t max_protection;
      vm_inherit_t inheritance;
      boolean_t shared;
      boolean_t reserved;
      unsigned int offset;
      vm_behavior_t behavior;
      unsigned short user_wired_count;

    ctypedef void* vm_region_basic_info_t;
    ctypedef void* vm_region_basic_info_data_t;
    ctypedef vm_region_basic_info_data_t vm_region_info_t


