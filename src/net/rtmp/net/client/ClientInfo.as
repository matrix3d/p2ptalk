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

	public class ClientInfo
	{
		private var mAddress:String;
		private var mPort:uint;
		private var mConnected:Boolean;
		private var mID:String;
		
		private var mObjectEncoding:uint;
		private var mApplication:String;
		private var mFlashVersion:String;
		private var mSwfURL:String;
		private var mTcURL:String;
		private var mPageURL:String;
		
		public function ClientInfo()
		{
			mAddress = "";
			mPort = 0;
			mConnected = false;
			mID = "";
			
			mObjectEncoding = ObjectEncoding.AMF0;
			mApplication = "";
			mFlashVersion = "";
			mSwfURL = "";
			mTcURL = "";
			mPageURL = "";
		}
		
		public function get address():String
		{
			return mAddress;
		}
		
		public function set address(value:String):void
		{
			mAddress = value;
		}
		
		public function get port():uint
		{
			return mPort;
		}
		
		public function set port(value:uint):void
		{
			mPort = value;
		}
		
		public function get connected():Boolean
		{
			return mConnected;
		}
		
		public function set connected(value:Boolean):void
		{
			mConnected = value;
		}
		
		public function get id():String
		{
			return mID;
		}
		
		public function set id(value:String):void
		{
			mID = value;
		}
		
		public function get objectEncoding():uint
		{
			return mObjectEncoding;
		}
		
		public function set objectEncoding(value:uint):void
		{
			mObjectEncoding = value;
		}
		
		public function get application():String
		{
			return mApplication;
		}
		
		public function set application(value:String):void
		{
			mApplication = value;
		}
		
		public function get flashVersion():String
		{
			return mFlashVersion;
		}
		
		public function set flashVersion(value:String):void
		{
			mFlashVersion = value;
		}
		
		public function get swfURL():String
		{
			return mSwfURL;
		}
		
		public function set swfURL(value:String):void
		{
			mSwfURL = value;
		}
		
		public function get tcURL():String
		{
			return mTcURL;
		}
		
		public function set tcURL(value:String):void
		{
			mTcURL = value;
		}
		
		public function get pageURL():String
		{
			return mPageURL;
		}
		
		public function set pageURL(value:String):void
		{
			mPageURL = value;
		}
		
		public function toString():String
		{
			return  "address = " + mAddress +
					", port = " + mPort +
					", connected = " + mConnected +
					", objectEncoding = " + mObjectEncoding +
					", application = " + mApplication +
					", flashVersion = " + mFlashVersion +
					", swfURL = " + mSwfURL +
					", tcURL = " + mTcURL +
					", pageURL = " + mPageURL;
		}
	}
}