package ui 
{
	import flash.display.DisplayObject;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TNativeWindow extends NativeWindow
	{
		private var dis:DisplayObject;
		
		public function TNativeWindow(dis:DisplayObject) 
		{
			this.dis = dis;
			var opt:NativeWindowInitOptions = new NativeWindowInitOptions;
			//opt.type = NativeWindowType.LIGHTWEIGHT;
			//opt.owner = stage.nativeWindow;
			//opt.systemChrome = NativeWindowSystemChrome.NONE;
			super(opt);
			//activate();
			stage.addChild(dis);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			addEventListener(Event.CLOSING, closing);
		}
		
		private function closing(e:Event):void 
		{
			e.preventDefault();
			visible = false;
			minimize();
		}
		
	}

}