package net.http 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author lizhi
	 */
	public class HTTPServer extends EventDispatcher
	{
		private static var servermap:Array = [];
		private var ss:ServerSocket;
		public var webroot:File;
		public var mimeTypes:Object = {};
		private var fs2Response:Dictionary = new Dictionary;
		public function HTTPServer() 
		{
			mimeTypes[".txt"]   = "text/plain";
			mimeTypes[".css"]   = "text/css";
			mimeTypes[".htm"]   = "text/html";
			mimeTypes[".html"]  = "text/html";
			mimeTypes[".ico"]   = "image/x-icon";
			mimeTypes[".jpg"]   = "image/jpeg";
			mimeTypes[".png"]   = "image/png";
			mimeTypes[".gif"]   = "image/gif";
			mimeTypes[".js"]    = "application/x-javascript";
			mimeTypes[".*"]   = "application/octet-stream";
		}
		
		public function start(port:int, webroot:File):void{
			//port = 13249;
			this.webroot = webroot;
			try{
				ss = new ServerSocket;
				servermap.push(ss);
				ss.addEventListener(ServerSocketConnectEvent.CONNECT, ss_connect);
				ss.addEventListener(Event.CLOSE, ss_close);
				ss.bind(port);
				ss.listen();
			}catch (err:Error){
				trace(port);
				trace(err);
			}
		}
		
		private function ss_close(e:Event):void 
		{
			dispatchEvent(e);
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
				var response:HTTPResponse = new HTTPResponse(p.socket);
				var path:String = p.headerObj.GET;
				if (path != null){
					path = decodeURIComponent(path);
					var li:int = path.indexOf("?");
					if (li!=-1){
						path = path.substring(0, li);
					}
					li = path.indexOf(".");
					if (li!=-1){
						var ext:String = path.substr(li);
					}else{
						ext = path;
					}
					li = ext.indexOf("?");
					if (li!=-1){
						ext = ext.substring(0, li);
					}
					var file:File = webroot.resolvePath(path.substr(1));
					if (file.exists&&file.isDirectory){
						var indexfile:File = file.resolvePath("index.html");
						if (indexfile.exists){
							file = indexfile;
							ext = ".html";
						}
					}
					if (file.exists){
						if(!file.isDirectory){
							var type:String = mimeTypes[ext] || mimeTypes[".*"];
							response.writeHead(200, type, file.size);
							p.socket.flush();
							
							var fs:FileStream = new FileStream;
							fs.addEventListener(IOErrorEvent.IO_ERROR, fs_ioError);
							fs.addEventListener(Event.COMPLETE, fs_complete);
							fs.addEventListener(ProgressEvent.PROGRESS, fs_progress);
							fs2Response[fs] = response
							fs.openAsync(file, FileMode.READ);
						}else{
							var html:String = 
							"<!DOCTYPE html>"+
							"<html lang=\"en\">"+
							"<head>"+
								"<meta charset=\"utf-8\">"+
								"<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">"+
								"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, user-scalable=no\">"+
							"</head>" +
							"<body>";	
							for each(var sf:File in file.getDirectoryListing()){
								html+="<a href='"+path+"/"+sf.name+"'>"+sf.name+"</a><br/>"
							}
							html+="</body>"+
							"</html>";
							response.writeTxt(html, 200, "text/html;");
							p.socket.flush();
							p.socket.close();
						}
					}else{
						response.writeTxt("404", 404, "text/html;");
						p.socket.flush();
						p.socket.close();
					}
				}else{
					response.writeTxt("404", 404, "text/html;");
					p.socket.flush();
					p.socket.close();
				}
			}
		}
		
		private function fs_progress(e:Event):void 
		{
			//var fs:FileStream = e.currentTarget as FileStream;
			//var response:HTTPResponse = fs2Response[fs] as HTTPResponse;
			//if (fs.bytesAvailable){
			//response.output.writeInt(fs.bytesAvailable);
			//var newbyte:ByteArray = new ByteArray;
			//fs.readBytes(newbyte, 0, fs.bytesAvailable);
			//response.output.writeBytes(newbyte,0,newbyte.length);// .writeByte(fs.readByte());
			//}
			//(response.output as Socket).flush();
		}
		
		private function fs_complete(e:Event):void 
		{
			//fs_progress(e);
			var fs:FileStream = e.currentTarget as FileStream;
			var response:HTTPResponse = fs2Response[fs] as HTTPResponse;
			
			//if()
			var newbyte:ByteArray = new ByteArray;
			fs.readBytes(newbyte, 0, fs.bytesAvailable);
			response.output.writeBytes(newbyte,0,newbyte.length);// .writeByte(fs.readByte());
			//response.output.writeInt(0);
			
			(response.output as Socket).flush();
			(response.output as Socket).close();
		}
		
		private function fs_ioError(e:IOErrorEvent):void 
		{
			var fs:FileStream = e.currentTarget as FileStream;
			var response:HTTPResponse = fs2Response[fs] as HTTPResponse;
			(response.output as Socket).close();
		}
	}

}