package net.rtmp.events 
{
	import flash.events.Event;
	import net.rtmp.net.stream.FlvWriter;
	/**
	 * ...
	 * @author lizhi
	 */
	public class StreamEvent extends Event
	{
		public var streamName:String;
		public var streamID:uint;
		public static const BEFORE_CREATE_RECORD_STREAM:String = "BeforeCreateRecordStream";
		public static const CLOSE_RECORD_STREAM:String = "CloseRecordStream";
		public var writer:FlvWriter;
		public function StreamEvent(type:String,streamID:uint, streamName:String,writer:FlvWriter=null) 
		{
			super(type);
			this.streamName = streamName;
			this.streamID = streamID;
			this.writer = writer;
			
		}
		
		override public function clone():Event 
		{
			return new StreamEvent(type,streamID,streamName,writer);
		}
	}

}