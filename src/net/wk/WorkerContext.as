package net.wk 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setInterval;
	import lib3d.io.FileStreamUrlLoader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class WorkerContext extends EventDispatcher
	{
		public static var LOAD:int = 1;
		public static var FILE_LOAD:int = 2;
		public static var CLOSE_LOAD:int = 3;
		
		public static var instance:WorkerContext;
		public static var ID:int = 0;
		private static var base2id:Dictionary = new Dictionary(true);
		private static var id2base:Object = {};
		private static var id2funs:Object = {};
		public var worker:Worker;
		public var m2w:MessageChannel;
		public var w2m:MessageChannel;
		public function WorkerContext(bytes:ByteArray) 
		{
			return;
			if (instance){
				return;
			}
			instance = this;
			if (Worker.current.isPrimordial){
				worker = WorkerDomain.current.createWorker(bytes,true);
				m2w = Worker.current.createMessageChannel(worker);
				w2m = worker.createMessageChannel(Worker.current);
				w2m.addEventListener(Event.CHANNEL_MESSAGE, w2m_channelMessage);
				worker.setSharedProperty("m2w", m2w);
				worker.setSharedProperty("w2m", w2m);
				worker.setSharedProperty("applicationStorageDirectory", File.applicationStorageDirectory.nativePath);
				worker.start();
				//setInterval(function():void{m2w.send(Math.random())}, 1000);
			}else{
				m2w = Worker.current.getSharedProperty("m2w");
				w2m = Worker.current.getSharedProperty("w2m");
				//setInterval(function():void{w2m.send(Math.random())}, 1000);
				m2w.addEventListener(Event.CHANNEL_MESSAGE, m2w_channelMessage);
			}
		}
		
		private function w2m_channelMessage(e:Event):void 
		{
			var t:Array = w2m.receive() as Array;
			if (t){
				var id:int = t.shift();
				var funs:Array = id2funs[id];
				if (funs){
					var fid:int = t.shift();
					var fun:Function = funs[fid];
					if (fun!=null){
						fun.apply(null, t);
					}
				}
			}
		}
		
		private function m2w_channelMessage(e:Event):void 
		{
			var obj:Array = m2w.receive() as Array;
			if (obj){
				var id:int = obj[0];
				var key:int = obj[1];
				
				switch(key){
					case LOAD:
					case FILE_LOAD:
						var url:String = obj[2];
						var isProg:Boolean = obj[3];
						var inflateNotOBJ:Boolean = obj[4];
						var loader:URLLoader = key == LOAD?(new URLLoader):(new FileStreamUrlLoader);
						if (key==FILE_LOAD){
							(loader as FileStreamUrlLoader).inflateNotOBJ = inflateNotOBJ;
						}
						loader.dataFormat = URLLoaderDataFormat.BINARY;
						base2id[loader] = id;
						id2base[id] = loader;
						loader.addEventListener(Event.COMPLETE, loader_complete);
						loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
						if (isProg){
							loader.addEventListener(ProgressEvent.PROGRESS, loader_progress);
						}
						loader.load(new URLRequest(url));
						break;
					case CLOSE_LOAD:
						loader = id2base[id] as URLLoader;
						if (loader){
							try{
								base2id[loader] = null;
								delete base2id[loader];
								id2base[id] = null;
								delete id2base[id];
								loader.data = null;
								loader.close();
							}catch (err:Error){
								
							}
						}
						break;
				}
			}
		}
		
		private function loader_progress(e:ProgressEvent):void 
		{
			var id:int = base2id[e.currentTarget];
			w2m.send([id,2,e.bytesLoaded,e.bytesTotal]);
		}
		
		private function loader_ioError(e:IOErrorEvent):void 
		{
			var id:int = base2id[e.currentTarget];
			var target:URLLoader = e.currentTarget as URLLoader;
			
			target.data = null;
			w2m.send([id, 1]);
			
			base2id[e.currentTarget] = null;
			delete base2id[e.currentTarget];
			id2base[id] = null;
			delete id2base[id];
		}
		
		private function loader_complete(e:Event):void 
		{
			var id:int = base2id[e.currentTarget];
			var target:URLLoader = e.currentTarget as URLLoader;
			var byte:ByteArray = target.data as ByteArray;
			//byte = new ByteArray;
			//byte.length = 1024 * 1024 * 100;
			//byte.shareable = true;
			//var bid:int = ID++;
			//trace(bid);
			//Worker.current.setSharedProperty(bid + "", byte);
			//Worker.current.setSharedProperty(bid + "", new by);
			w2m.send([id, 0,/*bid,*/ byte]);
			base2id[e.currentTarget] = null;
			delete base2id[e.currentTarget];
			id2base[id] = null;
			delete id2base[id];
			
			try{
				target.data = null;
				target.close();
			}catch (err:Error){
				
			}
		}
		
		public function load(id:int,url:String, oncomp:Function, onerror:Function, onProgress:Function,inflateNotOBJ:Boolean):void{
			id2funs[id] = [oncomp,onerror,onProgress];
			m2w.send([id, LOAD, url,onProgress!=null,inflateNotOBJ]);
		}
		
		public function fileload(id:int,url:String, oncomp:Function, onerror:Function, onProgress:Function,inflateNotOBJ:Boolean):void{
			id2funs[id] = [oncomp,onerror,onProgress];
			m2w.send([id, FILE_LOAD, url,onProgress!=null,inflateNotOBJ]);
		}
		
		public function closeLoad(id:int):void{
			id2funs[id] = null;
			delete id2funs[id];
			m2w.send([id, CLOSE_LOAD]);
		}
	}

}