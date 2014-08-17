package talk {
	import com.bit101.components.CheckBox;
	import net.Group;
	import talk.ScrTool;
	import ui.ImageTextArea;
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
	CONFIG::air{
	import flash.desktop.NativeApplication;
	}
	/**
	 * ...
	 * @author lizhi
	 */
	public class ChatTest extends Sprite
	{
		public static const CODE_TXT:int = 1;
		public static const CODE_NAME:int = 2;
		public static const CODE_IMAGE:int = 3;
		public static const CODE_FILE:int = 4;
		
		private var wrapper:Sprite = new Sprite;
		
		private var conn:NetConnection;
		public var groups:Array=[];
		private var users:Array = [];
		private var loginui:Window;
		private var loginmask:Sprite = new Sprite;
		private var myname:String;
		private var mynameinput:InputText;
		private var group2talkPanel:Dictionary = new Dictionary;
		private var user2talkPanel:Dictionary = new Dictionary;
		private var talkPanel2group:Dictionary = new Dictionary;
		private var talkPanel2user:Dictionary = new Dictionary;
		private var isLan:CheckBox;
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
			
			
			loginmask.graphics.beginFill(0, .5);
			loginmask.graphics.drawRect(0, 0, 10000, 10000);
			wrapper.addChild(loginmask);
			loginui = new Window(wrapper, 100, 100, "登陆");
			var vbox:VBox = new VBox(loginui, 5, 5);
			mynameinput= new InputText(vbox,0,0,"test"+int(Math.random()*100));
			new PushButton(vbox, 0, 0, "登陆",loginin);
			isLan= new CheckBox(vbox, 0, 0, "lan");
			loginui.setSize(200, 200);
			
			CONFIG::air {
				stage.nativeWindow.addEventListener(Event.CLOSE, nativeWindow_close);
			}
		}
		
		CONFIG::air {
		private function nativeWindow_close(e:Event):void 
		{
			NativeApplication.nativeApplication.exit();
		}
		}
		
		private function loginin(e:Event):void {
			myname = mynameinput.text;
			conn = new NetConnection();
			conn.addEventListener(NetStatusEvent.NET_STATUS, conn_netStatus);
			if (isLan.selected) {
				conn.connect("rtmfp:");
			}else {
				conn.connect("rtmfp://p2p.rtmfp.net/fe0704d85bec8171e0f35e7a-4e39644da8a0/");
			}
			if (loginui.parent) {
				loginui.parent.removeChild(loginui);
			}
		}
		
		public function post(e:Event):void {
			var tp:TalkPanel = e.currentTarget as TalkPanel;
			var g:NetGroup = talkPanel2group[tp];
			if (!tp.isGroup) {
				var user:User = talkPanel2user[tp];
			}
			if(tp.input.text!=""&&conn){
				var msg:Object = createMsg(tp.input.text,CODE_TXT,tp.isGroup);
				if (tp.isGroup) {
					tp.addLine(g.sendToAllNeighbors(msg));
				}else {
					tp.addLine(g.sendToNearest(msg,g.convertPeerIDToGroupAddress(user.peerID)));
				}
				
				tp.input.text = "";
				tp.receive(users,"you", msg.time, CODE_TXT, msg.data);
			}
		}
		
		public function onCutOver(e:Event):void {
			var tp:TalkPanel = e.currentTarget as TalkPanel;
			var g:NetGroup = talkPanel2group[tp];
			if (!tp.isGroup) {
				var user:User = talkPanel2user[tp];
			}
			var bmd:BitmapData = tp.currentBmd;
			if (bmd) {
				var msg:Object = createMsg(bmd.encode(bmd.rect, new JPEGXREncoderOptions), CODE_IMAGE,tp.isGroup);
				if (tp.isGroup) {
					tp.addLine(g.sendToAllNeighbors(msg));
				}else {
					tp.addLine(g.sendToNearest(msg, g.convertPeerIDToGroupAddress(user.peerID)));
				}
				tp.receive(users,"you", msg.time, CODE_IMAGE, msg.data);
			}
		}
		
		public function createMsg(data:Object,code:int,isGroup:Boolean):Object {
			var msg:Object = { };
			msg.time = time;
			msg.data = data;
			msg.code = code;
			msg.isGroup = isGroup;
			if(conn&&conn.connected)
			msg.sender = conn.nearID;
			return msg;
		}
		
		public static function get time():Number {
			var data:Date = new Date;
			return data.time;
		}
		
		private function receive(e:NetStatusEvent, isGroup:Boolean):void {
			var code:int=e.info.message.code
			
			var tp:TalkPanel = group2talkPanel[e.currentTarget];
			
			var e2:User = getUser(e.info.message.sender);
			if (isGroup) {
				var tp2:TalkPanel = tp;
			}else {
				tp2 = getOrCreateUserPanel(e2, talkPanel2group[tp]);
				if (code != CODE_NAME) {
					tp2.show(wrapper);
				}
			}
			tp2.receive(users,e2.name, e.info.message.time, code, e.info.message.data,e2);
			if (code == CODE_NAME) tp.updateUserList(users);
		}
		
		private function getUser(peerID:String):User {
			for (var i:int = 0; i < users.length;i++ ) {
				var e2:User = users[i];
				if (e2.peerID == peerID) {
					return e2;
				}
			}
			return null;
		}
		
		
		private function conn_netStatus(e:NetStatusEvent):void 
		{
			trace(e.currentTarget);
			trace(JSON.stringify(e.info, null, 4));
			if (e.info.code == "NetConnection.Connect.Success") {
				var gs:GroupSpecifier = new GroupSpecifier("main");
				gs.postingEnabled = true;
				gs.routingEnabled = true;
				gs.serverChannelEnabled = true;
				gs.ipMulticastMemberUpdatesEnabled = true;
				gs.addIPMulticastAddress("225.225.0.1:30303");
				var g:NetGroup = new NetGroup(conn, gs.groupspecWithAuthorizations());
				g.addEventListener(NetStatusEvent.NET_STATUS, conn_netStatus);
				groups.push(g);
			}else if (e.info.code=="NetGroup.Connect.Success") {
				loginmask.graphics.clear();
				var talkPanel:TalkPanel = new TalkPanel(true, 0, 0, "群聊 your name(" + myname+")");
				talkPanel.show(wrapper);
				talkPanel.addEventListener(TalkPanel.POST_EVENT, post);
				talkPanel.addEventListener(TalkPanel.CUTOVER_EVENT,onCutOver);
				talkPanel.addEventListener(TalkPanel.CLICKUSER_EVENT,onClickUser);
				group2talkPanel[e.info.group] = talkPanel;
				talkPanel2group[talkPanel] = e.info.group;
			}else if (e.info.code=="NetGroup.Posting.Notify") {
				receive(e,true);
			}else if (e.info.code == "NetGroup.SendTo.Notify") {
				receive(e,e.info.message.isGroup);
			}else if (e.info.code == "NetGroup.Neighbor.Connect") {
				talkPanel = group2talkPanel[e.currentTarget];
				users.push(new User(e.info.peerID));
				talkPanel.updateUserList(users);
				var nameMsg:Object = createMsg(myname, CODE_NAME,false);
				talkPanel.addLine(e.currentTarget.sendToNearest(nameMsg, e.currentTarget.convertPeerIDToGroupAddress(e.info.peerID)));
			}else if (e.info.code == "NetGroup.Neighbor.Disconnect") {
				talkPanel = group2talkPanel[e.currentTarget];
				for (var i:int = 0; i < users.length;i++ ) {
					var e2:User = users[i];
					if (e2.peerID == e.info.peerID) {
						users.splice(i, 1);
						talkPanel.updateUserList(users);
						break;
					}
				}
			}
		}
		
		private function onClickUser(e:Event):void 
		{
			var tp:TalkPanel = e.currentTarget as TalkPanel;
			var user:User = tp.currentUser;
			getOrCreateUserPanel(user,talkPanel2group[tp]).show(wrapper);
		}
		
		private function getOrCreateUserPanel(user:User,group:NetGroup):TalkPanel {
			var utp:TalkPanel = user2talkPanel[user];
			if (utp==null) {
				utp = new TalkPanel(false, 0, 0, user.name);
				user2talkPanel[user] = utp;
				utp.addEventListener(TalkPanel.POST_EVENT, post);
				utp.addEventListener(TalkPanel.CUTOVER_EVENT, onCutOver);
				talkPanel2group[utp] = group;
				talkPanel2user[utp] = user;
			}
			return utp;
		}
		
	}

}