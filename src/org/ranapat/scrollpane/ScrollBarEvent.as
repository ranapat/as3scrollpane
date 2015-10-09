package org.ranapat.scrollpane {
	import flash.events.Event;
	
	public class ScrollBarEvent extends Event {
		public static const SCROLL_CHANGED:String = "scrollChanged";
		
		public var offset:Number;
		
		public function ScrollBarEvent(type:String, offset:Number) {
			super(type);
			
			this.offset = offset;
		}
		
	}

}