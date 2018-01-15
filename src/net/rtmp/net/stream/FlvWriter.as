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
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.ObjectEncoding;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.getTimer;
	
	import net.rtmp.net.rtmp.RtmpPacket;

	public class FlvWriter
	{
		//Video Frame Type
		private static const FRAMETYPE_KEY:uint = 1;
		private static const FRAMETYPE_INTER:uint = 2;
		private static const FRAMETYPE_DISPOSABLE_INTER:uint = 3;
		private static const FRAMETYPE_GENERATED_KEY:uint = 4;
		private static const FRAMETYPE_COMMAND:uint = 5;
		
		//Video Code Type
		private static const VIDEO_CODECTYPE_JPEG:uint = 1;
		private static const VIDEO_CODECTYPE_H263:uint = 2;
		private static const VIDEO_CODECTYPE_SCREEN:uint = 3;
		private static const VIDEO_CODECTYPE_ON2VP6:uint = 4;
		private static const VIDEO_CODECTYPE_ON2VP6_ALPHA:uint = 5;
		private static const VIDEO_CODECTYPE_V2:uint = 6;
		private static const VIDEO_CODECTYPE_AVC:uint = 7;
		
		//Audio Code Type
		private static const AUDIO_CODECTYPE_ADPCM:uint = 1;
		private static const AUDIO_CODECTYPE_MP3:uint = 2;
		private static const AUDIO_CODECTYPE_PCM:uint = 3;
		private static const AUDIO_CODECTYPE_NELLY_16:uint = 4;
		private static const AUDIO_CODECTYPE_NELLY_8:uint = 5;
		private static const AUDIO_CODECTYPE_NELLY:uint = 6;
		private static const AUDIO_CODECTYPE_G711_A:uint = 7;
		private static const AUDIO_CODECTYPE_G711_U:uint = 8;
		private static const AUDIO_CODECTYPE_RESERVED:uint = 9;
		private static const AUDIO_CODECTYPE_AAC:uint = 10;
		private static const AUDIO_CODECTYPE_SPEEX:uint = 11;
		private static const AUDIO_CODECTYPE_MP3_8:uint = 14;
		private static const AUDIO_CODECTYPE_DEVICE_SPECIFIC:uint = 15;
		
		//Audio SampleRate
		private static const AUDIO_SAMPLERATE_KHZ_5:uint = 0;
		private static const AUDIO_SAMPLERATE_KHZ_11:uint = 1;
		private static const AUDIO_SAMPLERATE_KHZ_22:uint = 2;
		private static const AUDIO_SAMPLERATE_KHZ_44:uint = 3;
		
		private var mFile:File;
		private var mOutput:IDataOutput;
		private var mStream:FileStream;
		public var mByteArray:ByteArray;
		private var mPreTagSize:uint;
		
		public var mDuration:Number;
		private var mHasAudio:Boolean;
		private var mHasVideo:Boolean;
		
		private var mStart:int = 0;
		private var mTimeStamp:int = 0;
		private var isToMem:Boolean;//是否写入内存，否则写入文件
		
		public function FlvWriter(isToMem:Boolean=false)
		{
			trace("new flvwriter",isToMem);
			this.isToMem = isToMem;
			mPreTagSize = 0;
		}
		
		public function create(filePath:String):void
		{
			mDuration = getTimer();
			mHasAudio = false;
			mHasVideo = false;
			if (isToMem){
				mByteArray = new ByteArray;
				mOutput = mByteArray;
			}else{
				mFile = new File(File.applicationDirectory.nativePath+"/"+filePath+".flv");
				mStream = new FileStream();
				mStream.open(mFile, FileMode.WRITE);
				mOutput = mStream;
			}
			
			mOutput.writeUTFBytes("FLV");
			mOutput.writeByte(0x01);
			mOutput.writeByte(0x05);
			mOutput.writeUnsignedInt(0x09);
			
			mStart = -1;
			
			writeMetaDataTag();
		}
		
		public function write(packet:RtmpPacket):void
		{
			switch(packet.rtmpBodyType)
			{
				case 0x08: writeAudioTag(packet); break;
				case 0x09: writeVideoTag(packet); break;
			}
		}
		
		public function close():void
		{
			if(mStream)
			mStream.position = 4;
			if(mByteArray)
			mByteArray.position = 4;
			
			var flag:int = 0;
			if(mHasAudio) flag += 4;
			if(mHasVideo) flag += 1;
			mOutput.writeByte(flag);
			
			if(mStream)
			mStream.position = 9;
			if (mByteArray)
			mByteArray.position = 9;
			
			mPreTagSize = 0;
			mDuration = (getTimer() - mDuration) / 1000;
			writeMetaDataTag();
			
			if(mStream){
				mStream.close();
			}
			mStream = null;
			mFile = null;
		}
		
		public function writeAudioTag(packet:RtmpPacket):void
		{
			mHasAudio = true;
			
			var pos:uint =mStream? mStream.position:mByteArray.position;
			writeTag(0x08, packet);
			
			mPreTagSize = mStream? mStream.position:mByteArray.position - pos;
		}
		
		public function writeVideoTag(packet:RtmpPacket):void
		{
			mHasVideo = true;
			
			var pos:uint =mStream? mStream.position:mByteArray.position;
			writeTag(0x09, packet);
			
			mPreTagSize = mStream? mStream.position:mByteArray.position - pos;
		}
		
		public function writeMetaDataTag():void
		{
			return;
			mOutput.writeUnsignedInt(mPreTagSize);
			
			var metaData:ByteArray = new ByteArray();
			metaData.objectEncoding = ObjectEncoding.AMF0;
			metaData.writeObject("onMetaData");
			
			var info:Object = {};
			info.duration = Number(mDuration);
			info.width = Number(320);
			info.height = Number(240);
			info.canSeekToEnd = true;
			info.framerate = Number(30);
			info.metadatacreator = "DragonflyRTMPServer";
			mOutput.writeObject(info);
			
			var pos:uint =mStream? mStream.position:mByteArray.position;
			
			mOutput.writeByte(18);
			mOutput.writeByte((metaData.length >> 16) & 0xFF);
			mOutput.writeByte((metaData.length >> 8) & 0xFF);
			mOutput.writeByte(metaData.length & 0xFF);
			
			mOutput.writeByte(0);
			mOutput.writeByte(0);
			mOutput.writeByte(0);
			mOutput.writeByte(0);
			mOutput.writeByte(0);
			mOutput.writeByte(0);
			mOutput.writeByte(0);
			
			mOutput.writeBytes(metaData);
			
			mPreTagSize = (mStream?mStream.position:mByteArray.position) - pos;
		}
		
		private function writeTag(type:uint, packet:RtmpPacket):void
		{
			if(mStart == -1) mStart = getTimer();
			mTimeStamp = getTimer() - mStart;
			
			mOutput.writeUnsignedInt(mPreTagSize);
			mOutput.writeByte(type);
			
			mOutput.writeByte((packet.rtmpBodySize >> 16) & 0xFF);
			mOutput.writeByte((packet.rtmpBodySize >> 8) & 0xFF);
			mOutput.writeByte(packet.rtmpBodySize & 0xFF);
			
			mOutput.writeByte((mTimeStamp >> 16) & 0xFF);
			mOutput.writeByte((mTimeStamp >> 8) & 0xFF);
			mOutput.writeByte(mTimeStamp & 0xFF);
			mOutput.writeUnsignedInt(0);
			
			mOutput.writeBytes(packet.rtmpBody);
		}
	}
}