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

package net.rtmp.net.client
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.ObjectEncoding;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import net.rtmp.events.ClientEvent;
	import net.rtmp.events.ClientHandShakeEvent;
	import net.rtmp.events.RtmpDecoderEvent;
	import net.rtmp.net.rtmp.RtmpDecoder;
	import net.rtmp.net.rtmp.RtmpEncoder;
	import net.rtmp.net.rtmp.RtmpPacket;

	[Event(name = "rtmp_client_close", type = "net.rtmp.events.ClientEvent")]
	
	public class Client extends EventDispatcher
	{
		private static var mMaxID:uint = 0;
		
		private var mSocket:Socket;
		private var mHandShake:ClientHandShake;
		private var mInfo:ClientInfo;
		private var mRtmpDecoder:RtmpDecoder;
		private var mRtmpEncoder:RtmpEncoder;
		private var mMessageHandle:ClientMessageHandler;
		
		private var mBytesIn:uint;
		
		public function Client(socket:Socket)
		{
			mHandShake = new ClientHandShake();
			mInfo = new ClientInfo();
			mRtmpDecoder = new RtmpDecoder(this);
			mRtmpEncoder = new RtmpEncoder(this);
			mMessageHandle = new ClientMessageHandler(this);
			
			mHandShake.addEventListener(ClientHandShakeEvent.HANDSHAKE, onHandShakeHandler);
			mRtmpDecoder.addEventListener(RtmpDecoderEvent.DECODED, onDecodedHandler);
			
			if(socket)
			{
				close();
				mSocket = socket;
				mSocket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketDataHandler);
				mSocket.addEventListener(Event.CLOSE, onSocketCloseHandler);
				
				mInfo.address = mSocket.remoteAddress;
				mInfo.port = mSocket.remotePort;
				mInfo.id = "Client_" + mMaxID ++;
			}
		}
		
		public function get info():ClientInfo
		{
			return mInfo;
		}
		
		public function get bytesIn():uint
		{
			return mBytesIn;
		}
		
		public function send(bytes:ByteArray):void
		{
			mSocket.writeBytes(bytes);
			mSocket.flush();
		}
		
		public function sendPacket(packet:RtmpPacket):void
		{
			mRtmpEncoder.process(packet);
		}
		
		public function close():void
		{
			if(mSocket)
			{
				mSocket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketDataHandler);
				mSocket.removeEventListener(Event.CLOSE, onSocketCloseHandler);
				mSocket.close();
			}
			
			if(mInfo.connected)
			{
				mHandShake.removeEventListener(ClientHandShakeEvent.HANDSHAKE, onHandShakeHandler);
				mRtmpDecoder.removeEventListener(RtmpDecoderEvent.DECODED, onDecodedHandler);
			}
		}
		
		private function onSocketDataHandler(event:ProgressEvent):void
		{
			if(!mInfo.connected)
				mHandShake.process(mSocket);
			else
			{
				mBytesIn += mSocket.bytesAvailable;
				mRtmpDecoder.process(mSocket, mInfo.objectEncoding);
			}
		}
		
		private function onSocketCloseHandler(event:Event):void
		{
			mMessageHandle.onCloseClient();
			
			close();
			dispatchEvent(new ClientEvent(ClientEvent.CLOSE));
		}
		
		private function onHandShakeHandler(event:ClientHandShakeEvent):void
		{
			switch(event.step)
			{
				case ClientHandShakeEvent.STEP_1: send(event.bytes); 										break;
				case ClientHandShakeEvent.STEP_2: mRtmpDecoder.process(event.bytes, ObjectEncoding.AMF0); 	break;
			}
		}
		
		private function onDecodedHandler(event:RtmpDecoderEvent):void
		{
			var packet:RtmpPacket = event.packet;
			//Logger.debug("Receive packet: " + packet);
			
			switch(packet.rtmpBodyType)
			{
				case 0x03:				mMessageHandle.onRecvBytesReadPacket(packet);	break;
				case 0x04: 				mMessageHandle.onRecvPingPacket(packet); 		break;
				case 0x05:				mMessageHandle.onRecvBindInPacket(packet);		break;
				case 0x06:				mMessageHandle.onRecvBindOutPacket(packet);		break;
				case 0x08: case 0x09: 	mMessageHandle.onRecvFlvPakcet(packet); 		break;
				case 0x11: case 0x14: 	mMessageHandle.onRecvDataPakcet(packet); 		break;
				case 0x16:				trace("类型(type) = 0x16 流数据(StreamData)!!!");		break;
				default:				trace("其它类型包(Other Packet)!!! 类型(type) = " + packet.rtmpBodyType);	break;
			}
		}
		
		public override function toString():String
		{
			return mInfo.toString();
		}
	}
}