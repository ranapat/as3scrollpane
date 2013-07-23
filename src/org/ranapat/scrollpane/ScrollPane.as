package org.ranapat.scrollpane {
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class ScrollPane extends Sprite {
		private var _background:Sprite;
		private var _content:Sprite;
		private var _mask:Sprite;
		private var _control:Sprite;
		
		private var _width:Number;
		private var _height:Number;
		
		private var _offsetToApply:Point;
		
		private var _mouseDownMode:Boolean;
		private var _mouseMovedMode:Boolean;
		private var _latestMouseDownPoint:Point;
		private var _scrollDirectionX:uint;
		private var _scrollDirectionY:uint;
		private var _latestMouseUpTarget:Object;
		
		public var settings:ScrollPaneSettings;
		
		public function ScrollPane(_settings:ScrollPaneSettings = null) {
			super();
			
			this.settings = _settings? _settings : new ScrollPaneSettings();
			
			this._background = new Sprite();
			this._content = new Sprite();
			this._mask = new Sprite();
			this._control = new Sprite();
			
			this.addEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage, false, 0, true);
		}
		
		override public function set width(value:Number):void {
			this._width = value;
			
			this.updateSize();
		}
		
		override public function get width():Number {
			return this._width;
		}
		
		override public function set height(value:Number):void {
			this._height = value;
			
			this.updateSize();
		}
		
		override public function get height():Number {
			return this._height;
		}
		
		override public function addChild(item:DisplayObject):DisplayObject {
			this._content.addChild(item);
			
			return item;
		}
		
		public function appendChild(item:DisplayObject, mode:uint = ScrollPaneConstants.APPEND_MODE_COLUMN):DisplayObject {
			if (this._content.numChildren == 0) {
				item.x = this.settings.paddingLeft;
				item.y = this.settings.paddingTop;
			} else {
				var prevItem:DisplayObject;
				
				if (mode == ScrollPaneConstants.APPEND_MODE_COLUMN) {
					prevItem = this._content.getChildAt(this._content.numChildren - 1);
					item.x = this.settings.paddingLeft;
					item.y = prevItem.y + prevItem.height + this.settings.ySpaceBetweenItems;
				} else if (mode == ScrollPaneConstants.APPEND_MODE_ROW) {
					prevItem = this._content.getChildAt(this._content.numChildren - 1);
					item.y = this.settings.paddingTop;
					item.x = prevItem.x + prevItem.width + this.settings.xSpaceBetweenItems;
				}
			}
			
			this.addChild(item);
			
			return item;
		}
		
		public function get background():Sprite {
			return this._background;
		}
		
		public function set scrollX(value:Number):void {
			this._content.x = -value;
		}
		
		public function get scrollX():Number {
			return -this._content.x;
		}
		
		public function set scrollY(value:Number):void {
			this._content.y = -value;
		}
		
		public function get scrollY():Number {
			return -this._content.y;
		}
		
		public function scrollXTo(value:Number, ease:Function = null, duration:Number = Number.NaN, easeParams:Array = null):void {
			this.ensureOffsetToApply(value, Number.NaN);
			TweenLite.to(
				this._content,
				!isNaN(duration)? duration : this.settings.defaultTweenDuration,
				{
					x: this._content.x + value,
					ease: ease != null? ease : Linear.easeNone,
					easeParams: easeParams,
					onComplete: this.handleTweenComplete
				}
			);
		}
		
		public function scrollYTo(value:Number, ease:Function = null, duration:Number = Number.NaN, easeParams:Array = null):void {
			this.ensureOffsetToApply(Number.NaN, value);
			TweenLite.to(
				this._content,
				!isNaN(duration)? duration : this.settings.defaultTweenDuration,
				{
					y: this._content.y + value,
					ease: ease != null? ease : Linear.easeNone,
					easeParams: easeParams,
					onComplete: this.handleTweenComplete
				}
			);
		}
		
		public function focus(item:DisplayObject, ease:Function = null, duration:Number = Number.NaN, easeParams:Array = null):void {
			if (item.parent == this._content) {
				if (!this.isItemFullyVisibile(item)) {
					var deltaX:Number = 0;
					var deltaY:Number = 0;
					
					if (item.x + this._content.x < 0) {
						deltaX = this.settings.paddingLeft - this._content.x - item.x;
					} else if (item.x + item.width + this._content.x > this.width) {
						deltaX = this.width - item.x - item.width - this._content.x - this.settings.paddingRight;
					}
					
					if (item.y + this._content.y < 0) {
						deltaY = this.settings.paddingTop - this._content.y - item.y;
					} else if (item.y + item.height + this._content.y > this.height) {
						deltaY = this.height - item.y - item.height - this._content.y - this.settings.paddingBottom;
					}
					
					this.ensureOffsetToApply(deltaX, deltaY);
					TweenLite.to(
						this._content,
						!isNaN(duration)? duration : this.settings.defaultTweenDuration,
						{
							x: this._content.x + deltaX,
							y: this._content.y + deltaY,
							ease: ease != null? ease : Linear.easeNone,
							easeParams: easeParams,
							onComplete: this.handleTweenComplete
						}
					);
				}
			}
		}
		
		public function snap(item:DisplayObject, mode:uint, ease:Function = null, duration:Number = Number.NaN, easeParams:Array = null):void {
			if (item.parent == this._content) {
				var destinationX:Number = Number.NaN;
				var destinationY:Number = Number.NaN;
				
				if (mode == ScrollPaneConstants.SNAP_TO_TOP) {
					destinationX = item.x - this.settings.paddingLeft;
					destinationY = -(item.y - this.settings.paddingTop);
				} else if (mode == ScrollPaneConstants.SNAP_TO_BOTTOM) {
					destinationX = item.x - this.settings.paddingLeft;
					destinationY = this.height - item.y - item.height - this.settings.paddingTop;
				}
				
				if (!isNaN(destinationX) && !isNaN(destinationY)) {
					this.ensureOffsetToApply(destinationX, destinationY);
					TweenLite.to(
						this._content,
						!isNaN(duration)? duration : this.settings.defaultTweenDuration,
						{
							x: destinationX,
							y: destinationY,
							ease: ease != null? ease : Linear.easeNone,
							easeParams: easeParams,
							onComplete: this.handleTweenComplete
						}
					);					
				}
			}
		}
		
		public function scroll(items:int, ease:Function = null, duration:Number = Number.NaN, easeParams:Array = null):void {
			var scrollTo:uint;
			if (items >= 0) {
				var latestItem:DisplayObject = this.latestFullyVisibleItem;
				var latestItemIndex:uint = this._content.getChildIndex(latestItem);
				
				scrollTo = (latestItemIndex + items + 1) > this._content.numChildren? (this._content.numChildren - 1) : (latestItemIndex + items);
			} else if (items < 0) {
				var firstItem:DisplayObject = this.firstFullyVisibleItem;
				var firstItemIndex:uint = this._content.getChildIndex(firstItem);
				
				scrollTo = (latestItemIndex - items) >= 0? (latestItemIndex - items) : 0;
			}
			
			this.focus(this._content.getChildAt(scrollTo), ease, duration, easeParams);
		}
		
		private function get firstPartiallyVisibleItem():DisplayObject {
			var length:uint = this._content.numChildren;
			for (var i:uint = 0; i < length; ++i) {
				if (this.isItemPartiallyVisibile(this._content.getChildAt(i))) {
					return this._content.getChildAt(i);
				}
			}
			return null;
		}
		
		private function get firstFullyVisibleItem():DisplayObject {
			var length:uint = this._content.numChildren;
			for (var i:uint = 0; i < length; ++i) {
				if (this.isItemFullyVisibile(this._content.getChildAt(i))) {
					return this._content.getChildAt(i);
				}
			}
			return null;
		}
		
		private function get latestPartiallyVisibleItem():DisplayObject {
			var alreadyVisible:Boolean;
			var length:uint = this._content.numChildren;
			for (var i:uint = 0; i < length; ++i) {
				if (!alreadyVisible && this.isItemPartiallyVisibile(this._content.getChildAt(i))) {
					alreadyVisible = true;
				} else if (alreadyVisible && !this.isItemPartiallyVisibile(this._content.getChildAt(i))) {
					return this._content.getChildAt(i - 1);
				}
			}
			return this._content.getChildAt(length - 1);
		}
		
		private function get latestFullyVisibleItem():DisplayObject {
			var alreadyVisible:Boolean;
			var length:uint = this._content.numChildren;
			for (var i:uint = 0; i < length; ++i) {
				if (!alreadyVisible && this.isItemFullyVisibile(this._content.getChildAt(i))) {
					alreadyVisible = true;
				} else if (alreadyVisible && !this.isItemFullyVisibile(this._content.getChildAt(i))) {
					return this._content.getChildAt(i - 1);
				}
			}
			return this._content.getChildAt(length - 1);
		}
		
		private function get totalHeight():Number {
			var total:Number = this.settings.paddingTop + this.settings.paddingBottom;
			var length:uint = this._content.numChildren;
			for (var i:uint = 0; i < length; ++i) {
				total += this._content.getChildAt(i).height;
			}
			return total;
		}
		
		private function isItemPartiallyVisibile(item:DisplayObject):Boolean {
			return item.parent == this._content
				&& item.x + item.width + this._content.x >= 0
				&& item.y + item.height + this._content.y >= 0
				&& item.x + this._content.x < this.width
				&& item.y + this._content.y < this.height
			;
		}
		
		private function isItemFullyVisibile(item:DisplayObject):Boolean {
			return item.parent == this._content
				&& item.x + this._content.x >= 0
				&& item.y + this._content.y >= 0
				&& item.x + item.width + this._content.x < this.width
				&& item.y + item.height + this._content.y < this.height
			;
		}
		
		private function updateSize():void {
			if (!isNaN(this.width) && !isNaN(this.height)) {
				this._background.graphics.beginFill(0xff0000, 1);
				this._background.graphics.drawRect(0, 0, this.width, this.height);
				this._background.graphics.endFill();
				
				this._content.graphics.drawRect(0, 0, this.width, this.height);
				
				this._mask.graphics.beginFill(0xffffff, 1);
				this._mask.graphics.drawRect(0, 0, this.width, this.height);
				this._mask.graphics.endFill();
				
				this._control.graphics.beginFill(0xff00ff, 0);
				this._control.graphics.drawRect(0, 0, this.width, this.height);
				this._control.graphics.endFill();
				
				super.width = this.width;
				super.height = this.height;
				
				this._background.width = this.width;
				this._content.width = this.width;
				this._mask.width = this.width;
				this._control.width = this.width;
				
				this._background.height = this.height;
				this._content.height = this.height;
				this._mask.height = this.height;
				this._control.height = this.height;
			}
		}
		
		private function ensureOffsetToApply(x:Number = Number.NaN, y:Number = Number.NaN):void {
			if (this._offsetToApply) {
				if (this.settings.queueTweens) {
					if (!isNaN(this._offsetToApply.x)) {
						this._content.x = this._offsetToApply.x;
					}
					if (!isNaN(this._offsetToApply.y)) {
						this._content.y = this._offsetToApply.y;
					}
				}
				
				this._offsetToApply = null;
			}
			
			this._offsetToApply = new Point(x, y);
		}
		
		private function getItemUnderPoint(x:Number, y:Number):DisplayObject {
			var length:uint = this._content.numChildren;
			var tmp:DisplayObject;
			var offsetX:Number = x - this._content.x;
			var offsetY:Number = y - this._content.y;
			for (var i:uint = 0; i < length; ++i) {
				tmp = this._content.getChildAt(i);
				
				if (
					tmp.x <= offsetX && tmp.x + tmp.width > offsetX
					&& tmp.y <= offsetY && tmp.y + tmp.height > offsetY
				) {
					return tmp;
				}
			}
			return null;
		}
		
		private function handleTweenComplete():void {
			this._offsetToApply = null;
		}
		
		private function handleAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage, false, 0, true);
			
			super.addChild(this._background);
			super.addChild(this._content);
			super.addChild(this._mask);
			super.addChild(this._control);
			
			this._background.x = 0;
			this._background.y = 0;
			
			this._content.x = 0;
			this._content.y = 0;
			
			this._mask.x = 0;
			this._mask.y = 0;
			
			this._control.x = 0;
			this._control.y = 0;
			
			this._content.mask = this._mask;
			//this._mask.visible = false;
			
			this.updateSize();
			
			this._control.addEventListener(MouseEvent.MOUSE_DOWN, this.handleControlMouseDown, false, 0, true);
			this._control.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleControlMouseUp, false, 0, true);
			this._control.addEventListener(MouseEvent.MOUSE_MOVE, this.handleControlMouseMove, false, 0, true);
			this._control.addEventListener(MouseEvent.CLICK, this.handleControlClick, false, 0, true);
		}
		
		private function handleRemovedFromStage(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage);
			
			this._control.removeEventListener(MouseEvent.MOUSE_DOWN, this.handleControlMouseDown);
			this._control.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleControlMouseUp);
			this._control.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleControlMouseMove);
			this._control.removeEventListener(MouseEvent.CLICK, this.handleControlClick);
		}
		
		private function handleControlMouseDown(e:MouseEvent):void {
			this._mouseDownMode = true;
			this._latestMouseDownPoint = new Point(e.localX, e.localY);
		}
		
		private function handleControlMouseUp(e:MouseEvent):void {
			if (this._mouseDownMode) {
				var item:DisplayObject;
				var snapTo:uint;
				if (this.totalHeight > this.height && this._content.numChildren > 1 && this.settings.scrollSnapToItems) {
					if (this._scrollDirectionY == ScrollPaneConstants.DIRECTION_DOWN) {
						item = this.firstPartiallyVisibleItem;
						snapTo = ScrollPaneConstants.SNAP_TO_TOP;
					} else if (this._scrollDirectionY == ScrollPaneConstants.DIRECTION_UP) {
						item = this.latestPartiallyVisibleItem;
						snapTo = ScrollPaneConstants.SNAP_TO_BOTTOM;
					} else {
						snapTo = ScrollPaneConstants.SNAP_TO_BOTTOM;
					}
				} else {
					if (this._content.y > 0) {
						item = this.firstPartiallyVisibleItem;
						snapTo = ScrollPaneConstants.SNAP_TO_TOP;
					} else if (this._content.y + this.totalHeight < this.height && this.totalHeight > this.height){
						item = this.latestPartiallyVisibleItem;
						snapTo = ScrollPaneConstants.SNAP_TO_BOTTOM;
					} else if (this._content.y + this.totalHeight < this.height && this.totalHeight <= this.height) {
						item = this.latestPartiallyVisibleItem;
						snapTo = ScrollPaneConstants.SNAP_TO_TOP;
					}
				}
				
				if (item) {
					this.snap(item, snapTo, null, this.settings.scrollAutoFocusTweenDuration);
				}
				
				if (this._mouseMovedMode) {
					this._latestMouseUpTarget = e.target;
				} else {
					this._latestMouseUpTarget = null;
				}
			} else {
				this._latestMouseUpTarget = null;
			}
			
			this._mouseDownMode = false;
			this._mouseMovedMode = false;
			this._latestMouseDownPoint = null;
			this._scrollDirectionX = ScrollPaneConstants.DIRECTION_NONE;
			this._scrollDirectionY = ScrollPaneConstants.DIRECTION_NONE;
		}
		
		private function handleControlMouseMove(e:MouseEvent):void {
			if (this._mouseDownMode) {
				this._mouseMovedMode = true;
				
				var deltaX:Number = this._latestMouseDownPoint.x - e.localX;
				var deltaY:Number = this._latestMouseDownPoint.y - e.localY;
				
				this._latestMouseDownPoint = new Point(e.localX, e.localY);
				
				this.scrollY += deltaY;
				
				if (!this.settings.scrollLockX) {
					this.scrollX += deltaX;
					if (deltaX > 0) {
						this._scrollDirectionX = ScrollPaneConstants.DIRECTION_LEFT;
					} else {
						this._scrollDirectionX = ScrollPaneConstants.DIRECTION_RIGHT;
					}
				}
				if (deltaY > 0) {
					this._scrollDirectionY = ScrollPaneConstants.DIRECTION_UP;
				} else {
					this._scrollDirectionY = ScrollPaneConstants.DIRECTION_DOWN;
				}
			}
		}
		
		private function handleControlClick(e:MouseEvent):void {
			if (!this._mouseDownMode && this._latestMouseUpTarget != e.target) {
				var objectOnClick:DisplayObject = this.getItemUnderPoint(e.localX, e.localY);
				if (objectOnClick) {
					objectOnClick.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, e.localX - objectOnClick.x, e.localY - objectOnClick.y));
				}
			}
			
			this._latestMouseUpTarget = null;
		}
		
	}

}