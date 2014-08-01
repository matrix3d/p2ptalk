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
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
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
		private var con:TextArea;
		private var input:TextArea;
		private var list:VBox;
		private var users:Array = [];
		private var e2name:Dictionary = new Dictionary;
		private var item2e:Dictionary = new Dictionary;
		
		
		private var loginui:Window;
		private var myname:String;
		private var mynameBtn:PushButton;
		private var mynameinput:InputText;
		private var sp:ScrollPane;
		private var imageWrapper:Sprite = new Sprite;
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
			con = new TextArea(vbox);
			con.setSize(400, 250);
			input = new TextArea(vbox);
			input.setSize(400, 100);
			
			var hbox2:HBox = new HBox(vbox);
			new PushButton(hbox2, 0, 0, "发送",post);
			new PushButton(hbox2, 0, 0, "截图",cutScr);
			new PushButton(hbox2, 0, 0, "文件",sendFile);
			
			vbox = new VBox(hbox);
			list = new VBox(vbox);
			
			loginui = new Window(wrapper, 100, 100, "登陆");
			vbox = new VBox(loginui, 5, 5);
			mynameinput= new InputText(vbox,0,0,"test"+int(Math.random()*100));
			new PushButton(vbox, 0, 0, "登陆",loginin);
			loginui.setSize(200, 200);
			
			sp = new ScrollPane(this, 550);
			sp.setSize(250, 420)
			sp.addChild(imageWrapper);
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
			}
		}
		
		private function cutScr(e:Event):void {
			if(CONFIG::air) {
				ScrTool.startCut(onCutOver,stage,addLine);
			}else {
				addLine("网页版不支持此功能");
			}
			
		}
		
		private function onCutOver(bmd:BitmapData):void {
			if (bmd) {
				var msg:Object = createMsg(bmd.encode(bmd.rect,new JPEGEncoderOptions),CODE_IMAGE);
				addLine(group.sendToAllNeighbors(msg));
			}
		}
		
		private function sendFile(e:Event):void {
			
		}
		private function createMsg(data:Object,code:int):Object {
			var msg:Object = { };
			msg.time = time;
			msg.data = data;
			msg.code = code;
			msg.sender = conn.nearID;
			return msg;
		}
		
		private function get time():Number {
			var data:Date = new Date;
			return data.time;
		}
		
		private function receive(e:NetStatusEvent):void {
			var e2:NetStatusEvent = getUser(e.info.message.sender);
			var date:Date = new Date(e.info.message.time);
			addLine("["+date.toLocaleTimeString()+"] ["+(e2name[e2]||e.info.message.sender)+"] [延迟 " + (time-e.info.message.time)+"]");
			switch(e.info.message.code) {
				case CODE_TXT:
					addLine(e.info.message.data+"\n");
					break;
				case CODE_NAME:
					e2name[e2] = e.info.message.data;
					updateUserList();
					break;
				case CODE_IMAGE:
					var loader:Loader = new Loader;
					loader.loadBytes(e.info.message.data as ByteArray);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
					break;
			}
		}
		
		private function loader_complete(e:Event):void 
		{
			var con:LoaderInfo = e.currentTarget as LoaderInfo;
			var image:Bitmap = (con.content as Bitmap);
			image.y = imageWrapper.height + 20;
			imageWrapper.addChild(image);
			sp.draw();
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
			con.text += txt + "\n";
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