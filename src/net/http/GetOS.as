package net.http 
{
	import debug.Log;
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.StageWebView;
	import flash.net.ServerSocket;
	//import flash.events.ServerSocketConnectEvent;
	//import flash.net.ServerSocket;
	import lib3d.air.AIRUtils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GetOS extends EventDispatcher
	{
		public static var AndroidVersion:Number = 0;
		private static var ss:Object;
		private var headerOBj:Object;
		private var sv:Object;
		private var stage:Stage;
		private var errorCounter:int = 0;
		public function GetOS(stage:Stage) 
		{
			this.stage = stage;
		}
		
		public function start():void{
			try{
			ss =new ServerSocket //AIRUtils.newServerSocket();
			ss.addEventListener("connect"/*ServerSocketConnectEvent.CONNECT*/, ss_connect);
			ss.addEventListener(Event.CLOSE, ss_close);
			ss.bind(13249);
			ss.listen();
			sv =new StageWebView(true)//AIRUtils.newStageWebView(true);
			sv.addEventListener(ErrorEvent.ERROR, sv_error);
			sv.loadURL("http://127.0.0.1:13249");
			sv.stage = stage;
			}catch (err:Error){
				trace(err);
			}
		}
		
		private function sv_error(e:ErrorEvent):void 
		{
			if(headerOBj==null){
			errorCounter++;
			trace(e);
			if (errorCounter > 10){
				dispatchEvent(new Event(Event.CLOSE));
			}else{
				sv.loadURL("http://127.0.0.1:13249");
			}
			}
		}
		
		private function ss_close(e:Event):void 
		{
			dispatchEvent(e);
			sv.stage = null;
		}
		
		private function ss_connect(e:Object):void 
		{
			var p:HTTPParser = new HTTPParser(e.socket);
			p.addEventListener(Event.CHANGE, p_change);
		}
		
		private function p_change(e:Event):void 
		{
			var p:HTTPParser = e.currentTarget as HTTPParser;
			if (p.headerOver){
				headerOBj = p.headerObj;
				ss.close();
				sv.stage = null;
				AndroidVersion = androidVersion;
				Log.warn(p.header);
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function get androidVersion():Number{
			if (headerOBj==null){
				return 0;
			}
			var ua:String = headerOBj["User-Agent"];
			if (ua==null){
				return 0;
			}
			var reg:RegExp =/Android (.+?)[;)]/;
			var obj:Object = reg.exec(ua);
			if (obj==null){
				return 0;
			}
			if (obj[1]){
				var arr:Array = obj[1].split(".");
				return Number(arr[0]);
			}
			return 0;
		}
	}

}