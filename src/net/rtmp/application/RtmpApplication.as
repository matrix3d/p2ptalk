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

package net.rtmp.application
{
	import net.rtmp.net.Server;
	import net.rtmp.net.client.Client;
	import net.rtmp.net.client.ClientMessageSender;
	import net.rtmp.net.rtmp.RtmpPacket;

	public class RtmpApplication
	{
		public static function broadcastMsg(messageName:String, ...params:Array):void
		{
			params.unshift(0);
			params.unshift(0);
			params.unshift(0x03);
			params.unshift(true);
			params.unshift(0);
			params.unshift(messageName);
			
			var packet:RtmpPacket = ClientMessageSender.createInvokeMessagePacket.apply(null, params);
			Server.getInstance().broadcastPacket(packet);
		}
		
		public static function acceptConnection(client:Client):void
		{
			ClientMessageSender.sendAcceptConnectMessage(client, 1);
			client.info.connected = true;
		}
		
		public static function rejectConnection(client:Client):void
		{
			ClientMessageSender.sendRejectConnectMessage(client, 0);
			client.info.connected = false;
			client.close();
		}
		
		public static function closeConnection(client:Client):void
		{
			ClientMessageSender.sendCloseConnectMessage(client, 0);
			client.info.connected = false;
			client.close();
		}
	}
}