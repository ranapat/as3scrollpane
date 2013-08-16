package org.ranapat.scrollpane {
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Linear;
	
	public class ScrollPaneSettings {
		public static var PADDING_TOP:Number = 10;
		public static var PADDING_RIGHT:Number = 10;
		public static var PADDING_BOTTOM:Number = 10;
		public static var PADDING_LEFT:Number = 10;
		
		public static var SCROLL_MULTIPLIER:Number = 3;
		
		public static var X_SPACE_BETWEEN_ITEMS:Number = 0;
		public static var Y_SPACE_BETWEEN_ITEMS:Number = 0;

		public static var DEFAULT_TWEEN_EASE:Function = Linear.easeNone;
		public static var DEFAULT_TWEEN_DURATION:Number = .1;

		public static var SCROLL_AUTO_FOCUS_TWEEN_EASE:Function = Elastic.easeOut;
		public static var SCROLL_AUTO_FOCUS_TWEEN_DURATION:Number = 1.3;
		
		public static var QUEUE_TWEENS:Boolean = true;
		public static var SCROLL_LOCK_X:Boolean = true;
		public static var SCROLL_LOCK_Y:Boolean = false;
		public static var SCROLL_SNAP_TO_ITEMS:Boolean = false;
		
		public static var DRAG_SCROLL:Boolean = false;
		public static var DRAG_SCROLL_AUTO:Boolean = true;
		
		public static var POST_FORCE_MIN_DELTA:Number = 8;
		public static var POST_FORCE_ONE_ITEM_SIZE:Number = 10;
		
		public var paddingTop:Number;
		public var paddingRight:Number;
		public var paddingBottom:Number;
		public var paddingLeft:Number;
		
		public var scrollMultiplier:Number;
		
		public var xSpaceBetweenItems:Number;
		public var ySpaceBetweenItems:Number;

		public var defaultTweenEase:Function;
		public var defaultTweenDuration:Number;

		public var scrollAutoFocusTweenEase:Function;
		public var scrollAutoFocusTweenDuration:Number;
		
		public var queueTweens:Boolean;
		public var scrollLockX:Boolean;
		public var scrollLockY:Boolean;
		public var scrollSnapToItems:Boolean;
		
		public var dragScroll:Boolean;
		public var dragScrollAuto:Boolean;
		
		public var postForceMinDelta:Number;
		public var postForceOneItemSize:Number;
		
		public function ScrollPaneSettings() {
			this.paddingTop = ScrollPaneSettings.PADDING_TOP;
			this.paddingRight = ScrollPaneSettings.PADDING_RIGHT;
			this.paddingBottom = ScrollPaneSettings.PADDING_BOTTOM;
			this.paddingLeft = ScrollPaneSettings.PADDING_LEFT;
			
			this.scrollMultiplier = ScrollPaneSettings.SCROLL_MULTIPLIER;
			
			this.xSpaceBetweenItems = ScrollPaneSettings.X_SPACE_BETWEEN_ITEMS;
			this.ySpaceBetweenItems = ScrollPaneSettings.Y_SPACE_BETWEEN_ITEMS;

			this.defaultTweenEase = ScrollPaneSettings.DEFAULT_TWEEN_EASE;
			this.defaultTweenDuration = ScrollPaneSettings.DEFAULT_TWEEN_DURATION;

			this.scrollAutoFocusTweenEase = ScrollPaneSettings.SCROLL_AUTO_FOCUS_TWEEN_EASE;
			this.scrollAutoFocusTweenDuration = ScrollPaneSettings.SCROLL_AUTO_FOCUS_TWEEN_DURATION;
			
			this.queueTweens = ScrollPaneSettings.QUEUE_TWEENS;
			this.scrollLockX = ScrollPaneSettings.SCROLL_LOCK_X;
			this.scrollLockY = ScrollPaneSettings.SCROLL_LOCK_Y;
			this.scrollSnapToItems = ScrollPaneSettings.SCROLL_SNAP_TO_ITEMS;
			
			this.dragScroll = ScrollPaneSettings.DRAG_SCROLL;
			this.dragScrollAuto = ScrollPaneSettings.DRAG_SCROLL_AUTO;
			
			this.postForceMinDelta = ScrollPaneSettings.POST_FORCE_MIN_DELTA;
			this.postForceOneItemSize = ScrollPaneSettings.POST_FORCE_ONE_ITEM_SIZE;
		}
	}

}