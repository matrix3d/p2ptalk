package talk {
	import com.bit101.components.CheckBox;
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	import flash.display.BitmapData;
	import flash.display.JPEGXREncoderOptions;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import net.event.UserEvent;
	import net.Group;
	import net.NetUser;
	import net.p2p.P2PGroup;
	import net.p2p.P2PConnecter;
	import net.Connecter;
	import net.tcp.TcpConnecter;
	import net.tcp.TcpServer;
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
		private var isTcp:CheckBox;
		private var serverIp:InputText;
		private var serverPort:InputText;
		private var server:Connecter;
		public function ChatTest() 
		{
			if (stage) 
			addedToStage(null);
			else
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void 
		{
			CONFIG::air{
				new TcpServer();
			}
			
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
			isTcp = new CheckBox(vbox, 0, 0, "tcp");
			serverIp = new InputText(vbox, 0, 0, "host");
			serverPort = new InputText(vbox, 0, 0, "4444");
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
			
			if (isTcp.selected) {
				server = new TcpConnecter(serverIp.text, int(serverPort.text));
			}else {
				if (isLan.selected) {
					server = new P2PConnecter("rtmfp:");
				}else {
					server = new P2PConnecter("rtmfp://p2p.rtmfp.net/fe0704d85bec8171e0f35e7a-4e39644da8a0/");
				}
			}
			
			if (loginui.parent) {
				loginui.parent.removeChild(loginui);
			}
			server.addEventListener(Event.CONNECT, server_connect);
			server.parser.receiveFun = receive;
			server.start();
			
			
		}
		
		private function server_connect(e:Event):void 
		{
			var g:Group = server.createGroupByName("main");
			g.addEventListener(Event.CONNECT, g_connect);
			g.addEventListener(UserEvent.ADD_USER, g_addUser);
			g.addEventListener(UserEvent.REMOVE_USER, g_removeUser);
			server.startGroup(g);
		}
		
		private function g_removeUser(e:UserEvent):void 
		{
			var talkPanel:TalkPanel = group2talkPanel[e.currentTarget];
			for (var i:int = 0; i < users.length;i++ ) {
				var e2:User = users[i];
				if (e2.user == e.user) {
					users.splice(i, 1);
					talkPanel.updateUserList(users);
					break;
				}
			}
		}
		
		private function g_addUser(e:UserEvent):void 
		{
			var talkPanel:TalkPanel = group2talkPanel[e.currentTarget];
			users.push(new User(e.user));
			talkPanel.updateUserList(users);
			var nameMsg:Object = createMsg(myname, CODE_NAME,false);
			(e.currentTarget as Group).sendTo(e.user,nameMsg);
		}
		
		private function g_connect(e:Event):void 
		{
			loginmask.graphics.clear();
			var talkPanel:TalkPanel = new TalkPanel(true, 0, 0, "群聊 your name(" + myname+")");
			talkPanel.show(wrapper);
			talkPanel.addEventListener(TalkPanel.POST_EVENT, post);
			talkPanel.addEventListener(TalkPanel.CUTOVER_EVENT, onCutOver);
			talkPanel.addEventListener(TalkPanel.FILEOVER_EVENT, talkPanel_fileoverEvent);
			talkPanel.addEventListener(TalkPanel.CLICKUSER_EVENT,onClickUser);
			group2talkPanel[e.currentTarget] = talkPanel;
			talkPanel2group[talkPanel] = e.currentTarget;
		}
		
		public function post(e:Event):void {
			var tp:TalkPanel = e.currentTarget as TalkPanel;
			var g:Group = talkPanel2group[tp];
			if (!tp.isGroup) {
				var user:User = talkPanel2user[tp];
			}
			if(tp.input.text!=""){
				var msg:Object = createMsg(tp.input.text,CODE_TXT,tp.isGroup);
				if (tp.isGroup) {
					g.post(msg);
				}else {
					if (server.getUser(user.user.id)==null) {
						tp.addLine("此用户已经离线");
					}
					g.sendTo(user.user,msg);
				}
				
				tp.input.text = "";
				tp.receive(users,"you", msg.time, CODE_TXT, msg.data);
			}
		}
		
		public function onCutOver(e:Event):void {
			var tp:TalkPanel = e.currentTarget as TalkPanel;
			var g:Group = talkPanel2group[tp];
			if (!tp.isGroup) {
				var user:User = talkPanel2user[tp];
			}
			var bmd:BitmapData = tp.currentBmd;
			if (bmd) {
				var msg:Object = createMsg(bmd.encode(bmd.rect, new JPEGXREncoderOptions), CODE_IMAGE,tp.isGroup);
				if (tp.isGroup) {
					g.post(msg);
				}else {
					g.sendTo(user.user,msg);
				}
				tp.receive(users,"you", msg.time, CODE_IMAGE, msg.data);
			}
		}
		
		
		
		private function talkPanel_fileoverEvent(e:Event):void 
		{
			var tp:TalkPanel = e.currentTarget as TalkPanel;
			var g:Group = talkPanel2group[tp];
			if (!tp.isGroup) {
				var user:User = talkPanel2user[tp];
			}
			var byte:ByteArray = tp.currentByte;
			if (byte) {
				var msg:Object = createMsg(byte, CODE_FILE,tp.isGroup);
				if (tp.isGroup) {
					g.post(msg);
				}else {
					g.sendTo(user.user,msg);
				}
				tp.receive(users,"you", msg.time, CODE_FILE, msg.data);
			}
		}
		
		public function createMsg(data:Object,code:int,isGroup:Boolean):Object {
			var msg:Object = { };
			msg.time = time;
			msg.data = data;
			msg.code = code;
			msg.isGroup = isGroup;
			return msg;
		}
		
		public static function get time():Number {
			var data:Date = new Date;
			return data.time;
		}
		
		private function receive(group:Group, user:NetUser, data:Object):void {
			var code:int=data.code
			
			var tp:TalkPanel = group2talkPanel[group];
			
			var e2:User = getUser(user);
			if (data.isGroup) {
				var tp2:TalkPanel = tp;
			}else {
				tp2 = getOrCreateUserPanel(e2, talkPanel2group[tp]);
				if (code != CODE_NAME) {
					tp2.show(wrapper);
				}
			}
			tp2.receive(users,e2.name, data.time, code, data.data,e2);
			if (code == CODE_NAME) tp.updateUserList(users);
		}
		
		private function getUser(user:NetUser):User {
			for (var i:int = 0; i < users.length;i++ ) {
				var e2:User = users[i];
				if (e2.user == user) {
					return e2;
				}
			}
			return null;
		}
		
		private function onClickUser(e:Event):void 
		{
			var tp:TalkPanel = e.currentTarget as TalkPanel;
			var user:User = tp.currentUser;
			getOrCreateUserPanel(user,talkPanel2group[tp]).show(wrapper);
		}
		
		private function getOrCreateUserPanel(user:User,group:Group):TalkPanel {
			var utp:TalkPanel = user2talkPanel[user];
			if (utp==null) {
				utp = new TalkPanel(false, 0, 0, user.name);
				user2talkPanel[user] = utp;
				utp.addEventListener(TalkPanel.POST_EVENT, post);
				utp.addEventListener(TalkPanel.CUTOVER_EVENT, onCutOver);
				utp.addEventListener(TalkPanel.FILEOVER_EVENT, talkPanel_fileoverEvent);
				talkPanel2group[utp] = group;
				talkPanel2user[utp] = user;
			}
			return utp;
		}
		
	}

}