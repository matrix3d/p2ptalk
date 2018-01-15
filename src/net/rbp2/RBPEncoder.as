package net.rbp2 
{
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import tool.ui.Files;
	/**
	 * resume from break-point
	 * @author lizhi
	 */
	public class RBPEncoder extends RBPEncoderBase
	{
		private var dirs:Array;
		private var dir:File;
		public function RBPEncoder(dirs:Array) 
		{
			this.dirs = dirs;
		}
		
		public function encode():void{
			isAsync = false;
			for each(dir in dirs){
				dofile(dir);
			}
		}
		
		private function dofile(f:File):void{
			if (f.isDirectory){
				for each(var sf:File in f.getDirectoryListing()){
					dofile(sf);
				}
			}else{
				var path:String = dir.getRelativePath(f);
				//trace(path);
				var outname:String = dir.name;
				if (path.length){
					outname+= "/" + path;
				}
				dobyte(Files.readByte(f), outname);
			}
		}
		
		
		
		public function encodeAsync():void{
			isAsync = true;
			for each(dir in dirs){
				dofile(dir);
			}
		}
	}

}