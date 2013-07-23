package org.ranapat.scrollpane {
	
	public class ScrollPaneSettings {
		public static var PADDING_TOP:Number = 10;
		public static var PADDING_RIGHT:Number = 10;
		public static var PADDING_BOTTOM:Number = 10;
		public static var PADDING_LEFT:Number = 10;
		
		public static var X_SPACE_BETWEEN_ITEMS:Number = 10;
		public static var Y_SPACE_BETWEEN_ITEMS:Number = 10;
		
		public static var DEFAULT_TWEEN_DURATION:Number = 2;
		public static var SCROLL_AUTO_FOCUS_TWEEN_DURATION:Number = .1;
		
		public static var QUEUE_TWEENS:Boolean = true;
		public static var SCROLL_LOCK_X:Boolean = true;
		public static var SCROLL_LOCK_Y:Boolean = false;
		public static var SCROLL_SNAP_TO_ITEMS:Boolean = true;
		
		public var paddingTop:Number;
		public var paddingRight:Number;
		public var paddingBottom:Number;
		public var paddingLeft:Number;
		
		public var xSpaceBetweenItems:Number;
		public var ySpaceBetweenItems:Number;
		
		public var defaultTweenDuration:Number;
		public var scrollAutoFocusTweenDuration:Number;
		
		public var queueTweens:Boolean;
		public var scrollLockX:Boolean = true;
		public var scrollLockY:Boolean = true;
		public var scrollSnapToItems:Boolean = true;
		
		public function ScrollPaneSettings() {
			this.paddingTop = ScrollPaneSettings.PADDING_TOP;
			this.paddingRight = ScrollPaneSettings.PADDING_RIGHT;
			this.paddingBottom = ScrollPaneSettings.PADDING_BOTTOM;
			this.paddingLeft = ScrollPaneSettings.PADDING_LEFT;
			
			this.xSpaceBetweenItems = ScrollPaneSettings.X_SPACE_BETWEEN_ITEMS;
			this.ySpaceBetweenItems = ScrollPaneSettings.Y_SPACE_BETWEEN_ITEMS;
			
			this.defaultTweenDuration = ScrollPaneSettings.DEFAULT_TWEEN_DURATION;
			this.scrollAutoFocusTweenDuration = ScrollPaneSettings.SCROLL_AUTO_FOCUS_TWEEN_DURATION;
			
			this.queueTweens = ScrollPaneSettings.QUEUE_TWEENS;
			this.scrollLockX = ScrollPaneSettings.SCROLL_LOCK_X;
			this.scrollLockY = ScrollPaneSettings.SCROLL_LOCK_Y;
			this.scrollSnapToItems = ScrollPaneSettings.SCROLL_SNAP_TO_ITEMS;
		}
	}

}