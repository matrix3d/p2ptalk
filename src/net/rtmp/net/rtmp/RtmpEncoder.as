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
	import flash.net.ObjectEncoding;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import net.rtmp.net.client.Client;

	public class RtmpEncoder extends EventDispatcher
	{
		private var mClient:Client;
		private var mBuffer:ByteArray;
		
		private var mOldRtmpBodyType:Vector.<uint>;
		private var mOldRtmpBodySize:Vector.<uint>;
		private var mOldStreamTimeStamp:Vector.<uint>;
		private var mOldStreamChannel:Vector.<int>;
		
		private var mHeaderSize:uint;
		private var mHeaderFlag:uint;
		private var mChunkSize:uint;
		private var mRemaining:uint;
		
		public function RtmpEncoder(client:Client)
		{
			mClient = client;
			mBuffer = new ByteArray();
			mOldRtmpBodyType = new Vector.<uint>(64);
			mOldRtmpBodySize = new Vector.<uint>(64);
			mOldStreamTimeStamp = new Vector.<uint>(64);
			mOldStreamChannel = new Vector.<int>(64);
			
			for(var i:int = 0; i < 64; i ++)
			{
				mOldRtmpBodyType[i] = 0;
				mOldRtmpBodySize[i] = 0;
				mOldStreamTimeStamp[i] = 0;
				mOldStreamChannel[i] = -1;
			}
		}
		
		public function process(packet:RtmpPacket):void
		{
			mBuffer.clear();
			
			if(mOldStreamChannel[packet.rtmpChannel] == packet.streamChannel && packet.rtmpChannel != 0x02)
			{
				mHeaderSize = 8;
				mHeaderFlag = 0x40;
				
				if(mOldRtmpBodyType[packet.rtmpChannel] == packet.rtmpBodyType && mOldRtmpBodySize[packet.rtmpChannel] == packet.rtmpBodySize)
				{
					mHeaderSize = 4;
					mHeaderFlag = 0x80;
					
					if(mOldStreamTimeStamp[packet.rtmpChannel] == packet.streamTimeStamp)
					{
						mHeaderSize = 1;
						mHeaderFlag = 0xC0;
					}
				}
			}
			else
			{
				mHeaderSize = 12;
				mHeaderFlag = 0x00;
			}
			
			mOldRtmpBodyType[packet.rtmpChannel] = packet.rtmpBodyType;
			mOldRtmpBodySize[packet.rtmpChannel] = packet.rtmpBodySize;
			mOldStreamTimeStamp[packet.rtmpChannel] = packet.streamTimeStamp;
			mOldStreamChannel[packet.rtmpChannel] = packet.streamChannel;
			
			var first:uint = mHeaderFlag | (packet.rtmpChannel & 0x3F);
			mBuffer.writeByte(first);
			
			if(mHeaderSize > 1)
			{
				mBuffer.writeShort((packet.streamTimeStamp >> 8) & 0xFFFF);
				mBuffer.writeByte(packet.streamTimeStamp & 0xFF);
				
				if(mHeaderSize > 4)
				{
					mBuffer.writeShort((packet.rtmpBodySize >> 8) & 0xFFFF);
					mBuffer.writeByte(packet.rtmpBodySize & 0xFF);
					mBuffer.writeByte(packet.rtmpBodyType);
					
					if(mHeaderSize > 8)
					{
						mBuffer.writeByte(packet.streamChannel & 0xFF);
						mBuffer.writeByte((packet.streamChannel >> 8) && 0xFF);
						mBuffer.writeByte((packet.streamChannel >> 16) && 0xFF);
						mBuffer.writeByte((packet.streamChannel >> 24) && 0xFF);
					}
				}
			}
			
			mChunkSize = (packet.rtmpBodyType == 0x08 ? 65 : 128);
			mRemaining = packet.rtmpBodySize;
			
			while(mRemaining > 0)
			{
				var size:uint = (mRemaining < mChunkSize ? mRemaining : mChunkSize);
				mBuffer.writeBytes(packet.rtmpBody, packet.rtmpBodySize - mRemaining, size);
				mRemaining -= size;
				if(mRemaining > 0) mBuffer.writeByte(first | 0xC0);
			}
			
			mBuffer.position = 0;
			mClient.send(mBuffer);
		}
	}
}