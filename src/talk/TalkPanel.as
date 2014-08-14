package talk {
	import com.bit101.components.HBox;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.JPEGXREncoderOptions;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.net.FileReference;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import ui.ImageTextArea;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TalkPanel extends Window
	{
		public static const POST_EVENT:String = "postevent";
		public static const CUTOVER_EVENT:String = "cutoverevent";
		public static const CLICKUSER_EVENT:String = "clickUserEvent";
		
		private var con:ImageTextArea;
		private var list:VBox;
		public var input:TextArea;
		public var btn2user:Dictionary = new Dictionary;
		private var file:FileReference;
		public var isGroup:Boolean;
		
		public var currentBmd:BitmapData;
		public var currentUser:User;
		public function TalkPanel(isGroup:Boolean,parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, title:String="Window") 
		{
			super(parent, xpos, ypos, title);
			this.isGroup = isGroup;
			
			setSize(720, 560);
			
			var hbox:HBox = new HBox(this,5,5);
			var vbox:VBox = new VBox(hbox);
			con = new ImageTextArea(vbox);
			con.editable = false;
			con.html = true;
			con.setSize(600, 400);
			input = new TextArea(vbox);
			input.setSize(600, 100);
			
			var hbox2:HBox = new HBox(vbox);
			new PushButton(hbox2, 0, 0, "发送",post);
			new PushButton(hbox2, 0, 0, "截图",cutScr);
			new PushButton(hbox2, 0, 0, "文件",sendFile);
			
			list = new VBox(hbox);
			
			addLine("open source flash p2p talk tool. https://github.com/matrix3d/p2ptalk");
			
			if(stage)
			addedToStage(null)
			else
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			if (!isGroup) {
				hasCloseButton = true;
				_closeButton.addEventListener(MouseEvent.CLICK, closeButton_click);
			}
		}
		
		private function closeButton_click(e:MouseEvent):void 
		{
			if (parent) {
				parent.removeChild(this);
			}
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyDown);
		}
		
		private function stage_keyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode==Keyboard.ENTER&&e.ctrlKey) {
				post(null);
			}
		}
		
		private function post(e:Event):void {
			dispatchEvent(new Event(POST_EVENT));
		}
		
		public function cutScr(e:Event):void {
			if(CONFIG::air) {
				ScrTool.startCut(onCutOver, stage, addLine);
				addLine("此功能需要按prt scr截屏键");
			}else {
				file = new FileReference();
				file.addEventListener(Event.SELECT, file_select);
				file.browse();
			}
		}
		
		private function onCutOver(bmd:BitmapData):void {
			currentBmd = bmd;
			dispatchEvent(new Event(CUTOVER_EVENT));
		}
		
		private function file_select(e:Event):void 
		{
			var file:FileReference = e.currentTarget as FileReference;
			file.load();
			file.addEventListener(Event.COMPLETE, file_complete);
		}
		
		private function file_complete(e:Event):void 
		{
			var file:FileReference = e.currentTarget as FileReference;
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete_cut);
			loader.loadBytes(file.data);
		}
		
		private function loader_complete_cut(e:Event):void 
		{
			onCutOver(((e.currentTarget as LoaderInfo).content as Bitmap).bitmapData);
		}
		
		public function sendFile(e:Event):void {
			addLine("该功能暂未开放");
		}
		
		public function addLine(txt:String):void {
			con.text +="<p>"+ txt.replace(/\r/g,"<br>") + "</p>";
			con.draw();
			con.textField.scrollV = con.textField.maxScrollV;
		}
		public function addImage(bmd:BitmapData):void {
			con.addImage(new Bitmap(bmd), bmd.width, bmd.height,20);
			con.draw();
			con.textField.scrollV = con.textField.maxScrollV;
		}
		
		public function updateUserList(users:Array):void {
			if (!isGroup) return;
			list.removeChildren();
			for each(var e:User in users) {
				var btn:PushButton = new PushButton(list, 0, 0, e.name,btnclick);
				btn2user[btn] = e;
			}
		}
		
		private function btnclick(e:Event):void 
		{
			currentUser = btn2user[e.currentTarget];
			dispatchEvent(new Event(CLICKUSER_EVENT));
		}
		
		public function receive(users:Array,name:String, time:Number, code:int, data:Object, e2:User = null):void {
			var date:Date = new Date(time);
			addLine("<font color='#0000FF'>["+date.toLocaleTimeString()+"] ["+name+"] [延迟 " + (ChatTest.time-time)+"]</font>");
			switch(code) {
				case ChatTest.CODE_TXT:
					addLine("<textformat indent='20'><font color='#000000'>"+data+"</font><br></textformat>");
					break;
				case ChatTest.CODE_NAME:
					e2.name = data+"";
					updateUserList(users);
					if (!isGroup) {
						title = e2.name;
					}
					break;
				case ChatTest.CODE_IMAGE:
					var loader:Loader = new Loader;
					loader.loadBytes(data as ByteArray);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
					break;
			}
		}
		
		private function loader_complete(e:Event):void 
		{
			var con:LoaderInfo = e.currentTarget as LoaderInfo;
			var image:Bitmap = (con.content as Bitmap);
			addImage(image.bitmapData);
		}
	}

}