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
	import flash.events.ProgressEvent;
	import flash.system.Security;
	import flash.system.System;
	import flash.text.TextField;
	import net.event.HTTPEvent;
	import net.http.HTTPHeaderLoader;
	import net.http.HTTPLoader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestHTTPLoader extends Sprite
	{
		private var loader:HTTPLoader;
		private var headerTF:TextField;
		private var contentTF:TextField;
		private var input:InputText;
		
		public function TestHTTPLoader() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var vbox:VBox = new VBox(this);
			var hbox:HBox = new HBox(vbox);
			input = new InputText(null,0,0,"https://www.baidu.com/a");
			input.width = 600;
			hbox.addChild(input);
			new PushButton(hbox, 0, 0, "go", ongo);
			
			headerTF = new TextField;
			headerTF.width = 800;
			headerTF.height = 200;
			vbox.addChild(headerTF);
			
			contentTF = new TextField;
			contentTF.width = 800;
			contentTF.height = 300;
			vbox.addChild(contentTF);
			
			ongo(null);
		}
		
		private function ongo(e:Event):void 
		{
			
			loader = new HTTPLoader();
			loader.addEventListener(HTTPEvent.HEADER_COMPLETE, loader_headerComplete);
			loader.addEventListener(ProgressEvent.PROGRESS, loader_progress);
			loader.load(input.text);
		}
		
		private function loader_progress(e:ProgressEvent):void 
		{
			contentTF.text = loader.parser.content;
		}
		
		private function loader_headerComplete(e:HTTPEvent):void 
		{
			headerTF.text=
			(JSON.stringify(loader.parser.headerObj,null,4));
		}
	}

}