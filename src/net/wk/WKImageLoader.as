package net.wk 
{
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class WKImageLoader extends Loader
	{
		
		public function WKImageLoader() 
		{
			
		}
		
		override public function loadBytes(bytes:ByteArray, context:LoaderContext = null):void 
		{
			if (bytes.shareable){
				
			}else{
				super.loadBytes(bytes, context);
			}
		}
	}

}