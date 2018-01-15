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

package net.rtmp.net.stream
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import net.rtmp.events.StreamEvent;
	
	import net.rtmp.net.Server;
	import net.rtmp.net.client.Client;
	import net.rtmp.net.client.ClientMessageSender;
	import net.rtmp.net.rtmp.RtmpPacket;

	public class Stream extends EventDispatcher
	{
		//private static var mStreamPath:String = File.applicationDirectory.nativePath;
		public static var isToMem:Boolean = false;
		private static var mInstance:Stream = null;
		private var mMaxID:uint;
		private var mStreamInfoMap:Dictionary;
		
		private var mRecordStreamMap:Dictionary;
		
		public function Stream()
		{
			mMaxID = 1;
			mStreamInfoMap = new Dictionary();
			mRecordStreamMap = new Dictionary();
		}
		
		public static function getInstance():Stream
		{
			if(mInstance == null) mInstance = new Stream();
			return mInstance;
		}
		
		public function getCurrentID():uint
		{
			mMaxID ++;
			if(mMaxID > 0xFFFF) mMaxID = 1;
			
			return mMaxID;
		}
		
		public function getStreamTypeByID(streamID:uint):Boolean
		{
			return mStreamInfoMap[streamID].streamType;
		}
		
		public function getNameByID(streamID:uint):String
		{
			return mStreamInfoMap[streamID].streamName;
		}
		
		public function getClientByID(streamID:uint):Client
		{
			return mStreamInfoMap[streamID].streamClient;
		}
		
		public function getPlayClientsByID(streamID:uint):Vector.<uint>
		{
			return mStreamInfoMap[streamID].playStreamIDs;
		}
		
		public function hasSamePublishStream(streamID:uint, streamName:String):Boolean
		{
			for(var id:String in mStreamInfoMap)
			{
				if(uint(id) != streamID && mStreamInfoMap[id].streamName == streamName && mStreamInfoMap[id].streamType == true)
					return true;
			}
			
			return false;
		}
		
		public function createStream(client:Client, streamID:uint):void
		{
			mStreamInfoMap[streamID] = new StreamInfo();
			mStreamInfoMap[streamID].streamClient = client;
		}
		
		public function publishStream(streamID:uint, streamName:String, publishType:Boolean):void
		{
			mStreamInfoMap[streamID].streamName = streamName;
			mStreamInfoMap[streamID].streamType = true;
			mStreamInfoMap[streamID].publishType = publishType;
			mStreamInfoMap[streamID].playStreamIDs = new Vector.<uint>();
			
			for(var id:String in mStreamInfoMap)
			{
				if(mStreamInfoMap[id].streamName == streamName && mStreamInfoMap[id].streamType == false)
				{
					mStreamInfoMap[id].publishStreamID = streamID;
					mStreamInfoMap[streamID].playStreamIDs.push(uint(id));
				}
			}
		}
		
		public function playStream(client:Client, streamID:uint, streamName:String):void
		{
			mStreamInfoMap[streamID].streamName = streamName;
			mStreamInfoMap[streamID].streamType = false;
			mStreamInfoMap[streamID].publishType = false;
			
			for(var id:String in mStreamInfoMap)
			{
				if(mStreamInfoMap[id].streamName == streamName && mStreamInfoMap[id].streamType == true)
				{
					mStreamInfoMap[id].playStreamIDs.push(streamID);
					mStreamInfoMap[streamID].publishStreamID = uint(id);
				}
			}
		}
		
		public function closeStream(streamID:uint):void
		{
			if(mStreamInfoMap[streamID].streamType)
			{
//				var playStreamIDs:Vector.<uint> = mStreamInfoMap[streamID].playStreamIDs;
//				for(var i:int = 0; i < playStreamIDs.length; i ++)
//				{
//					var id:uint = playStreamIDs[i];
//					mStreamInfoMap[id].publishStreamID = 0;
//				}
				
				mStreamInfoMap[streamID].streamName = "";
				mStreamInfoMap[streamID].streamType = false;
				mStreamInfoMap[streamID].publishType = false;
				mStreamInfoMap[streamID].publishStreamID = 0;
				mStreamInfoMap[streamID].playStreamIDs.splice(0, mStreamInfoMap[streamID].playStreamIDs.length);
			}
			else
			{
				var publishStreamID:uint = mStreamInfoMap[streamID].publishStreamID;
				if(!mStreamInfoMap[publishStreamID]) return;
				var index:int = mStreamInfoMap[publishStreamID].playStreamIDs.indexOf(streamID);
				if(index != -1) mStreamInfoMap[publishStreamID].playStreamIDs.splice(index, 1);
			}
		}
		
		public function deleteStream(streamID:uint):void
		{
			closeRecordStream(streamID);
			
			mStreamInfoMap[streamID] = null;
			delete mStreamInfoMap[streamID];
		}
		
		public function broadcastStream(packet:RtmpPacket):void
		{
			var playStreamIDs:Vector.<uint> = mStreamInfoMap[packet.streamChannel].playStreamIDs;
			for(var i:int = 0; i < playStreamIDs.length; i ++)
			{
				var id:uint = playStreamIDs[i];
				packet.streamChannel = id;
				mStreamInfoMap[id].streamClient.sendPacket(packet);
			}
			
			if(mStreamInfoMap[packet.streamChannel].publishType)
				writeRecordStream(packet);
		}
		
		public function createRecordStream(streamID:uint, streamName:String):void
		{
			dispatchEvent(new StreamEvent(StreamEvent.BEFORE_CREATE_RECORD_STREAM,streamID, streamName));
			if(mRecordStreamMap[streamID]==null){
				createRecordStreamWithFlvWriter(streamID, streamName, new FlvWriter(isToMem));
			}
		}
		
		public function createRecordStreamWithFlvWriter(streamID:uint, streamName:String, writer:FlvWriter):void{
			mRecordStreamMap[streamID] = writer;
			mRecordStreamMap[streamID].create(streamName);
		}
		
		public function writeRecordStream(packet:RtmpPacket):void
		{
			mRecordStreamMap[packet.streamChannel].write(packet);
		}
		
		public function closeRecordStream(streamID:uint):void
		{
			if(mStreamInfoMap[streamID] && mStreamInfoMap[streamID].publishType)
			{
				mRecordStreamMap[streamID].close();
				dispatchEvent(new StreamEvent(StreamEvent.CLOSE_RECORD_STREAM,streamID,null,mRecordStreamMap[streamID]));
				
				mRecordStreamMap[streamID] = null;
				delete mRecordStreamMap[streamID];
			}
		}
	}
}