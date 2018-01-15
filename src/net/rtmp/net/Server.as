/**************************************************************************************
 * Dragonfly - RTMP Server by ActionScript
 * 
 * Author: SnowMan
 * Author QQ: 228529978
 * BLOG: http://rtmp.net or http://rtmp.us.to
 * Copyright(c) AS-RTMP-Server(Dragonfly) 2012
 * SourceCode URL: http://code.google.com/p/as-rtmp-server
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **************************************************************************************/

package net.rtmp.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.ServerSocket;
	import lib3d.air.AIRUtils;
	//import flash.events.ServerSocketConnectEvent;
	//import flash.net.ServerSocket;
	import flash.utils.ByteArray;
	
	import net.rtmp.application.DefaultRtmpMain;
	import net.rtmp.application.IRtmpMain;
	import net.rtmp.application.RtmpApplication;
	import net.rtmp.events.ClientEvent;
	import net.rtmp.net.client.Client;
	import net.rtmp.net.rtmp.RtmpPacket;
	
	public class Server extends EventDispatcher
	{
		private static var instance:Server = null;
		
		private var mServer:Object;
		private var mClients:Vector.<Client>;
		private var mRtmpMain:IRtmpMain;
		
		public function Server()
		{
			mallocServer();
			mClients = new Vector.<Client>();
			mRtmpMain = new DefaultRtmpMain();
		}
		
		public static function getInstance():Server
		{
			if(instance == null) instance = new Server();
			return instance;
		}
		
		public static function getVersion():String
		{
			return "Dragonfly_0.3.3";
		}
		
		public function get rtmpMain():IRtmpMain
		{
			return mRtmpMain;
		}
		
		public function registRtmpMain(rtmpMain:IRtmpMain):void
		{
			mRtmpMain = rtmpMain;
		}
		
		public function listen(address:String = "0.0.0.0", port:uint = 1935):void
		{
			if(mServer.bound)
			{
				freeServer();
				mallocServer();
			}
			
			mServer.bind(port, address);
			mServer.listen();
			
			mRtmpMain.onAppStart(this);
			
			if(mServer.listening)
				trace("RTMP服务端监听在(RTMP Server listen on) " + address + ":" + port);
			else
				trace("RTMP服务端监听错误(RTMP Server listen error)!");
		}
		
		public function broadcast(bytes:ByteArray):void
		{
			for(var i:int = 0; i < mClients.length; i ++)
				mClients[i].send(bytes);
		}
		
		public function broadcastPacket(packet:RtmpPacket):void
		{
			for(var i:int = 0; i < mClients.length; i ++)
				mClients[i].sendPacket(packet);
		}
		
		public function close():void
		{
			for(var i:int = 0; i < mClients.length; i ++)
			{
				mClients[i].removeEventListener(ClientEvent.CLOSE, onClientCloseHandler);
				mClients[i].close();
			}
			
			mClients.splice(0, mClients.length);
			freeServer();
			
			mRtmpMain.onAppStop(this);
		}
		
		private function mallocServer():void
		{
			mServer = new ServerSocket//AIRUtils.newServerSocket();// new ServerSocket();
			mServer.addEventListener("connect", onConnectHandler);
		}
		
		private function freeServer():void
		{
			mServer.removeEventListener("connect", onConnectHandler);
			mServer.close();
		}
		
		private function onConnectHandler(event:Object):void
		{
			var client:Client = new Client(event.socket);
			client.addEventListener(ClientEvent.CLOSE, onClientCloseHandler);
			mClients.push(client);
			
			trace("客户端连接(client connect): " + client);
		}
		
		private function onClientCloseHandler(event:Event):void
		{
			var index:int = mClients.indexOf(event.target as Client);
			if(index != -1)
			{
				mClients[index].info.connected = false;
				
				trace("客户端断开(client disconnect): " + mClients[index]);
				
				mClients[index].removeEventListener(ClientEvent.CLOSE, onClientCloseHandler);
				var clients:Vector.<Client> = mClients.splice(index, 1);
				
				mRtmpMain.onDisconnect(clients[0]);
			}
		}
	}
}