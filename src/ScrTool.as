package  
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ScrTool
	{
		static private var onCutOver:Function;
		private static var scrWin:NativeWindow;
		private static var scrImageWrapper:Sprite = new Sprite;
		private static var scrImage:Bitmap=new Bitmap;
		static private var log:Function;
		static private var stage:Stage;
		static private var downPos:Point;
		public function ScrTool() 
		{
			
		}
		
		public static function startCut(onCutOver:Function,stage:Stage,log:Function):void {
			ScrTool.stage = stage;
			ScrTool.log = log;
			ScrTool.onCutOver = onCutOver;
			
			if (Clipboard.generalClipboard.hasFormat(ClipboardFormats.BITMAP_FORMAT)) {
				var bmd:BitmapData = Clipboard.generalClipboard.getData(ClipboardFormats.BITMAP_FORMAT) as BitmapData;
				Clipboard.generalClipboard.clear();
				scrImage.bitmapData = bmd;
				if (scrWin==null) {
					var opt:NativeWindowInitOptions = new NativeWindowInitOptions;
					opt.type = NativeWindowType.LIGHTWEIGHT;
					opt.owner = stage.nativeWindow;
					opt.systemChrome = NativeWindowSystemChrome.NONE;
					scrWin = new NativeWindow(opt);
					
					scrWin.stage.align = StageAlign.TOP_LEFT;
					scrWin.stage.scaleMode = StageScaleMode.NO_SCALE;
					scrWin.stage.addChild(scrImageWrapper);
					scrImageWrapper.addChild(scrImage);
					scrImageWrapper.addEventListener(MouseEvent.MOUSE_DOWN, scrImageWrapper_mouseDown);
					scrWin.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
					scrWin.addEventListener(Event.CLOSING, scrWin_closing);
				}
				stage.nativeWindow.alwaysInFront = true;
				scrWin.activate();
				scrWin.x = 0;
				scrWin.y = 0;
				scrWin.width = bmd.width
				scrWin.height = bmd.height;
				
				scrWin.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUp);
			}else {
				if (log!=null) {
					log("先按截屏键 Prt Scr");
				}
			}
			
		}
		
		static private function stage_mouseUp(e:MouseEvent):void 
		{
			if (downPos == null) return;
			var upPos:Point = new Point(scrWin.stage.mouseX, scrWin.stage.mouseY);
			if (upPos.x<downPos.x) {
				var temp:Number = upPos.x;
				upPos.x = downPos.x;
				downPos.x = temp;
			}
			if (upPos.y<downPos.y) {
				temp = upPos.y;
				upPos.y = downPos.y;
				downPos.y = temp;
			}
			var rect:Rectangle = new Rectangle(downPos.x, downPos.y, upPos.x - downPos.x, upPos.y - downPos.y);
			if(rect.width>0&&rect.height>0){
				var bmd:BitmapData = new BitmapData(rect.width,rect.height, false, 0);
				bmd.copyPixels(scrImage.bitmapData, rect, new Point);
				scrWin.minimize();
				scrWin.visible = false;
				downPos = null;
				onCutOver(bmd);
				downPos = null;
				
				stage.nativeWindow.alwaysInFront = false;
			}
		}
		
		static private function scrImageWrapper_mouseDown(e:MouseEvent):void 
		{
			downPos = new Point(scrWin.stage.mouseX, scrWin.stage.mouseY);
		}
		
		static private function stage_keyUp(e:KeyboardEvent):void 
		{
			if (e.keyCode==Keyboard.ESCAPE) {
				scrWin.minimize();
				scrWin.visible = false;
				downPos = null;
				
				stage.nativeWindow.alwaysInFront = false;
			}
		}
		
		static private function scrWin_closing(e:Event):void 
		{	
			e.preventDefault();
			scrWin.minimize();
			scrWin.visible = false;
			stage.nativeWindow.alwaysInFront = false;
			downPos = null;
		}
		
	}

}