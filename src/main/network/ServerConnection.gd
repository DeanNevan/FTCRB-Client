extends Node

signal responsed(response)
signal connected

var reading := false
var expected_length := 0 

var client_id : String = ""
var gate_server_id : String = ""
var connected := false

var logger : Logger = Logger.new("连接", Logger.LOG_LEVEL.DEBUG)

var ip := "192.168.49.1"
var port : int = 8888
var tcp := StreamPeerTCP.new()

var read_mode := 0
var read_bytes : PoolByteArray = PoolByteArray()

var request_id_queue_size = 50
var request_id_queue := []

var request_id2timestamp := {
	
}

var temp_bytes := PoolByteArray()

func _ready() -> void:
	connect("responsed", self, "_on_responsed")
	#var err = connect_to(ip, port)
	#var temp := SCMessage.Request.new()
	#temp.set_type(SCMessage.Type.CONNECT)
	#temp.set_tip(content.to_string())
	#temp.set_client_id("")
	#temp.set_timestamp(OS.get_system_time_msecs())
	#yield(get_tree().create_timer(1), "timeout")
	#send_message_request(temp)

func _process(delta: float) -> void:
	_process_read_tcp()
	pass

func _process_read_tcp():
	if !tcp.is_connected_to_host():
		return
	if read_mode == 0:
		#不在读取数据body且可读byte>0，则读取数据包长度
		if !reading and tcp.get_available_bytes() > 3:
			var temp : Array = tcp.get_data(4)
			expected_length = (
				temp[1][0] * pow(256, 3) + 
				temp[1][1] * pow(256, 2) +
				temp[1][2] * 256 +
				temp[1][3]
			)
			reading = true
		var available_bytes_count = tcp.get_available_bytes()
		if reading and expected_length > 65536:
			var t = tcp.get_data(available_bytes_count)
			temp_bytes.append_array(t[1])
			if temp_bytes.size() >= expected_length:
				var a = RBMessage.Response.new()
				a.from_bytes(temp_bytes)
				#print(a.to_string())
				reading = false
				temp_bytes = PoolByteArray()
				emit_signal("responsed", a)
		
		elif reading and available_bytes_count >= expected_length:
			var temp = tcp.get_data(expected_length)
			var err_code = temp[0]
			var data = temp[1]
			var a = RBMessage.Response.new()
			a.from_bytes(data)
			#print(a.to_string())
			reading = false
			#if request_id2timestamp.has(a.get_request_id()):
			#print(request_id2timestamp.has(a.get_request_id()))
			emit_signal("responsed", a)
		pass

func get_ping() -> int:
	if request_id_queue.size() == 0 or request_id2timestamp.size() == 0:
		return -1
	var temp = request_id_queue[request_id_queue.size() - 1]
	for i in request_id_queue.size():
		var id = temp - i
		var request_timestamp : int = int(request_id2timestamp.get(id).get("request"))
		var response_timestamp : int = int(request_id2timestamp.get(id).get("response"))
		if request_timestamp >= 0 and response_timestamp >= 0:
			return response_timestamp - request_timestamp
	return -1

func connect_to(_ip : String = ip, _port : int = port) -> int:
	ip = _ip
	port = _port
	var err = tcp.connect_to_host(
		_ip,
		_port
	)
	return err

func send_message_request(msg : RBMessage.Request):
	msg.set_clientID(client_id)
	msg.set_timestamp(Global.get_local_timestamp())
	
	var id = -1
	if request_id_queue.size() == 0:
		id = 0
	else:
		id = request_id_queue[request_id_queue.size() - 1] + 1
	if request_id_queue.size() >= request_id_queue_size:
		request_id2timestamp.erase(request_id_queue.pop_front())
	request_id_queue.append(id)
	
	msg.set_request_id(id)
	request_id2timestamp[id] = {
		"request" : -1,
		"response" : -1
	}
	request_id2timestamp[id]["request"] = msg.get_timestamp()
	
	send_packed_bytes(msg.to_bytes())
	pass

func send_packed_bytes(bytes : PoolByteArray) -> int:
	#logger.debug("发送数据 %s" % bytes.get_string_from_utf8())
	#bytes.insert(0, bytes.size())
	bytes.insert(bytes.size(), "$".to_utf8()[0])
	bytes.insert(bytes.size(), "_".to_utf8()[0])
	bytes.insert(bytes.size(), "$".to_utf8()[0])
	if tcp.is_connected_to_host():
		var err = tcp.put_data(bytes)
		return err
	return ERR_CONNECTION_ERROR

func connect_ok(response : RBMessage.Response):
	client_id = response.get_clientID()
	connected = true
	NetworkManagers.all_work()
	emit_signal("connected")

func _on_responsed(response : RBMessage.Response):
	if response.get_type() != RBMessage.Type.HEARTBEAT:
		print(response.to_string())
	
	var req_id = response.get_request_id()
	
	if req_id >= 0:
		if request_id2timestamp.has(req_id):
			request_id2timestamp[req_id]["response"] = OS.get_system_time_msecs()
	
	#logger.debug("接收信息id:" + str(req_id), true)
	
	match response.get_type():
		RBMessage.Type.CONNECT:
			connect_ok(response)


