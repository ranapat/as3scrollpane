package org.ranapat.scrollpane {
	import flash.events.Event;
	
	public class ScrollPaneEvent extends Event {
		public static const SCROLL_X_CHANGED:String = "scrollXChanged";
		public static const SCROLL_Y_CHANGED:String = "scrollYChanged";
		
		public var offset:Number;
		
		public function ScrollPaneEvent(type:String, offset:Number) {
			super(type);
			
			this.offset = offset;
		}
		
	}

}