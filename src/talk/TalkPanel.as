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
	import flash.events.NetStatusEvent;
	import flash.net.FileReference;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import ui.ImageTextArea;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TalkPanel extends Window
	{
		private var con:ImageTextArea;
		private var list:VBox;
		private var chatTest:ChatTest;
		public var input:TextArea;
		
		private var file:FileReference;
		public function TalkPanel(chatTest:ChatTest,parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, title:String="Window") 
		{
			super(parent, xpos, ypos, title);
			this.chatTest = chatTest;
			
			setSize(710, 560);
			
			var hbox:HBox = new HBox(this,5,5);
			var vbox:VBox = new VBox(hbox);
			con = new ImageTextArea(vbox);
			con.editable = false;
			con.html = true;
			con.setSize(600, 400);
			input = new TextArea(vbox);
			input.setSize(600, 100);
			
			var hbox2:HBox = new HBox(vbox);
			new PushButton(hbox2, 0, 0, "发送",chatTest.post);
			new PushButton(hbox2, 0, 0, "截图",cutScr);
			new PushButton(hbox2, 0, 0, "文件",sendFile);
			
			list = new VBox(vbox);
		}
		
		
		public function cutScr(e:Event):void {
			if(CONFIG::air) {
				ScrTool.startCut(chatTest.onCutOver, stage, addLine);
				addLine("此功能需要按prt scr截屏键");
			}else {
				file = new FileReference();
				file.addEventListener(Event.SELECT, file_select);
				file.browse();
			}
			
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
			chatTest.onCutOver(((e.currentTarget as LoaderInfo).content as Bitmap).bitmapData);
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
			list.removeChildren();
			for each(var e:NetStatusEvent in users) {
				var btn:PushButton=new PushButton(list, 0, 0, chatTest.e2name[e]||e.info.peerID);
				var menu:ContextMenu = new ContextMenu;
				var item:ContextMenuItem = new ContextMenuItem("送花");
				chatTest.item2e[item] = e;
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,item_select)
				menu.customItems = [item];
				btn.contextMenu = menu;
			}
		}
		
		private function item_select(e:Event):void 
		{
			var e2:NetStatusEvent = chatTest.item2e[e.currentTarget] as NetStatusEvent;
			addLine(chatTest.group.sendToNearest(chatTest.createMsg("送你一朵花",ChatTest.CODE_TXT), chatTest.group.convertPeerIDToGroupAddress(e2.info.peerID)));
		}
	}

}