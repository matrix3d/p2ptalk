package test 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestProxy extends Sprite
	{
		private var loader:URLLoader;
		
		public function TestProxy() 
		{
			loader = new URLLoader;
			loader.addEventListener(Event.COMPLETE, loader_complete);
			loader.load(new URLRequest("https://www.baidu.com"));
		}
		
		private function loader_complete(e:Event):void 
		{
			trace(loader.data);
		}
		
	}

}