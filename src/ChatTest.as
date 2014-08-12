package  
{
	import com.bit101.components.HBox;
	import com.bit101.components.InputText;
	import com.bit101.components.List;
	import com.bit101.components.PushButton;
	import com.bit101.components.ScrollPane;
	import com.bit101.components.Style;
	import com.bit101.components.TextArea;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.JPEGXREncoderOptions;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.NetStatusEvent;
	import flash.net.FileReference;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ChatTest extends Sprite
	{
		private static const CODE_TXT:int = 1;
		private static const CODE_NAME:int = 2;
		private static const CODE_IMAGE:int = 3;
		private static const CODE_FILE:int = 4;
		
		private var wrapper:Sprite = new Sprite;
		
		private var conn:NetConnection;
		private var group:NetGroup;
		private var con:ImageTextArea;
		private var input:TextArea;
		private var list:VBox;
		private var users:Array = [];
		private var e2name:Dictionary = new Dictionary;
		private var item2e:Dictionary = new Dictionary;
		
		
		private var loginui:Window;
		private var loginmask:Sprite = new Sprite;
		private var myname:String;
		private var mynameBtn:PushButton;
		private var mynameinput:InputText;
		private var file:FileReference;
		public function ChatTest() 
		{
			if (stage) 
			addedToStage(null);
			else
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			
			Style.embedFonts = false;
			Style.fontName = "宋体";
			Style.fontSize = 12;
			addChild(wrapper);
			
			var hbox:HBox = new HBox(wrapper);
			var vbox:VBox = new VBox(hbox);
			mynameBtn = new PushButton(vbox);
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
			
			vbox = new VBox(hbox);
			list = new VBox(vbox);
			
			loginmask.graphics.beginFill(0, .5);
			loginmask.graphics.drawRect(0, 0, 10000, 10000);
			wrapper.addChild(loginmask);
			loginui = new Window(wrapper, 100, 100, "登陆");
			vbox = new VBox(loginui, 5, 5);
			mynameinput= new InputText(vbox,0,0,"test"+int(Math.random()*100));
			new PushButton(vbox, 0, 0, "登陆",loginin);
			loginui.setSize(200, 200);
			
			stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyDown);
			
			addLine("open source flash p2p talk tool. https://github.com/matrix3d/p2ptalk");
		}
		
		private function stage_keyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode==Keyboard.ENTER&&e.ctrlKey) {
				post(null);
			}
		}
		
		private function loginin(e:Event):void {
			myname = mynameinput.text;
			mynameBtn.label = myname;
			conn = new NetConnection();
			conn.addEventListener(NetStatusEvent.NET_STATUS, conn_netStatus);
			//conn.connect("rtmfp:");
			conn.connect("rtmfp://p2p.rtmfp.net/fe0704d85bec8171e0f35e7a-4e39644da8a0/");
			if (loginui.parent) {
				loginui.parent.removeChild(loginui);
			}
		}
		
		private function post(e:Event):void {
			if(input.text!=""&&conn){
				var msg:Object = createMsg(input.text,CODE_TXT);
				addLine(group.sendToAllNeighbors(msg));
				input.text = "";
				
				receive2("you", msg.time, CODE_TXT, msg.data);
			}
		}
		
		private function cutScr(e:Event):void {
			if(CONFIG::air) {
				ScrTool.startCut(onCutOver, stage, addLine);
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
			onCutOver(((e.currentTarget as LoaderInfo).content as Bitmap).bitmapData);
		}
		
		private function onCutOver(bmd:BitmapData):void {
			if (bmd) {
				var msg:Object = createMsg(bmd.encode(bmd.rect,new JPEGXREncoderOptions),CODE_IMAGE);
				addLine(group.sendToAllNeighbors(msg));
				receive2("you", msg.time, CODE_IMAGE, msg.data);
			}
		}
		
		private function sendFile(e:Event):void {
			addLine("该功能暂未开放");
		}
		private function createMsg(data:Object,code:int):Object {
			var msg:Object = { };
			msg.time = time;
			msg.data = data;
			msg.code = code;
			if(conn&&conn.connected)
			msg.sender = conn.nearID;
			return msg;
		}
		
		private function get time():Number {
			var data:Date = new Date;
			return data.time;
		}
		
		private function receive(e:NetStatusEvent):void {
			var e2:NetStatusEvent = getUser(e.info.message.sender);
			receive2((e2name[e2] || e.info.message.sender), e.info.message.time, e.info.message.code, e.info.message.data,e2);
		}
		
		private function receive2(name:String, time:Number, code:int, data:Object,e2:NetStatusEvent=null):void {
			var date:Date = new Date(time);
			addLine("<font color='#0000FF'>["+date.toLocaleTimeString()+"] ["+name+"] [延迟 " + (this.time-time)+"]</font>");
			switch(code) {
				case CODE_TXT:
					addLine("<textformat indent='20'><font color='#000000'>"+data+"</font><br></textformat>");
					break;
				case CODE_NAME:
					e2name[e2] = data;
					updateUserList();
					break;
				case CODE_IMAGE:
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
		
		private function getUser(peerID:String):NetStatusEvent {
			for (var i:int = 0; i < users.length;i++ ) {
				var e2:NetStatusEvent = users[i];
				if (e2.info.peerID == peerID) {
					return e2;
				}
			}
			return null;
		}
		
		public function addLine(txt:String):void {
			con.text +="<p>"+ txt + "</p>";
			con.draw();
			con.textField.scrollV = con.textField.maxScrollV;
		}
		public function addImage(bmd:BitmapData):void {
			con.addImage(new Bitmap(bmd), bmd.width, bmd.height,20);
			con.draw();
			con.textField.scrollV = con.textField.maxScrollV;
		}
		private function conn_netStatus(e:NetStatusEvent):void 
		{
			trace(e.currentTarget);
			trace(JSON.stringify(e.info, null, 4));
			if (e.info.code == "NetConnection.Connect.Success") {
				var gs:GroupSpecifier = new GroupSpecifier("test1");
				gs.postingEnabled = true;
				gs.routingEnabled = true;
				gs.serverChannelEnabled = true;
				gs.ipMulticastMemberUpdatesEnabled = true;
				gs.addIPMulticastAddress("225.225.0.1:30303");
				group = new NetGroup(conn, gs.groupspecWithAuthorizations());
				group.addEventListener(NetStatusEvent.NET_STATUS, conn_netStatus);
			}else if (e.info.code=="NetGroup.Connect.Success") {
				loginmask.graphics.clear();
			}else if (e.info.code=="NetGroup.Posting.Notify") {
				receive(e);
			}else if (e.info.code == "NetGroup.SendTo.Notify") {
				receive(e);
			}else if (e.info.code=="NetGroup.Neighbor.Connect") {
				users.push(e);
				updateUserList();
				var nameMsg:Object = createMsg(myname, CODE_NAME);
				addLine(group.sendToNearest(nameMsg, group.convertPeerIDToGroupAddress(e.info.peerID)));
			}else if (e.info.code=="NetGroup.Neighbor.Disconnect") {
				for (var i:int = 0; i < users.length;i++ ) {
					var e2:NetStatusEvent = users[i];
					if (e2.info.peerID == e.info.peerID) {
						users.splice(i, 1);
						updateUserList();
						break;
					}
				}
			}
		}
		
		private function updateUserList():void {
			list.removeChildren();
			for each(var e:NetStatusEvent in users) {
				var btn:PushButton=new PushButton(list, 0, 0, e2name[e]||e.info.peerID);
				var menu:ContextMenu = new ContextMenu;
				var item:ContextMenuItem = new ContextMenuItem("送花");
				item2e[item] = e;
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,item_select)
				menu.customItems = [item];
				btn.contextMenu = menu;
			}
		}
		
		private function item_select(e:Event):void 
		{
			var e2:NetStatusEvent = item2e[e.currentTarget] as NetStatusEvent;
			addLine(group.sendToNearest(createMsg("送你一朵花",CODE_TXT), group.convertPeerIDToGroupAddress(e2.info.peerID)));
		}
	}

}