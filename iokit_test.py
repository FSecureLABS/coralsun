
import iokitlib
import unittest
import binascii

class IOKitTest(unittest.TestCase):

	def test_open_service_valid(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("IOHIDSystem",1)
		self.assertNotEqual(h, 0)
	
	def test_open_service_failed(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("blah",0)
		self.assertEqual(h, 0)

	def test_connect_call_method_scalar_noinput_structoutput_valid(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("IOSurfaceRoot",0)

		input_scalar = None
		input_struct = None
		
		output_scalar = None
		output_struct = b"0" * 20 # 20 bytes output

		selector = 0x0d

		kr = iokit.connect_call_method(h,selector,input_scalar,input_struct,output_scalar,output_struct)

		self.assertEqual(kr,0)

		print("Output struct = ")
		hexstr = ':'.join(x.encode('hex') for x in output_struct)
		print(hexstr)
		#print("test_connect_call_method_scalar_valid %d " % kr)

	@unittest.skip("Gen6Accelerator is not available on 10.12.3")
	def test_connect_call_method_scalar_input_structoutput_valid(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("Gen6Accelerator",1)

		input_scalar = [0] 			# One element
		input_struct = None

		output_scalar = None
		output_struct = b"\x00" * 28

		selector = 0x10

		kr = iokit.connect_call_method(h,selector,input_scalar,input_struct,output_scalar,output_struct)
		self.assertEqual(kr,0)	

		# Print the output
		print("Output struct = ")
		hexstr = ':'.join(x.encode('hex') for x in output_struct)
		print(hexstr)

	def test_connect_call_method_struct_input_struct_output(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("IntelAccelerator",5)	

		input_scalar = None

		input_struct = binascii.unhexlify("3f0000000100000000000000000000000000000000000000")
		print(input_struct)

		output_scalar = None
		output_struct = binascii.unhexlify("3f0000000100000000000000000000000000000000000000")

		selector = 11

		kr = iokit.connect_call_method(h,selector,input_scalar,input_struct,output_scalar,output_struct)
		self.assertEqual(kr,0)

		# Print the output
		print("Output struct = ")
		hexstr = ':'.join(x.encode('hex') for x in output_struct)
		print(hexstr)


	def test_connect_call_method_struct_input_struct_output(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("IntelAccelerator",5)	

		input_scalar = None

		input_struct = binascii.unhexlify("3f0000000100000000000000000000000000000000000000")
		print(input_struct)

		output_scalar = None
		output_struct = binascii.unhexlify("3f0000000100000000000000000000000000000000000000")

		selector = 11

		print("++ making async call ++")
		kr = iokit.connect_call_async_method(h,selector,input_scalar,input_struct,output_scalar,output_struct)
		self.assertEqual(kr,0)

		# Print the output
		print("Output struct = ")
		hexstr = ':'.join(x.encode('hex') for x in output_struct)
		print(hexstr)

	def test_mach_msg_send_valid_bootstrap(self):
		iokit = iokitlib.iokit()
		data = binascii.unhexlify("13151300d000000007080000031f0000030c000000000010214350580500000000f00000a80000000700000073756273797374656d00000000400000030000000000000068616e646c650000004000000000000000000000726f7574696e6500004000002403000000000000666c6167730000000040000000000000000000006e616d65000000000090000010000000636f6d2e6170706c652e666f6e74730074797065000000000040000007000000000000006c6f6f6b75702d68616e646c65000000004000000000000000000000")
		service = "TASK_BOOTSTRAP_PORT"

		ret = iokit.send_mach_msg(service,data)
		print(ret)

		self.assertEqual(ret,0)

	def test_send_coreserviced(self):
		iokit = iokitlib.iokit()
		data = binascii.unhexlify("13151300010000000b4b000007070000030c000023270000000000000100000001000000435353656564000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100010001000000")
		service = "com.apple.CoreServices.coreservicesd"

		ret = iokit.send_mach_msg(service,data)
		print(ret)	

		#self.assertEqual(ret,0)	

	def test_send_audiohald(self):
		iokit = iokitlib.iokit()
		data = binascii.unhexlify("13151300380000000379000007070000030c000063690f00000000000100000001000000236b6c63626f6c6700000000")
		service = "com.apple.audio.audiohald"

		ret = iokit.send_mach_msg(service,data)
		print(ret)	

		self.assertEqual(ret,0)


	def test_mapsharedmemory_ok(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("IOFramebuffer",1)

		print("connect shared memory handle: " + str(h))
		self.assertNotEqual(h, 0)

		# This call returns back the memory address mapped. 
		kr = iokit.map_sharedmemory(h,110,4096)
		print("sharedmemory: " + str(hex(kr)))

		self.assertNotEqual(kr,0)

	def test_mapsharedmemory_fail(self):
		iokit = iokitlib.iokit()

		h = iokit.open_service("IOAccelerator",1)

		print("connect shared memory handle: " + str(h))
		self.assertNotEqual(h, 0)

		# This call should fail and therefore the address should be zero. 
		kr = iokit.map_sharedmemory(h,110,4096)
		print("sharedmemory: " + str(hex(kr)))

		self.assertEqual(kr,0)

	def test_mapsharedmemorydump_ok(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("IOFramebuffer",1)

		print("connect shared memory handle: " + str(h))
		self.assertNotEqual(h, 0)

		# This call returns back the memory address mapped. 
		kr = iokit.map_sharedmemory(h,110,4096)

		iokit.set_sharedmemory(kr,"BBBBB")

		memory = iokit.dump_sharedmemory(kr,4096)	

		print(binascii.hexlify(memory))
			

	def test_ioconnect_setproperty_ok(self):
		iokit = iokitlib.iokit()

		h = iokit.open_service("IOPMrootDomain",0)
		self.assertNotEqual(h, 0)

		kr = iokit.ioconnect_setproperty(h,"Hibernate File","TEST")

		print("ioconnect_setproperty ret = %d" % kr)

		#self.assertEqual(kr,0)

	def test_ioregistry_setproperty(self):
		iokit = iokitlib.iokit()

		kr = iokit.ioregistry_setproperty("IOPMrootDomain","Hibernate File","TEST")

		print("ioconnect_setproperty ret = %d" % kr)

		self.assertEqual(kr,0)

	""" This should test writing to a shared memory map """
	def test_writable_mapping(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("IOFramebuffer",1)
		kr = iokit.map_sharedmemory(h,110,4096)
		if kr == 0:
			print("++ mapping failed ++")
		else:

			writable = iokit.is_memory_writable(kr)
			if writable:
				iokit.set_sharedmemory(kr,"BBBBB")
			memory = iokit.dump_sharedmemory(kr,4096)
			print(binascii.hexlify(memory))

	""" 
	This should test writing to a read only memory map 
	The writable test should failt, otherwise we could cause a segfault. 
	"""
	def test_readonly_mapping(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("IOFramebuffer",1)
		kr = iokit.map_sharedmemory(h,100,4096)
		if kr == 0:
			print("++ mapping failed ++")
		else:
			writable = iokit.is_memory_writable(kr)
			if writable:
				iokit.set_sharedmemory(kr,"BBBBB")
			memory = iokit.dump_sharedmemory(kr,4096)
			print(binascii.hexlify(memory))

	"""
	Determine if a memory page is writable 
	"""
	def test_writable_memory(self):
		iokit = iokitlib.iokit()
		iokit.is_memory_writable(0xffffffff)			

	""" Try set the notification port for a service """
	def test_set_notification_port(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("IOFramebuffer",1)
		t = 1
		kr = iokit.ioconnect_setnotificationport(h,t,1)
		print("++ set notification port %d ++" % kr)

	""" Try get the ioservice a connect handle was opened on """
	def test_get_service(self):
		iokit = iokitlib.iokit()
		h = iokit.open_service("IOFramebuffer",1)
		kr = iokit.ioconnect_getservice(h)
		print("++ get_service: %d ++" % kr)

if __name__ == '__main__':
    unittest.main()