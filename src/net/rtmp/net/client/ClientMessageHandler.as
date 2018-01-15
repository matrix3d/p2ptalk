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
	import flash.net.ObjectEncoding;
	
	import net.rtmp.net.Server;
	import net.rtmp.net.rtmp.RtmpPacket;
	import net.rtmp.net.stream.Stream;

	public class ClientMessageHandler
	{
		private var mClient:Client;
		
		public function ClientMessageHandler(client:Client)
		{
			mClient = client;
		}
		
		public function onRecvBytesReadPacket(packet:RtmpPacket):void
		{
			ClientMessageSender.sendBytesReadMessage(mClient);
			packet.clear();
			packet = null;
		}
		
		public function onRecvPingPacket(packet:RtmpPacket):void
		{
//			ClientMessageSender.sendPingMessage(mClient, 0, 0, 0, 0);
			packet.clear();
			packet = null;
		}
		
		public function onRecvBindInPacket(packet:RtmpPacket):void
		{
//			ClientMessageSender.sendBindInMessage(mClient, 0);
			packet.clear();
			packet = null;
		}
		
		public function onRecvBindOutPacket(packet:RtmpPacket):void
		{
//			ClientMessageSender.sendBindOutMessage(mClient, 0);
			packet.clear();
			packet = null;
		}
		
		public function onRecvFlvPakcet(packet:RtmpPacket):void
		{
			Stream.getInstance().broadcastStream(packet);
			packet.clear();
			packet = null;
		}
		
		public function onRecvDataPakcet(packet:RtmpPacket):void
		{
			if(mClient.info.objectEncoding == ObjectEncoding.AMF3) packet.rtmpBody.readByte();
			var invokeName:String = packet.readObject() as String;
			
			trace("通知消息名(invokeName) = " + invokeName);
			
			switch(invokeName)
			{
				case "connect":			onConnect(packet);			break;
				case "createStream":	onCreateStream(packet);		break;
				case "publish":			onPublish(packet);			break;
				case "play":			onPlay(packet);				break;
				case "deleteStream":	onDeleteStream(packet);		break;
				case "closeStream":		onCloseStream(packet);		break;
				default: 				trace("LPC");		break;
			}
			
			packet.clear();
			packet = null;
		}
		
		public function onConnect(packet:RtmpPacket):void
		{
			var responseID:uint = packet.readObject() as uint;
			var connectInfo:Object = packet.readObject();
			
			trace("客户端连接信息(client connect info):", connectInfo);
			
			mClient.info.objectEncoding = connectInfo["objectEncoding"];
			mClient.info.application = connectInfo["app"];
			mClient.info.flashVersion = connectInfo["flashVer"];
			mClient.info.swfURL = connectInfo["swfUrl"];
			mClient.info.tcURL = connectInfo["tcUrl"];
			mClient.info.pageURL = connectInfo["pageUrl"];
			
			Server.getInstance().rtmpMain.onConnect(mClient);
		}
		
		public function onCreateStream(packet:RtmpPacket):void
		{
			var responseID:uint = packet.readObject() as uint;
			var streamID:uint = Stream.getInstance().getCurrentID();
			
			Stream.getInstance().createStream(mClient, streamID);
			ClientMessageSender.sendCreateStreamMessage(mClient, responseID, streamID);
		}
		
		public function onPublish(packet:RtmpPacket):void
		{
			var responseID:uint = packet.readObject() as uint;
			var nullValue:Object = packet.readObject();
			var streamName:String = packet.readObject() as String;
			var type:String = packet.readObject() as String;
			
			if(type == "live" || type == "record")
			{
				Stream.getInstance().publishStream(packet.streamChannel, streamName, (type == "record" ? true : false));
				
				if(Stream.getInstance().hasSamePublishStream(packet.streamChannel, streamName))
				{
					ClientMessageSender.sendStreamPublishBadNameMessage(mClient, responseID, packet.streamChannel);
					return;
				}
				
				if(type == "record") Stream.getInstance().createRecordStream(packet.streamChannel, streamName);
				ClientMessageSender.sendStreamPublishStartMessage(mClient, responseID, packet.streamChannel);
			}
		}
		
		public function onPlay(packet:RtmpPacket):void
		{
			var responseID:uint = packet.readObject() as uint;
			var nullValue:Object = packet.readObject();
			var streamName:String = packet.readObject() as String;
			
			Stream.getInstance().playStream(mClient, packet.streamChannel, streamName);
			ClientMessageSender.sendStreamPlayResetMessage(mClient, responseID, packet.streamChannel);
			ClientMessageSender.sendStreamPlayStartMessage(mClient, responseID, packet.streamChannel);
		}
		
		public function onDeleteStream(packet:RtmpPacket):void
		{
			var responseID:uint = packet.readObject() as uint;
			var nullValue:Object = packet.readObject();
			var streamID:int = packet.readObject() as Number;
			
			Stream.getInstance().deleteStream(streamID);
		}
		
		public function onCloseStream(packet:RtmpPacket):void
		{
			var responseID:uint = packet.readObject() as uint;
			
			var streamType:Boolean = Stream.getInstance().getStreamTypeByID(packet.streamChannel);
			
			if(streamType)
			{
				ClientMessageSender.sendStreamPublishStopMessage(mClient, responseID, packet.streamChannel);
				Stream.getInstance().closeRecordStream(packet.streamChannel);
			}
			else
				ClientMessageSender.sendStreamPlayStopMessage(mClient, responseID, packet.streamChannel);
			
			Stream.getInstance().closeStream(packet.streamChannel);
		}
		
		public function onCloseClient():void
		{
			//TODO: remove stream.
		}
	}
}