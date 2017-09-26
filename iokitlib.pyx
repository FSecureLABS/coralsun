cimport cython

from ciokitlib cimport *
from libc.stdlib cimport malloc, free
from libc.string cimport memcpy, memset, strncpy, strlen

import binascii

cdef class iokit:

    def open_service(self,service_name,userclient_type):
        cdef kern_return_t kr = -1
        cdef io_iterator_t iterator = 0
        cdef io_connect_t conn = 0
        cdef io_service_t svc = 0
        cdef CFDictionaryRef matching

        matching = IOServiceMatching(service_name)
        svc = IOServiceGetMatchingService(0,matching)

        print("SVC " + str(svc))

        if (svc == 0):
            print("++ IOServiceGetMatchingService could not find service for %s" % service_name)
            matching = IOServiceNameMatching(service_name)
            svc = IOServiceGetMatchingService(0, matching);

        if (svc == 0):
            # TODO: Try to loop for a partial match
            print("++ Looking for a partial match ++")
            matching = IOServiceMatching("IOService")
            IOServiceGetMatchingServices(0, matching, &iterator)
            svc = IOIteratorNext(iterator);

        kr = IOServiceOpen(svc, mach_task_self(), userclient_type, &conn);
        print("IOServiceOpen kr: %d" % kr)

        IOObjectRelease(svc);
        IOObjectRelease(iterator);
        
        return conn

    def close_service(self,handle):
        cdef kern_return_t kr = -1
        kr = IOServiceClose(handle);
        return kr

    def connect_call_method(self,conn,selector,scalar_input,structInput,scalar_output,struct_output):
        print("Connect call method called")
        cdef uint64_t *input_scalar
        cdef uint32_t input_scalar_size
        cdef uint32_t output_scalar_size
        cdef size_t inputStructCnt
        cdef size_t outputStructCnt
        #cdef bytes input_struct
        #cdef const void *inputStruct
        cdef char *outputStruct
        cdef bytes py_bytes
        cdef kern_return_t kr = -1
        cdef uint64_t *output_scalar
        cdef char* inputStruct

        # Handle the input scalar first. 
        if type(scalar_input) is list:
            print("++ An input list was passed ++") 

            input_scalar_len = len(scalar_input)
            print("input scalar len = %d" % input_scalar_len)

            input_scalar_size = input_scalar_len
            i = 0
            input_scalar = <uint64_t *>malloc(input_scalar_size * sizeof(uint64_t))
            if not input_scalar:
                raise MemoryError()

            # Convert the python array to native. 
            for elem in scalar_input:
                if isinstance(elem, (int, long)):
                    input_scalar[i] = elem
                    i += 1
        else:
            print("++ Scalar input is None or type we cannot convert ++")
            input_scalar = NULL
            input_scalar_size = 0

        # Now handle the input struct types
        if isinstance(structInput, basestring):
            print("A string was passed")
            #hexstr = ':'.join(x.encode('hex') for x in structInput)
            #print(hexstr)

            inputStructCnt = len(structInput)
            print("++ Input struct size = " + str(hex(inputStructCnt)))

            # First convert the python string to char * string to get at raw data
            inputStruct = structInput
        else:
            print("++ Struct input is None or type we cannot convert ++")
            inputStruct = NULL
            inputStructCnt = 0

        # Handle the output scalar here
        if type(scalar_output) is list:
            print("++ An output list was passed ++")
            output_scalar_len = len(scalar_output)
            print("output scalar len = %d" % output_scalar_len)
            output_scalar_size = output_scalar_len

            output_scalar = <uint64_t *>malloc(output_scalar_size * sizeof(uint64_t))
            if not output_scalar:
                raise MemoryError()
        else:
            print("++ Scalar output is None or type we cannot convert ++ ")
            output_scalar = NULL
            output_scalar_size = 0

        # Now handle he output struct. 
        if isinstance(struct_output, basestring):
            print("++ An output string has been passed ++")
            outputStructCnt = len(struct_output)
            print("Output struct cnt = " + str(outputStructCnt))

            # Convert our byte string to char * string to get at raw data. 
            outputStruct = struct_output 
        else:
            print("++ Struct output is None or type we cannot convert ++")
            outputStruct = NULL
            outputStructCnt = 0

        # Finally make the call
        print("%d,%d,%d,%d,%d" % (selector,input_scalar_size,inputStructCnt,output_scalar_size,outputStructCnt))
        kr = IOConnectCallMethod(conn,selector,input_scalar,input_scalar_size,inputStruct,inputStructCnt,output_scalar,&output_scalar_size,outputStruct,&outputStructCnt)

        # Scalar output
        if output_scalar_size:
            print("++ Converting output scalar ++")

        # Struct output
        if outputStructCnt:
            pass

        # Cleanup our temp buffers.
        if input_scalar:
            free(input_scalar)

        if output_scalar:
            free(output_scalar)

        return kr

    def connect_call_async_method(self,conn,selector,scalar_input,structInput,scalar_output,struct_output):
        print("Connect call method called")
        cdef uint64_t *input_scalar
        cdef uint32_t input_scalar_size
        cdef uint32_t output_scalar_size
        cdef size_t inputStructCnt
        cdef size_t outputStructCnt
        #cdef bytes input_struct
        #cdef const void *inputStruct
        cdef char *outputStruct
        cdef bytes py_bytes
        cdef kern_return_t kr = -1
        cdef uint64_t *output_scalar
        cdef char* inputStruct
        cdef mach_port_t wake_port = 0
        cdef uint64_t asyncRef[8]

        # Handle the input scalar first. 
        if type(scalar_input) is list:
            print("++ An input list was passed ++") 

            input_scalar_len = len(scalar_input)
            print("input scalar len = %d" % input_scalar_len)

            input_scalar_size = input_scalar_len
            i = 0
            input_scalar = <uint64_t *>malloc(input_scalar_size * sizeof(uint64_t))
            if not input_scalar:
                raise MemoryError()

            # Convert the python array to native. 
            for elem in scalar_input:
                if isinstance(elem, (int, long)):
                    input_scalar[i] = elem
                    i += 1
        else:
            print("++ Scalar input is None or type we cannot convert ++")
            input_scalar = NULL
            input_scalar_size = 0

        # Now handle the input struct types
        if isinstance(structInput, basestring):
            print("A string was passed")
            #hexstr = ':'.join(x.encode('hex') for x in structInput)
            #print(hexstr)

            inputStructCnt = len(structInput)
            print("++ Input struct size = " + str(hex(inputStructCnt)))

            # First convert the python string to char * string to get at raw data
            inputStruct = structInput
        else:
            print("++ Struct input is None or type we cannot convert ++")
            inputStruct = NULL
            inputStructCnt = 0

        # Handle the output scalar here
        if type(scalar_output) is list:
            print("++ An output list was passed ++")
            output_scalar_len = len(scalar_output)
            print("output scalar len = %d" % output_scalar_len)
            output_scalar_size = output_scalar_len

            output_scalar = <uint64_t *>malloc(output_scalar_size * sizeof(uint64_t))
            if not output_scalar:
                raise MemoryError()
        else:
            print("++ Scalar output is None or type we cannot convert ++ ")
            output_scalar = NULL
            output_scalar_size = 0

        # Now handle he output struct. 
        if isinstance(struct_output, basestring):
            print("++ An output string has been passed ++")
            outputStructCnt = len(struct_output)
            print("Output struct cnt = " + str(outputStructCnt))

            # Convert our byte string to char * string to get at raw data. 
            outputStruct = struct_output 
        else:
            print("++ Struct output is None or type we cannot convert ++")
            outputStruct = NULL
            outputStructCnt = 0

        # Finally make the call
        print("%d,%d,%d,%d,%d" % (selector,input_scalar_size,inputStructCnt,output_scalar_size,outputStructCnt))
        kr = IOConnectCallAsyncMethod(conn,selector,wake_port,asyncRef,8,input_scalar,input_scalar_size,inputStruct,inputStructCnt,output_scalar,&output_scalar_size,outputStruct,&outputStructCnt)

        # Scalar output
        if output_scalar_size:
            print("++ Converting output scalar ++")

        # Struct output
        if outputStructCnt:
            pass

        # Cleanup our temp buffers.
        if input_scalar:
            free(input_scalar)

        if output_scalar:
            free(output_scalar)

        return kr



    def get_port(self,service):
        cdef mach_port_t port
        if service == "TASK_BOOTSTRAP_PORT":    
            return bootstrap_port
        else:
            print("++ Looking up bootstrap service for " + str(service))
            bootstrap_look_up(bootstrap_port, service, &port);
            print("++ Found " + str(port))
            return port

    def map_sharedmemory(self,connect,memoryType,size):
        print("++ Mapping shared memory ++")
        cdef task_port_t intoTask = mach_task_self();
        cdef mach_vm_size_t ofSize = 0; 
        cdef mach_vm_address_t atAddress = 0;
        cdef kern_return_t kr = -1

        ofSize = size;

        kr = IOConnectMapMemory(connect,memoryType,intoTask,&atAddress,&ofSize,0x00000001);
        print("IOConnectMapMemory ret = %d" % kr)
        print("atAddress = 0x%x" % atAddress)

        if (atAddress != 0):
            print("++ mapping ok 0x%x ++" % atAddress)
            # Removed as there are read-only mappings
            # memset(<void*>atAddress,0,ofSize);
        else:
            print("++ mapping failed ++")

        return atAddress

    def map_unmapmemory(self,connect,memoryType,address):
        print("++ Unmapping shared memory ++")
        cdef task_port_t fromTask = mach_task_self();
        cdef mach_vm_address_t atAddress;

        atAddress = address;

        kr = IOConnectUnmapMemory(connect,memoryType,fromTask,atAddress);

        return kr

    def is_memory_writable(self,address):
        cdef vm_size_t vmsize = 0;
        cdef vm_address_t addr;
        cdef vm_region_basic_info_data_t info;
        cdef mach_msg_type_number_t info_count;
        cdef memory_object_name_t object;
        cdef kern_return_t status;
        cdef unsigned char isWritable = 0;
        cdef vm_region_basic_info info_struct; 

        info_count = 9
        addr = address; 

        memset(<void*>&info,0,sizeof(info));
        memset(<void*>&info_struct,0,sizeof(info_struct));

        print("addr = 0x%x" % addr)
        print("vmsize = %d" % vmsize)
        print("info_count = %d" % info_count)
        status = vm_region_64(mach_task_self(),&addr,&vmsize,9,<vm_region_info_t>&info,&info_count,&object);
        print("status = %d" % status)

        info_struct = <vm_region_basic_info>info;

        if (status == 0):
            print("protection = %d" % info_struct.protection)
            print("max protection = %d" % info_struct.max_protection)
            print("user_wired_count = %d" % info_struct.user_wired_count)

            # VM_PROT_WRITE
            isWritable = info_struct.protection & 0x02; 

            if (isWritable):
                print("++ pointer is writable ++")
                return True
            else:
                print("++ pointer is read-only ++")
                return False
        else:
            print("++ memory is not writable ++")
            return False

    def set_sharedmemory(self,address,data,size=4096):
        print("++ Setting shared memory at 0x%x ++" % address)
        cdef char* inputbuf
        cdef mach_vm_address_t atAddress;
        inputbuf = data
        atAddress = address;

        print("++ Setting shared memory size %d ++" % size)
        memcpy(<void *>atAddress,inputbuf,size);

    def dump_sharedmemory(self,address,size):
        print("++ Dumping shared memory at 0x%x of size %d ++" % (address,size))
        cdef unsigned char *tempbuf

        cdef mach_vm_address_t atAddress;
        atAddress = address;

        tempbuf = <unsigned char *>malloc(size);
        memcpy(tempbuf,<void *>atAddress,size);

        pystring = ""

        for i in range(size):
            pystring += chr(tempbuf[i])

        #print(pystring)

        return pystring

    def send_mach_msg(self,service,data):
        print("mach_msg called")
        cdef mach_msg_return_t ret
        cdef mach_msg_header_t* msg
        cdef char* inputdata
        inputdata = data

        # Cast our data to message header struct 
        msg = <mach_msg_header_t*>inputdata

        # Update the local and remote ports to ones within our process. 
        msg.msgh_local_port = 0
        msg.msgh_remote_port = self.get_port(service)
        msg.msgh_bits = 0x131513

        kr = mach_msg_send(msg)

        return kr


    def ioconnect_addclient(self,f,t):
        cdef mach_msg_return_t ret
        ret = IOConnectAddClient(f, t);
        return ret 

    def ioconnect_trap0(self,conn,i):
        cdef mach_msg_return_t ret
        ret = IOConnectTrap0(conn,i);
        return ret

    def ioconnect_trap1(self,conn,i,p):
        cdef mach_msg_return_t ret
        ret = IOConnectTrap1(conn,i,p);
        return ret

    def ioconnect_trap2(self,conn,i,p1,p2):
        cdef mach_msg_return_t ret
        ret = IOConnectTrap2(conn,i,p1,p2);
        return ret

    def ioconnect_trap3(self,conn,i,p1,p2,p3):
        cdef mach_msg_return_t ret
        ret = IOConnectTrap3(conn,i,p1,p2,p3);
        return ret

    def ioconnect_trap4(self,conn,i,p1,p2,p3,p4):
        cdef mach_msg_return_t ret
        ret = IOConnectTrap4(conn,i,p1,p2,p3,p4);
        return ret

    def ioconnect_trap5(self,conn,i,p1,p2,p3,p4,p5):
        cdef mach_msg_return_t ret
        ret = IOConnectTrap5(conn,i,p1,p2,p3,p4,p5);
        return ret

    def ioconnect_trap6(self,conn,i,p1,p2,p3,p4,p5,p6):
        cdef mach_msg_return_t ret
        ret = IOConnectTrap6(conn,i,p1,p2,p3,p4,p5,p6);
        return ret 

    def ioconnect_setnotificationport(self,conn,type,port):
        cdef uintptr_t reference = <uintptr_t>0; 
        ret = IOConnectSetNotificationPort(conn,type,port,reference);
        return ret;

    def ioconnect_getservice(self,conn):
        cdef io_service_t service;
        cdef mach_msg_return_t ret;
        ret = IOConnectGetService(conn, &service);
        return service

    def ioconnect_setproperty(self,conn,key,value):        
        cdef CFStringRef cf_key
        cdef CFTypeRef cf_value

        cf_key = CFStringCreateWithCString(NULL,key,0)
        cf_value = CFStringCreateWithCString(NULL,value,0)

        kr = IOConnectSetCFProperty(conn,cf_key,cf_value)

        if cf_key:
            CFRelease(cf_key)

        if cf_value:
            CFRelease(cf_value)

        return kr

    def ioregistry_setproperty(self,service_name,key,value):
        cdef kern_return_t kr = -1
        cdef io_iterator_t iterator = 0
        cdef io_connect_t conn = 0
        cdef io_service_t svc = 0
        cdef CFDictionaryRef matching        
        cdef CFStringRef cf_key
        cdef CFTypeRef cf_value

        matching = IOServiceMatching(service_name)
        svc = IOServiceGetMatchingService(0,matching)

        print("SVC " + str(svc))

        if (svc == 0):
            print("++ IOServiceGetMatchingService could not find service for %s" % service_name)
            matching = IOServiceNameMatching(service_name)
            svc = IOServiceGetMatchingService(0, matching);

        if (svc == 0):
            # TODO: Try to loop for a partial match
            print("++ Looking for a partial match ++")
            matching = IOServiceMatching("IOService")
            IOServiceGetMatchingServices(0, matching, &iterator)
            svc = IOIteratorNext(iterator);

        cf_key = CFStringCreateWithCString(NULL,key,0)
        cf_value = CFStringCreateWithCString(NULL,value,0)

        kr = IORegistryEntrySetCFProperty(svc,cf_key,cf_value)

        if cf_key:
            CFRelease(cf_key)

        if cf_value:
            CFRelease(cf_value)

        return kr







