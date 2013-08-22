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
		
		private var _mouseDownStageMode:Boolean;
		private var _mouseMovedStageMode:Boolean;
		private var _mouseDownMode:Boolean;
		private var _mouseMovedMode:Boolean;
		private var _latestMouseDownPoint:Point;
		private var _scrollDirectionX:uint;
		private var _scrollDirectionY:uint;
		private var _latestMouseUpTarget:Object;
		private var _latestScrollDeltaX:Number;
		private var _latestScrollDeltaY:Number;
		private var _postScrollFix:Boolean;
		
		private var _scrollbars:Vector.<ScrollBar>;
		
		private var mode:uint;
		
		public var settings:ScrollPaneSettings;
		
		public function ScrollPane(_mode:uint = ScrollPaneConstants.APPEND_MODE_COLUMN, _settings:ScrollPaneSettings = null) {
			super();
			
			this.mode = _mode;
			this.settings = _settings? _settings : new ScrollPaneSettings();
			this._scrollbars = new Vector.<ScrollBar>();
			
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
		
		override public function getChildAt(index:int):DisplayObject {
			return this._content.getChildAt(index);
		}
		
		override public function addChild(item:DisplayObject):DisplayObject {
			this._content.addChild(item);
			
			this.updateScrollBars();
			
			return item;
		}
		
		override public function removeChild(item:DisplayObject):DisplayObject {
			this._content.removeChild(item);

			this.scrollX = 0;
			this.scrollY = 0;
			this.updateScrollBars();

			return item;
		}
		
		override public function get numChildren():int {
			return this._content.numChildren;
		}
		
		public function removeAllChildren():Vector.<DisplayObject> {
			var result:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			while (this.numChildren > 0) {
				result.push(this.removeChild(this.getChildAt(this.numChildren - 1)));
			}
			return result;
		}
		
		public function appendChild(item:DisplayObject):DisplayObject {
			if (this._content.numChildren == 0) {
				item.x = this.settings.paddingLeft;
				item.y = this.settings.paddingTop;
			} else {
				var prevItem:DisplayObject;
				
				if (this.mode == ScrollPaneConstants.APPEND_MODE_COLUMN) {
					prevItem = this._content.getChildAt(this._content.numChildren - 1);
					item.x = this.settings.paddingLeft;
					item.y = prevItem.y + prevItem.height + this.settings.ySpaceBetweenItems;
				} else if (this.mode == ScrollPaneConstants.APPEND_MODE_ROW) {
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
		
		public function set scrollXPercents(value:uint):void {
			this.scrollX = value * (this.totalWidth - this.width) / 100;
		}
		
		public function get scrollXPercents():uint {
			var result:uint = this.scrollX / (this.totalWidth - this.width) * 100;
			return scrollX < 0? 0 : result > 100? 100 : result;
		}
		
		public function get visibilityXProportion():uint {
			var result:uint = this.width / this.totalWidth * 100;
			return result > 100? 100 : result;
		}
		
		public function set scrollY(value:Number):void {
			this._content.y = -value;
		}
		
		public function get scrollY():Number {
			return -this._content.y;
		}
		
		public function set scrollYPercents(value:uint):void {
			this.scrollY = value * (this.totalHeight - this.height) / 100;
		}
		
		public function get scrollYPercents():uint {
			var result:uint = this.scrollY / (this.totalHeight - this.height) * 100;
			return this.scrollY < 0? 0 : result > 100? 100 : result;
		}
		
		public function get visibilityYProportion():uint {
			var result:uint = this.height / this.totalHeight * 100;
			return result > 100? 100 : result;
		}
		
		public function scrollXTo(value:Number, ease:Function = null, duration:Number = Number.NaN, easeParams:Array = null):void {
			this.ensureOffsetToApply(this._content.x + value, Number.NaN);
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
			this.ensureOffsetToApply(Number.NaN, this._content.y + value);
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
					
					this.ensureOffsetToApply(this._content.x + deltaX, this._content.y + deltaY);
					TweenLite.to(
						this._content,
						!isNaN(duration)? duration : this.settings.defaultTweenDuration,
						{
							x: this._content.x + deltaX,
							y: this._content.y + deltaY,
							ease: ease != null? ease : settings.defaultTweenEase,
							easeParams: easeParams,
							onComplete: this.handleTweenComplete
						}
					);
				}
			}
		}
		
		public function snap(item:DisplayObject, mode:uint, ease:Function = null, duration:Number = Number.NaN, easeParams:Array = null):void {
			if (item.parent == this._content) {
				var params:Object = {
					x: Number.NaN,
					y: Number.NaN,
					ease: ease != null? ease : Linear.easeNone,
					easeParams: easeParams,
					onComplete: this.handleTweenComplete
				};
				
				if (mode == ScrollPaneConstants.SNAP_TO_TOP) {
					if (!this.settings.scrollLockX) {
						params.x = item.x - this.settings.paddingLeft;
					}
					if (!this.settings.scrollLockY) {
						params.y = -(item.y - this.settings.paddingTop);
					}
				} else if (mode == ScrollPaneConstants.SNAP_TO_BOTTOM) {
					if (!this.settings.scrollLockX) {
						params.x = item.x - this.settings.paddingLeft;
					}
					if (!this.settings.scrollLockY) {
						params.y = this.height - item.y - item.height - this.settings.paddingTop;
					}
				} else {
					throw new Error("No more modes are implemented so far! Sorry :(");
				}
				
				if (!isNaN(params.x) || !isNaN(params.y)) {
					this.ensureOffsetToApply(params.x, params.y);
					if (isNaN(params.x)) { delete params.x; }
					if (isNaN(params.y)) { delete params.y; }
					TweenLite.to(
						this._content,
						!isNaN(duration)? duration : this.settings.defaultTweenDuration,
						params
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
		
		public function invalidate(scrollDirectionX:uint = ScrollPaneConstants.DIRECTION_NONE, scrollDirectionY:uint = ScrollPaneConstants.DIRECTION_NONE):void {
			this._scrollDirectionX = scrollDirectionX;
			this._scrollDirectionY = scrollDirectionY;
			
			this.revalidateList();
			this.updateScrollBars();
		}
		
		public function addScrollBar(scrollBar:ScrollBar):void {
			this._scrollbars.push(scrollBar);
			
			scrollBar.scrollPane = this;
			
			this.updateScrollBars();
		}
		
		public function removeScrollBar(scrollBar:ScrollBar):void {
			this._scrollbars.splice(this._scrollbars.indexOf(scrollBar), 1);
			
			scrollBar.scrollPane = null;
		}
		
		protected function redrawAssets():void {
			this._background.graphics.beginFill(0xff0000, 1);
			this._background.graphics.drawRect(0, 0, this.width, this.height);
			this._background.graphics.endFill();
		}
		
		private function updateScrollBars():void {
			var length:uint = this._scrollbars.length;
			var scrollBar:ScrollBar;
			for (var i:uint = 0; i < length; ++i) {
				scrollBar = this._scrollbars[i];
				
				if (this.mode == ScrollPaneConstants.APPEND_MODE_COLUMN) {
					scrollBar.offset = this.scrollYPercents;
					scrollBar.percents = this.visibilityYProportion;
				} else if (this.mode == ScrollPaneConstants.APPEND_MODE_ROW) {
					scrollBar.offset = this.scrollXPercents;
					scrollBar.percents = this.visibilityXProportion;
				}
				
				scrollBar.visible = true;
				if (this.settings.autoHideScrollBarsOnFullBar) {
					if (scrollBar.offset == 0 && scrollBar.percents == 100) {
						scrollBar.visible = false;
					}
				}
				
			}
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
			return length > 0? this._content.getChildAt(length - 1) : null;
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
			return length > 0? this._content.getChildAt(length - 1) : null;
		}
		
		private function get totalWidth():Number {
			return this._content.width;
		}
		
		private function get totalHeight():Number {
			return this._content.height;
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
				this.graphics.beginFill(0xff00ff, 0);
				this.graphics.drawRect(0, 0, this.width, this.height);
				this.graphics.endFill();
				
				this.redrawAssets();
				
				this._content.graphics.drawRect(0, 0, this.width, this.height);
			
				this._mask.graphics.beginFill(0xffffff, 1);
				this._mask.graphics.drawRect(0, 0, this.width, this.height);
				this._mask.graphics.endFill();
				
				this._control.graphics.beginFill(0xff00ff, 0);
				this._control.graphics.drawRect(0, 0, this.width, this.height);
				this._control.graphics.endFill();
				
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
			if (_offsetToApply) {
				TweenLite.killTweensOf(this._content);
				if (settings.queueTweens) {
					if (!isNaN(_offsetToApply.x)) {
						_content.x = _offsetToApply.x;
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
		
		private function revalidateList(istantMode:Boolean = false):void {
			var item:DisplayObject;
			var snapTo:uint;
			var ease:Function = istantMode? null : this.settings.scrollAutoFocusTweenEase;
			var duration:Number = istantMode? null : this.settings.scrollAutoFocusTweenDuration;
			
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
				} else if (this._content.y + this.totalHeight < this.height && this.totalHeight > this.height) {
					if (this._scrollDirectionY == ScrollPaneConstants.DIRECTION_DOWN) {
						item = this.firstPartiallyVisibleItem;
						snapTo = ScrollPaneConstants.SNAP_TO_TOP;
					} else if (this._scrollDirectionY == ScrollPaneConstants.DIRECTION_UP) {
						item = this.latestPartiallyVisibleItem;
						snapTo = ScrollPaneConstants.SNAP_TO_BOTTOM;
					} else {
						item = this.latestPartiallyVisibleItem;
						snapTo = ScrollPaneConstants.SNAP_TO_BOTTOM;
					}
				} else if (this._content.y + this.totalHeight < this.height && this.totalHeight <= this.height) {
					item = this._content.numChildren > 0? this._content.getChildAt(0) : null
					snapTo = ScrollPaneConstants.SNAP_TO_TOP;
				} else {
					ease = this.settings.scrollOverDragTweenEase;
					duration = this.settings.scrollOverDragTweenDuration;
							
					if (this._latestScrollDeltaY > 0) {
						if (this._latestScrollDeltaY > this.settings.postForceMinDelta) {
							var currentTop:DisplayObject = this.firstPartiallyVisibleItem;
							var currentTopIndex:int = currentTop.parent.getChildIndex(currentTop);
							
							if (currentTopIndex > 0) {
								currentTopIndex += int(this._latestScrollDeltaY / this.settings.postForceOneItemSize);
								currentTopIndex = currentTopIndex < 0? 0 : currentTopIndex;
								currentTopIndex = currentTopIndex >= currentTop.parent.numChildren? currentTop.parent.numChildren - 1 : currentTopIndex;
							}
							
							item = currentTop.parent.getChildAt(currentTopIndex);
							snapTo = ScrollPaneConstants.SNAP_TO_TOP;
							
							this._postScrollFix = true;
						}
					} else {
						if (this._latestScrollDeltaY < -this.settings.postForceMinDelta) {
							var currentBottom:DisplayObject = this.latestPartiallyVisibleItem;
							var currentBottomIndex:int = currentBottom.parent.getChildIndex(currentBottom);
							
							if (currentBottomIndex < currentBottom.parent.numChildren) {
								currentBottomIndex -= int( -this._latestScrollDeltaY / this.settings.postForceOneItemSize);
								currentBottomIndex = currentBottomIndex < 0? 0 : currentBottomIndex;
								currentBottomIndex = currentBottomIndex >= currentBottom.parent.numChildren? currentBottom.parent.numChildren - 1 : currentBottomIndex;
							}
							
							item = currentBottom.parent.getChildAt(currentBottomIndex);
							snapTo = ScrollPaneConstants.SNAP_TO_BOTTOM;
							
							this._postScrollFix = true;
						}
					}
				}
			}
			
			if (item) {
				this.snap(item, snapTo, ease, duration);
			}			
		}
		
		private function dragScrollEnabled():void {
			if (!this._control.parent) {
				super.addChild(this._control);
				
				this._control.addEventListener(MouseEvent.MOUSE_DOWN, this.handleControlMouseDown, false, 0, true);
				this._control.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleControlMouseUp, false, 0, true);
				this._control.addEventListener(MouseEvent.MOUSE_MOVE, this.handleControlMouseMove, false, 0, true);
				this._control.addEventListener(MouseEvent.CLICK, this.handleControlClick, false, 0, true);
			}
		}
		
		private function dragScrollDisabled():void {
			if (this._control.parent) {
				this._control.removeEventListener(MouseEvent.MOUSE_DOWN, this.handleControlMouseDown);
				this._control.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleControlMouseUp);
				this._control.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleControlMouseMove);
				this._control.removeEventListener(MouseEvent.CLICK, this.handleControlClick);
				
				super.removeChild(this._control);
			}
		}
		
		private function handleTweenComplete():void {
			this._offsetToApply = null;
			this.updateScrollBars();
			
			if (this._postScrollFix) {
				this.revalidateList();
				
				this._postScrollFix = false;
			}
		}
		
		private function handleAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage, false, 0, true);
			
			super.addChild(this._background);
			super.addChild(this._content);
			super.addChild(this._mask);
			
			this._background.x = 0;
			this._background.y = 0;
			
			this._content.x = 0;
			this._content.y = 0;
			
			this._mask.x = 0;
			this._mask.y = 0;
			
			this._control.x = 0;
			this._control.y = 0;
			
			this._content.mask = this._mask;
			
			this.updateSize();
			
			this.addEventListener(MouseEvent.MOUSE_WHEEL, this.handleMouseWheel, false, 0, true);
			if (this.settings.dragScrollAuto) {
				this.addEventListener(MouseEvent.MOUSE_DOWN, this.handlePreStageMouseDown, false, 0, true);
				this.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleStageMouseUp, false, 0, true);
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleStageMouseMove, false, 0, true);
			}
			if (this.settings.dragScroll) {
				this.dragScrollEnabled();
			}
		}
		
		private function handleRemovedFromStage(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage);
			
			this.removeEventListener(MouseEvent.MOUSE_WHEEL, this.handleMouseWheel);
			if (this.settings.dragScrollAuto) {
				this.removeEventListener(MouseEvent.MOUSE_DOWN, this.handlePreStageMouseDown);
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleStageMouseUp);
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleStageMouseMove);
			}
			
			this.dragScrollDisabled();
		}
		
		private function handleMouseWheel(e:MouseEvent):void {
			var desired:Number = this.scrollY - e.delta * this.settings.scrollMultiplier;
			this.scrollY = desired < 0? 0 : desired;
			
			this._scrollDirectionY = e.delta > 0? ScrollPaneConstants.DIRECTION_DOWN : ScrollPaneConstants.DIRECTION_UP;
			
			this._latestMouseDownPoint = null;
			this._mouseDownMode = false;
			this._mouseMovedMode = false;
			
			this.revalidateList(true);
			this.updateScrollBars();
		}
		
		private function handlePreStageMouseDown(e:MouseEvent):void {
			this._mouseDownStageMode = true;
		}
		
		private function handleStageMouseUp(e:MouseEvent):void {
			this._mouseDownStageMode = false;
			this._mouseMovedStageMode = false;
			
			this.dragScrollDisabled();
		}
		
		private function handleStageMouseMove(e:MouseEvent):void {
			if (this._mouseDownStageMode) {
				this._mouseMovedStageMode = true;

				this.handleControlMouseDown(e);
				this.dragScrollEnabled();
			}
		}
		
		private function handleControlMouseDown(e:MouseEvent):void {
			this._mouseDownMode = true;
			this._latestMouseDownPoint = e.target.localToGlobal(new Point(e.localX, e.localY));
			TweenLite.killTweensOf(this._content);
			this._offsetToApply = null;
		}
		
		private function handleControlMouseUp(e:MouseEvent):void {
			if (this._mouseDownMode) {
				this.revalidateList();
				
				if (this._mouseMovedMode) {
					this._latestMouseUpTarget = e.target;
				} else {
					this._latestMouseUpTarget = null;
				}
			} else {
				this._latestMouseUpTarget = null;
			}
			
			this.updateScrollBars();
			
			this._mouseDownMode = false;
			this._mouseMovedMode = false;
			this._latestMouseDownPoint = null;
			this._latestScrollDeltaX = 0;
			this._latestScrollDeltaY = 0;
			this._scrollDirectionX = ScrollPaneConstants.DIRECTION_NONE;
			this._scrollDirectionY = ScrollPaneConstants.DIRECTION_NONE;
		}
		
		private function handleControlMouseMove(e:MouseEvent):void {
			if (this._mouseDownMode) {
				this._mouseMovedMode = true;
				var globalPoint:Point = e.target.localToGlobal(new Point(e.localX, e.localY));
				
				var deltaX:Number = this._latestMouseDownPoint.x - globalPoint.x;
				var deltaY:Number = this._latestMouseDownPoint.y - globalPoint.y;
				
				this._latestMouseDownPoint = e.target.localToGlobal(new Point(e.localX, e.localY));
				
				if (!this.settings.scrollLockX) {
					this.scrollX += deltaX;
					if (deltaX > 0) {
						this._scrollDirectionX = ScrollPaneConstants.DIRECTION_LEFT;
					} else {
						this._scrollDirectionX = ScrollPaneConstants.DIRECTION_RIGHT;
					}
					this._latestScrollDeltaX = deltaX;
				}
				if (!this.settings.scrollLockY) {
					this.scrollY += deltaY;
					if (deltaY > 0) {
						this._scrollDirectionY = ScrollPaneConstants.DIRECTION_UP;
					} else {
						this._scrollDirectionY = ScrollPaneConstants.DIRECTION_DOWN;
					}
					this._latestScrollDeltaY = deltaY;
				}
				
				this.updateScrollBars();
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