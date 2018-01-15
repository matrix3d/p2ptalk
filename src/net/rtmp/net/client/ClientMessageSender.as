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
	
	import net.rtmp.net.rtmp.RtmpPacket;
	import net.rtmp.net.stream.Stream;

	public class ClientMessageSender
	{
		public static function createInvokeMessagePacket(messageID:String, responseID:uint, amfVer:Boolean = false, rtmpChannel:uint = 0x03, streamChannel:uint = 0x00, streamTimeStamp:uint = 0x00, ...params:Array):RtmpPacket
		{
			var packet:RtmpPacket = new RtmpPacket();
			
			if(amfVer)
				packet.rtmpBody.writeByte(0);
			
			packet.writeObject(messageID);
			packet.writeObject(responseID);
			packet.writeObject(null);
			
			for(var i:int = 0; i < params.length; i ++)
			{
				if(amfVer)
					packet.writeObject(params[i]);
				else 
					packet.rtmpBody.writeObject(params[i]);
			}
			
			packet.rtmpChannel = rtmpChannel;
			packet.rtmpBodyType = (amfVer ? 0x11: 0x14);
			packet.streamTimeStamp = streamTimeStamp;
			packet.streamChannel = streamChannel;
			packet.rtmpBodySize = packet.rtmpBody.length;
			
			return packet;
		}
		
		public static function sendInvokeMessagePacket(client:Client, messageID:String, responseID:uint, amfVer:Boolean = false, rtmpChannel:uint = 0x03, streamChannel:uint = 0x00, streamTimeStamp:uint = 0x00, ...params:Array):void
		{
			params.unshift(streamTimeStamp);
			params.unshift(streamChannel);
			params.unshift(rtmpChannel);
			params.unshift(amfVer);
			params.unshift(responseID);
			params.unshift(messageID);
			
			var packet:RtmpPacket = createInvokeMessagePacket.apply(null, params);
			client.sendPacket(packet);
			
			packet.clear();
			packet = null;
		}
		
		public static function sendAcceptConnectMessage(client:Client, responseID:uint):void
		{
			sendInvokeMessagePacket(client, "_result", responseID, false, 0x03, 0, 0,
									{level : "status",
									code : "NetConnection.Connect.Success",
									objectEncoding : client.info.objectEncoding,
									description : "AS_RTMP_SERVER, by SnowMan."});
		}
		
		public static function sendRejectConnectMessage(client:Client, responseID:uint):void
		{
			sendInvokeMessagePacket(client, "_result", responseID, false, 0x03, 0, 0,
									{level : "status",
									code : "NetConnection.Connect.Rejected",
									objectEncoding : client.info.objectEncoding,
									description : "AS_RTMP_SERVER, by SnowMan."});
		}
		
		public static function sendCloseConnectMessage(client:Client, responseID:uint):void
		{
			sendInvokeMessagePacket(client, "_result", responseID, false, 0x03, 0, 0,
									{level : "status",
									code : "NetConnection.Connect.Closed",
									objectEncoding : client.info.objectEncoding,
									description : "AS-RTMP-SERVER, by SnowMan."});
		}
		
		public static function sendBWDoneMessage(client:Client):void
		{
			sendInvokeMessagePacket(client, "onBWDone", 0, false, 0x03, 0, 0);
		}
		
		public static function sendCreateStreamMessage(client:Client, responseID:uint, streamID:uint):void
		{
			sendInvokeMessagePacket(client, "_result", responseID, false, 0x03, 0, 0, streamID);
		}
		
		public static function sendStreamPublishStartMessage(client:Client, responseID:uint, streamChannel:uint):void
		{
			sendInvokeMessagePacket(client, "onStatus", responseID, false, 0x08, streamChannel, 0,
									{level : "status", code : "NetStream.Publish.Start"});
		}
		
		public static function sendStreamPublishStopMessage(client:Client, responseID:uint, streamChannel:uint):void
		{
			sendInvokeMessagePacket(client, "onStatus", responseID, false, 0x08, streamChannel, 0,
									{level : "status", code : "NetStream.Unpublish.Success"});
		}
		
		public static function sendStreamPublishBadNameMessage(client:Client, responseID:uint, streamChannel:uint):void
		{
			sendInvokeMessagePacket(client, "onStatus", responseID, false, 0x08, streamChannel, 0,
									{level:"status", code:"NetStream.Publish.BadName"});
		}
		
		public static function sendStreamPlayResetMessage(client:Client, responseID:uint, streamChannel:uint):void
		{
			sendInvokeMessagePacket(client, "onStatus", responseID, false, 0x04, streamChannel, 0,
									{level : "status", code : "NetStream.Play.Reset"});
		}
		
		public static function sendStreamPlayStartMessage(client:Client, responseID:uint, streamChannel:uint):void
		{
			sendInvokeMessagePacket(client, "onStatus", responseID, false, 0x05, streamChannel, 0,
									{level:"status", code:"NetStream.Play.Start"});
		}
		
		public static function sendStreamPlayStopMessage(client:Client, responseID:uint, streamChannel:uint):void
		{
			sendInvokeMessagePacket(client, "onStatus", responseID, false, 0x05, streamChannel, 0,
									{level:"status", code:"NetStream.Play.Stop"});
		}
		
		public static function sendStreamPlayFailedMessage(client:Client, responseID:uint, streamChannel:uint):void
		{
			sendInvokeMessagePacket(client, "onStatus", responseID, false, 0x08, streamChannel, 0,
									{level:"error", code:"NetStream.Play.Failed"});
		}
		
		public static function sendStreamSeekNotifyMessage(client:Client, responseID:uint, streamChannel:uint, seekTime:uint):void
		{
			sendInvokeMessagePacket(client, "onStatus", responseID, false, 0x05, streamChannel, seekTime,
									{level:"status", code:"NetStream.Seek.Notify"});
		}
		
		public static function sendStreamPauseNotifyMessage(client:Client, responseID:uint, streamChannel:uint):void
		{
			sendInvokeMessagePacket(client, "onStatus", responseID, false, 0x05, streamChannel, 0,
									{level:"status", code:"NetStream.Pause.Notify"});
		}
		
		public static function sendStreamUnpauseNotifyMessage(client:Client, responseID:uint, streamChannel:uint):void
		{
			sendInvokeMessagePacket(client, "onStatus", responseID, false, 0x05, streamChannel, 0,
									{level:"status", code:"NetStream.Unpause.Notify"});
		}
		
		public static function sendStreamPlayUnpublishNotifyMessage(client:Client, responseID:uint, streamChannel:uint):void
		{
			sendInvokeMessagePacket(client, "onStatus", responseID, false, 0x08, streamChannel, 0,
									{level:"status", code:"NetStream.Play.UnpublishNotify"});
		}
		
		public static function sendBytesReadMessage(client:Client):void
		{
			var packet:RtmpPacket = new RtmpPacket();
			var bytesIn:uint = client.bytesIn;
			
			packet.rtmpChannel = 0x02;
			packet.rtmpBodyType = 0x03;
			packet.streamChannel = 0;
			packet.rtmpBody.writeUnsignedInt(bytesIn);
			packet.rtmpBodySize = 4;
			
			client.sendPacket(packet);
			
			packet.clear();
			packet = null;
		}
		
		public static function sendBindInMessage(client:Client, bandIn:uint):void
		{
			var packet:RtmpPacket = new RtmpPacket();
			var bytesIn:uint = client.bytesIn;
			
			packet.rtmpChannel = 0x02;
			packet.rtmpBodyType = 0x05;
			packet.streamChannel = 0;
			packet.rtmpBody.writeUnsignedInt(bandIn);
			packet.rtmpBodySize = 4;
			
			client.sendPacket(packet);
			
			packet.clear();
			packet = null;
		}
		
		public static function sendBindOutMessage(client:Client, bandOut:uint):void
		{
			var packet:RtmpPacket = new RtmpPacket();
			var bytesIn:uint = client.bytesIn;
			
			packet.rtmpChannel = 0x02;
			packet.rtmpBodyType = 0x06;
			packet.streamChannel = 0;
			packet.rtmpBody.writeUnsignedInt(bandOut);
			packet.rtmpBodySize = 4;
			
			client.sendPacket(packet);
			
			packet.clear();
			packet = null;
		}
		
		public static function sendPingMessage(client:Client, p1:int, p2:int, p3:int = -1, p4:int = -1):void
		{
			var packet:RtmpPacket = new RtmpPacket();
			
			packet.rtmpBody.writeShort(p1);
			packet.rtmpBody.writeUnsignedInt(p2);
			
			if(p3 != -1) packet.rtmpBody.writeUnsignedInt(p3);
			if(p4 != -1) packet.rtmpBody.writeUnsignedInt(p4);
			
			packet.rtmpChannel = 0x02;
			packet.rtmpBodyType = 0x04;
			packet.rtmpBodySize = packet.rtmpBody.length;
			
			client.sendPacket(packet);
			
			packet.clear();
			packet = null;
		}
	}
}