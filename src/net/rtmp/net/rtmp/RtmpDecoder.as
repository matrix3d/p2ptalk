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

package net.rtmp.net.rtmp
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.ObjectEncoding;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.Timer;
	
	import net.rtmp.events.RtmpDecoderEvent;
	import net.rtmp.net.client.Client;
	
	[Event(name = "rtmp_decoded", type = "net.rtmp.events.RtmpDecoderEvent")]
	
	public class RtmpDecoder extends EventDispatcher
	{
		private static const READED_FIRSTBYTE:String = "readed_firstByte";
		private static const READED_HEADER:String = "readed_header";
		private static const READED_BODY:String = "readed_body";
		
		private var mClient:Client;
		private var mPackets:Dictionary;
		private var mReadStatus:String;
		
		private var mRtmpHeadSize:uint;
		private var mRtmpChannel:uint;
		
		public function RtmpDecoder(client:Client)
		{
			mClient = client;
			mPackets = new Dictionary();
			
			mReadStatus = READED_BODY;
			mRtmpHeadSize = 0;
			mRtmpChannel = 0;
		}
		
		public function process(dataInput:IDataInput, encoding:uint):void
		{
			while(true)
			{
				if(mReadStatus == READED_BODY)
					if(!readFirst(dataInput, encoding)) break;
				
				if(mReadStatus == READED_FIRSTBYTE)
					if(!readHead(dataInput)) break;
				
				if(mReadStatus == READED_HEADER)
					if(!readBody(dataInput)) break;
			}
		}
		
		private function readFirst(dataInput:IDataInput, encoding:uint):Boolean
		{
			if(dataInput.bytesAvailable > 0)
			{
				var first:uint = dataInput.readUnsignedByte();
				mRtmpHeadSize = first & 0xC0;
				mRtmpChannel = first & 0x3F;
				
				if(mPackets[mRtmpChannel] == null)
				{
					mPackets[mRtmpChannel] = new RtmpPacket();
					mPackets[mRtmpChannel].rtmpChannel = mRtmpChannel;
				}
				
				var packet:RtmpPacket = mPackets[mRtmpChannel];
				packet.objectEncoding = encoding;
				
				switch(mRtmpHeadSize)
				{
					case 0xC0:	mRtmpHeadSize = 1;	break;
					case 0x80:	mRtmpHeadSize = 4;	break;
					case 0x40:	mRtmpHeadSize = 8;	break;
					case 0x00:	mRtmpHeadSize = 12;	break;
					default: 	trace("RTMP解码包错误(decode packet error)!"); break;
				}
				
				mReadStatus = READED_FIRSTBYTE;
			}
			else 
				return false;
			
			return true;
		}
		
		private function readHead(dataInput:IDataInput):Boolean
		{
			var packet:RtmpPacket = mPackets[mRtmpChannel];
			
			if(dataInput.bytesAvailable >= mRtmpHeadSize - 1)
			{
				if(mRtmpHeadSize > 1)
				{
					packet.streamTimeStamp = (dataInput.readUnsignedShort() << 8) | dataInput.readUnsignedByte();
					
					if(mRtmpHeadSize > 4)
					{
						packet.rtmpBodySize = (dataInput.readUnsignedShort() << 8) | dataInput.readUnsignedByte();
						packet.rtmpBodyType = dataInput.readUnsignedByte();
						
						packet.chunkSize = (packet.rtmpBodyType == 0x08 ? 65 : 128);
						packet.remaining = packet.rtmpBodySize;
						
						if(mRtmpHeadSize > 8)
						{
							packet.streamChannel = (dataInput.readUnsignedByte() & 0xFF) | (dataInput.readUnsignedByte() << 8) |
													(dataInput.readUnsignedByte() << 16) | (dataInput.readUnsignedByte() << 24);
						}
					}
				}
				
				if(packet.chunkSize > packet.remaining) packet.chunkSize = packet.remaining;
				
				mReadStatus = READED_HEADER;
			}
			else 
				return false;
			
			return true;
		}
		
		private function readBody(dataInput:IDataInput):Boolean
		{
			var packet:RtmpPacket = mPackets[mRtmpChannel];
			
			if(dataInput.bytesAvailable >= packet.chunkSize)
			{
				dataInput.readBytes(packet.rtmpBody, packet.rtmpBody.position, packet.chunkSize);
				packet.rtmpBody.position += packet.chunkSize;
				packet.remaining -= packet.chunkSize;
				
				mReadStatus = READED_BODY;
				
				if(packet.remaining == 0)
				{
					packet.rtmpBody.position = 0;
					dispatchEvent(new RtmpDecoderEvent(RtmpDecoderEvent.DECODED, packet.clone()));
					
					packet.rtmpBody.clear();
					packet.chunkSize = 128;//(packet.rtmpBodyType == 0x08 ? 65 : 128);
					packet.remaining = packet.rtmpBodySize;
				}
			}
			else 
				return false;
			
			return true;
		}
	}
}