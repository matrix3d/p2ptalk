package net.rtmp.utils 
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.H264Level;
	import flash.media.H264Profile;
	import flash.media.H264VideoStreamSettings;
	import flash.media.Microphone;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import net.rtmp.events.StreamEvent;
	import net.rtmp.net.Server;
	import net.rtmp.net.stream.Stream;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Recorder extends EventDispatcher
	{
		private var nss:Array = [];
		private var waitingName:String;
		public var microphone:Microphone;
		public var camera:Camera;
		private var netConnect:NetConnection;
		private static var _instance:Recorder;
		public function Recorder() 
		{
			if (_instance!=null){
				throw "这是单例类";
				return;
			}
			
			Server.getInstance().listen("127.0.0.1", 1935);
			Stream.isToMem = true;
			Stream.getInstance().addEventListener(StreamEvent.CLOSE_RECORD_STREAM, closeRecordStream);
			
			netConnect = new NetConnection;
			netConnect.client = this;
			netConnect.addEventListener(NetStatusEvent.NET_STATUS, c_netStatus);
			netConnect.connect("rtmp://127.0.0.1:1935/app");
		}
		
		public static function get instance():Recorder{
			if (_instance==null){
				_instance = new Recorder;
			}
			return _instance;
		}
		
		public function publish(name:String):void{
			waitingName = name;
			if (nss.length==0&&netConnect.connected){
				onPublish();
			}else{
				stop();
			}
		}
		
		public function stop():void{
			for each(var nc:NetStream in nss){
				nc.close();
			}
			nss = [];
		}
		
		private function closeRecordStream(e:StreamEvent):void 
		{
			dispatchEvent(e);
			if (waitingName){
				onPublish();
			}
		}
		
		private function c_netStatus(e:NetStatusEvent):void 
		{
			trace(JSON.stringify(e.info));
			if (e.info.code == "NetConnection.Connect.Success"){
				if (waitingName){
					onPublish();
				}
			}
		}
		
		private function onPublish():void 
		{
			var h264:H264VideoStreamSettings = new H264VideoStreamSettings();
			h264.setMode(320, 240, 30);
			h264.setQuality(0, 90);
			h264.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_5_1);
			var ns:NetStream = new NetStream(netConnect);
			nss.push(ns);
			ns.videoStreamSettings = h264;
			ns.attachAudio(microphone);
			ns.attachCamera(camera);
			ns.publish(waitingName, "record");
			waitingName = null;
		}
		
		public function onUserAdded(id:String):void
		{
			trace("客户端加入(Client userAdded): " + id);
		}
		
		public function onUserRemoved(id:String):void
		{
			trace("客户端离开(Client userRemoved): " + id);
		}
		
	}

}