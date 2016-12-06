package test 
{
	import com.bit101.components.HBox;
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.Security;
	import flash.system.System;
	import flash.text.TextField;
	import net.event.HTTPEvent;
	import net.http.HTTPHeaderLoader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestHTTPLoader extends Sprite
	{
		private var loader:HTTPHeaderLoader;
		private var tf:TextField;
		private var input:InputText;
		
		public function TestHTTPLoader() 
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var vbox:VBox = new VBox(this);
			var hbox:HBox = new HBox(vbox);
			input = new InputText(null,0,0,"https://www.baidu.com/a");
			input.width = 600;
			hbox.addChild(input);
			new PushButton(hbox, 0, 0, "go", ongo);
			tf = new TextField;
			
			tf.width = 800;
			tf.height = 400;
			vbox.addChild(tf);
			ongo(null);
		}
		
		private function ongo(e:Event):void 
		{
			
			loader = new HTTPHeaderLoader();
			loader.addEventListener(HTTPEvent.HEADER_COMPLETE, loader_headerComplete);
			loader.load(input.text);
		}
		
		private function loader_headerComplete(e:HTTPEvent):void 
		{
			tf.text=
			(JSON.stringify(loader.parser.headerObj,null,4));
		}
	}

}