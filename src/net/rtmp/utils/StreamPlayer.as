package net.rtmp.utils 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.utils.ByteArray;
	import lib3d.Engine3D;
	import lib3d.io.AssetLoader;
	import lib3d.util.OS;
	/**
	 * ...
	 * @author lizhi
	 */
	public class StreamPlayer extends EventDispatcher
	{
		private var n:NetStream;
		public var sound:Video;
		public var loop:int = 0;
		public var counter:int = 0;
		private var closed:Boolean = false;
		private var sndTransform:SoundTransform;
		public function StreamPlayer() 
		{
			var nc:NetConnection = new NetConnection;
			nc.connect(null);
			n = new NetStream(nc);
			n.client = this;
			n.addEventListener(NetStatusEvent.NET_STATUS, n_netStatus);
		}
		
		public function play(url:String, loop:int = 1,sndTransform:SoundTransform=null):void{
			this.sndTransform = sndTransform;
			this.loop = loop;
			counter = 0;
			if (false&&OS.isAIR()){
				closed = false;
				Engine3D.io.loadBin(url, loader_complete,null,null,false,100000);
			}else{
				n.play(url);
				if (sndTransform){
					n.soundTransform = sndTransform;
				}else{
					n.soundTransform = new SoundTransform;
				}
			}
		}
		
		private function loader_complete(loader:AssetLoader):void 
		{
			if(!closed){
				playByteArray(loader.data as ByteArray, loop, sndTransform);
			}
		}
		
		public function playByteArray(by:ByteArray, loop:int = 1, sndTransform:SoundTransform = null):void{
			this.sndTransform = sndTransform;
			this.loop = loop;
			counter = 0;
			n.play(null);
			n.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
			n.appendBytes(by);
			if (sndTransform){
				n.soundTransform = sndTransform;
			}else{
				n.soundTransform = new SoundTransform;
			}
		}
		
		private function n_netStatus(e:NetStatusEvent):void
		{
			trace(JSON.stringify(e.info));
			if (e.info.code == "NetStream.Play.Stop")
			{
				counter++;
				if(loop==0||counter<loop){
					n.seek(0);
				}else{
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}else if (e.info.code=="NetStream.Play.StreamNotFound"){
				//trace("error");
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function onCuePoint(info:Object):void
		{
		}
		
		public function onMetaData(info:Object):void
		{
		}
		
		public function onPlayStatus(info:Object):void
		{
		}
		
		public function close():void{
			closed = true;
			n.close();
		}
	}

}