package org.ranapat.scrollpane {
	import com.greensock.easing.Ease;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ScrollPane extends Sprite {
		public static var DEBUG_MODE:Boolean = false;
		
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
		private var _latestScrollDeltaX:Number;
		private var _latestScrollDeltaY:Number;
		private var _postScrollFix:Boolean;
		private var _removeAllChildren:Boolean;
		
		private var _items:Vector.<DisplayObject>;
		private var _numChildren:uint;
		private var _totalWidth:Number;
		private var _totalHeight:Number;
		
		private var _scrollbars:Vector.<ScrollBar>;
		
		private var mode:uint;
		private var breakAt:uint;
		
		private var dragScroll:Boolean;
		
		public var settings:ScrollPaneSettings;
		
		public function ScrollPane(_mode:uint = ScrollPaneConstants.APPEND_MODE_FREE, _breakAt:uint = 1, _settings:ScrollPaneSettings = null) {
			super();
			
			this.mode = _mode;
			this.breakAt = _breakAt;
			this.settings = _settings? _settings : new ScrollPaneSettings();
			
			this.settings.scrollLockX = this.mode == ScrollPaneConstants.APPEND_MODE_COLUMN;
			this.settings.scrollLockY = this.mode == ScrollPaneConstants.APPEND_MODE_ROW;
			
			this._scrollbars = new Vector.<ScrollBar>();
			
			this._background = new Sprite();
			this._content = new Sprite();
			this._mask = new Sprite();
			this._control = new Sprite();
			
			this._items = new Vector.<DisplayObject>();
			
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
			return index < 0? null : index >= this._items.length? null : this._items[index];
		}
		
		override public function addChild(item:DisplayObject):DisplayObject {
			this._totalWidth = Math.max(this._content.width, item.x + item.width);
			this._totalHeight = Math.max(this._content.height, item.y + item.height);
			
			//item.cacheAsBitmap = true;
			
			this._items[this._items.length] = item;
			++this._numChildren;
			
			this.updateItemsInContentContainer();
			this.updateScrollBars();
			
			return item;
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			trace("!!! NOT IMPLEMENTED !!!");
			return this.addChild(child);
		}
		
		override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void {
			this._removeAllChildren = true;
			
			var itemsToDelete:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			var i:uint;
			var length:uint;
			
			length = this.numChildren;
			for (i = 0; i < length; ++i) {
				if (i >= beginIndex && i <= endIndex) {
					itemsToDelete[itemsToDelete.length] = this.getChildAt(i);
				}
			}
			
			length = itemsToDelete.length;
			for (i = 0; i < length; ++i) {
				this.removeChild(itemsToDelete[i]);
			}
			
			this._removeAllChildren = false;
		}
		
		override public function removeChildAt(index:int):DisplayObject {
			return this.removeChild(this.getChildAt(index));
		}
		
		override public function removeChild(item:DisplayObject):DisplayObject {
			var index:int = this._items.indexOf(item);
			var length:uint = this.numChildren;
			var i:uint;
			var current:DisplayObject;
			var previous:DisplayObject;
			
			if (index >= 0) {
				if (
					this.mode == ScrollPaneConstants.APPEND_MODE_COLUMN
					|| this.mode == ScrollPaneConstants.APPEND_MODE_ROW
				) {
					for (i = length - 1; i >= index + 1; --i) {
						previous = this.getChildAt(i - 1);
						current = this.getChildAt(i);
						
						current.x = previous.x;
						current.y = previous.y;
					}
				} else if (this.mode == ScrollPaneConstants.APPEND_MODE_FREE) {
					//
				}
				
				if (item.parent == this._content) {
					this._content.removeChild(item);
				}
				this._items.splice(index, 1);
				--this._numChildren;
				
				var lastItem:DisplayObject = this.getChildAt(this.numChildren - 1);
				if (lastItem) {
					this._totalWidth = lastItem.x + lastItem.width;
					this._totalHeight = lastItem.y + lastItem.height;
				}
				
				this.updateItemsInContentContainer();
				this.updateScrollBars();
			}

			this.ensureScrollOffsets(this._removeAllChildren? true : false);
			
			return item;
		}
		
		override public function getChildIndex(child:DisplayObject):int {
			return this._items.indexOf(child);
		}
		
		override public function get numChildren():int {
			return this._numChildren;
		}
		
		public function removeAllChildren():Vector.<DisplayObject> {
			var result:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			while (this._items.length > 0) {
				result[result.length] = this.removeChild(this.getChildAt(this._items.length - 1));
			}
			
			return result;
		}
		
		public function appendChild(item:DisplayObject):DisplayObject {
			if (this.numChildren == 0) {
				item.x = this.settings.paddingLeft;
				item.y = this.settings.paddingTop;
			} else {
				var prevItem:DisplayObject;
				
				prevItem = this.getChildAt(this.numChildren - 1);
				
				if (this.mode == ScrollPaneConstants.APPEND_MODE_COLUMN) {
					if (this.breakAt && this.numChildren % this.breakAt != 0) {
						item.x = this.settings.paddingLeft + item.width * (this.numChildren % this.breakAt) +  this.settings.xSpaceBetweenItems * (this.numChildren % this.breakAt);
						item.y = prevItem.y
					} else {
						item.x = this.settings.paddingLeft;
						item.y = prevItem.y + prevItem.height + this.settings.ySpaceBetweenItems;
					}
				} else if (this.mode == ScrollPaneConstants.APPEND_MODE_ROW) {
					if (this.breakAt && this.numChildren % this.breakAt != 0) {
						item.x = prevItem.x;
						item.y = this.settings.paddingTop + item.height * (this.numChildren % this.breakAt) + this.settings.ySpaceBetweenItems * (this.numChildren % this.breakAt);
					} else {
						item.y = this.settings.paddingTop;
						item.x = prevItem.x + prevItem.width + this.settings.xSpaceBetweenItems;
					}
				} else if (this.mode == ScrollPaneConstants.APPEND_MODE_FREE) {
					item.x = 1.5 * Math.random() * (this.width);
					item.y = 1.5 * Math.random() * (this.height);
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
			
			this.updateItemsInContentContainer();
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
			
			this.updateItemsInContentContainer();
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
		
		public function setTotalWidth(value:Number):void {
			this._totalWidth = value;
		}
		
		public function setTotalHeight(value:Number):void {
			this._totalHeight = value;
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
					onUpdate: this.updateItemsInContentContainer,
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
					onUpdate: this.updateItemsInContentContainer,
					onComplete: this.handleTweenComplete
				}
			);
		}
		
		public function focus(item:DisplayObject, ease:Ease = null, duration:Number = Number.NaN, easeParams:Array = null):void {
			if (this._items.indexOf(item) >= 0) {
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
							onUpdate: this.updateItemsInContentContainer,
							onComplete: this.handleTweenComplete
						}
					);
				}
			}
		}
		
		public function snap(item:DisplayObject, mode:uint, ease:Ease = null, duration:Number = Number.NaN, easeParams:Array = null):void {
			if (this._items.indexOf(item) >= 0) {
				var params:Object = {
					x: Number.NaN,
					y: Number.NaN,
					ease: ease != null? ease : Linear.easeNone,
					easeParams: easeParams,
					onUpdate: this.updateItemsInContentContainer,
					onComplete: this.handleTweenComplete
				};
				
				if (mode == ScrollPaneConstants.SNAP_TO_TOP) {
					params.y = -(item.y - this.settings.paddingTop);
				} else if (mode == ScrollPaneConstants.SNAP_TO_BOTTOM) {
					params.y = this.height - item.y - item.height - this.settings.paddingTop;
				} else if (mode == ScrollPaneConstants.SNAP_TO_LEFT) {
					params.x = -(item.x - this.settings.paddingLeft);
				} else if (mode == ScrollPaneConstants.SNAP_TO_RIGHT) {
					params.x = this.width - item.x - item.width - this.settings.paddingLeft;
				} else {
					throw new Error("Mode not implement! Sorry :(");
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
		
		public function scroll(items:int, ease:Ease = null, duration:Number = Number.NaN, easeParams:Array = null):void {
			var scrollTo:uint;
			if (items >= 0) {
				var latestItem:DisplayObject = this.latestFullyVisibleItem;
				var latestItemIndex:uint = this._items.indexOf(latestItem);
				
				scrollTo = (latestItemIndex + items + 1) > this.numChildren? (this.numChildren - 1) : (latestItemIndex + items);
			} else if (items < 0) {
				var firstItem:DisplayObject = this.firstFullyVisibleItem;
				var firstItemIndex:uint = this._items.indexOf(firstItem);
				
				scrollTo = (latestItemIndex - items) >= 0? (latestItemIndex - items) : 0;
			}
			
			this.focus(this.getChildAt(scrollTo), ease, duration, easeParams);
		}
		
		public function invalidate(scrollDirectionX:uint = ScrollPaneConstants.DIRECTION_NONE, scrollDirectionY:uint = ScrollPaneConstants.DIRECTION_NONE):void {
			this._scrollDirectionX = scrollDirectionX;
			this._scrollDirectionY = scrollDirectionY;
			
			this.updateItemsInContentContainer();
			this.updateScrollBars();
			this.ensureScrollOffsets();
		}
		
		public function addScrollBar(scrollBar:ScrollBar):void {
			this._scrollbars[this._scrollbars.length] = scrollBar;
			
			scrollBar.scrollPane = this;
			
			this.updateScrollBars();
		}
		
		public function removeScrollBar(scrollBar:ScrollBar):void {
			this._scrollbars.splice(this._scrollbars.indexOf(scrollBar), 1);
			
			scrollBar.scrollPane = null;
		}
		
		protected function redrawAssets():void {
			this._background.graphics.beginFill(0xff00ff, ScrollPane.DEBUG_MODE? 1 : 0);
			this._background.graphics.drawRect(0, 0, this.width, this.height);
			this._background.graphics.endFill();
		}
		
		private function updateScrollBars():void {
			var length:uint = this._scrollbars.length;
			var scrollBar:ScrollBar;
			for (var i:uint = 0; i < length; ++i) {
				scrollBar = this._scrollbars[i];
				
				if (
					(this.mode == ScrollPaneConstants.APPEND_MODE_COLUMN || this.mode == ScrollPaneConstants.APPEND_MODE_FREE)
					&& scrollBar.mode == ScrollBarConstants.MODE_VERTICAL
				) {
					scrollBar.offset = this.scrollYPercents;
					scrollBar.percents = this.visibilityYProportion;
				} else if (
					(this.mode == ScrollPaneConstants.APPEND_MODE_ROW || this.mode == ScrollPaneConstants.APPEND_MODE_FREE)
					&& scrollBar.mode == ScrollBarConstants.MODE_HORIZONTAL
				) {
					scrollBar.offset = this.scrollXPercents;
					scrollBar.percents = this.visibilityXProportion;
				}
				
				scrollBar.visible = true;
				
				if (this.settings.autoHideScrollBarsOnFullBar) {
					if (scrollBar.offset == 0 && (scrollBar.percents == 0 || scrollBar.percents == 100)) {
						scrollBar.visible = false;
					}
				}
			}
		}
		
		private function get firstPartiallyVisibleItem():DisplayObject {
			var length:uint = this.numChildren;
			for (var i:uint = 0; i < length; ++i) {
				if (this.isItemPartiallyVisibile(this.getChildAt(i))) {
					return this.getChildAt(i);
				}
			}
			return null;
		}
		
		private function get firstFullyVisibleItem():DisplayObject {
			var length:uint = this.numChildren;
			for (var i:uint = 0; i < length; ++i) {
				if (this.isItemFullyVisibile(this.getChildAt(i))) {
					return this.getChildAt(i);
				}
			}
			return null;
		}
		
		private function get latestPartiallyVisibleItem():DisplayObject {
			var alreadyVisible:Boolean;
			var length:uint = this.numChildren;
			for (var i:uint = 0; i < length; ++i) {
				if (!alreadyVisible && this.isItemPartiallyVisibile(this.getChildAt(i))) {
					alreadyVisible = true;
				} else if (alreadyVisible && !this.isItemPartiallyVisibile(this.getChildAt(i))) {
					return this.getChildAt(i - 1);
				}
			}
			return length > 0? this.getChildAt(length - 1) : null;
		}
		
		private function get latestFullyVisibleItem():DisplayObject {
			var alreadyVisible:Boolean;
			var length:uint = this.numChildren;
			for (var i:uint = 0; i < length; ++i) {
				if (!alreadyVisible && this.isItemFullyVisibile(this.getChildAt(i))) {
					alreadyVisible = true;
				} else if (alreadyVisible && !this.isItemFullyVisibile(this.getChildAt(i))) {
					return this.getChildAt(i - 1);
				}
			}
			return length > 0? this.getChildAt(length - 1) : null;
		}
		
		private function get totalWidth():Number {
			return this._totalWidth;
		}
		
		private function get totalHeight():Number {
			return this._totalHeight;
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
				
				this.scrollRect = new Rectangle(0, 0, this.width, this.height);
			}
		}
		
		private function ensureOffsetToApply(x:Number = Number.NaN, y:Number = Number.NaN):void {
			if (this._offsetToApply) {
				TweenLite.killTweensOf(this._content);
				if (settings.queueTweens) {
					if (!isNaN(this._offsetToApply.x)) {
						_content.x = this._offsetToApply.x;
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
			var length:uint = this.numChildren;
			var tmp:DisplayObject;
			var offsetX:Number = x - this._content.x;
			var offsetY:Number = y - this._content.y;
			for (var i:uint = 0; i < length; ++i) {
				tmp = this.getChildAt(i);
				
				if (
					tmp.x <= offsetX && tmp.x + tmp.width > offsetX
					&& tmp.y <= offsetY && tmp.y + tmp.height > offsetY
				) {
					return tmp;
				}
			}
			return null;
		}
		
		private function ensureScrollOffsets(istantMode:Boolean = false):void {
			var item:DisplayObject;
			var snapTo:uint;
			var ease:Ease = istantMode? null : this.settings.scrollAutoFocusTweenEase;
			var duration:Number = istantMode? null : this.settings.scrollAutoFocusTweenDuration;
			
			if (this._content.y > 0) {
				item = this.firstPartiallyVisibleItem;
				snapTo = ScrollPaneConstants.SNAP_TO_TOP;
			} else if (int(this._content.y + this.totalHeight) < int(this.height) && this.totalHeight > this.height) {
				item = this.latestPartiallyVisibleItem;
				snapTo = ScrollPaneConstants.SNAP_TO_BOTTOM;
			} else if (int(this._content.y + this.totalHeight) < int(this.height) && this.totalHeight <= this.height) {
				item = this.numChildren > 0? this.getChildAt(0) : null
				snapTo = ScrollPaneConstants.SNAP_TO_TOP;
			} else if (this._content.x > 0) {
				item = this.firstPartiallyVisibleItem;
				snapTo = ScrollPaneConstants.SNAP_TO_LEFT;
			} else if (int(this._content.x + this.totalWidth) < int(this.width) && this.totalWidth > this.width) {
				item = this.latestPartiallyVisibleItem;
				snapTo = ScrollPaneConstants.SNAP_TO_RIGHT;
			} else if (int(this._content.x + this.totalWidth) < int(this.width) && this.totalWidth <= this.width) {
				item = this.numChildren > 0? this.getChildAt(0) : null
				snapTo = ScrollPaneConstants.SNAP_TO_LEFT;
			} else if (this._scrollDirectionY != ScrollPaneConstants.DIRECTION_NONE && this.totalHeight > this.height && this.numChildren > 1 && this.settings.scrollSnapToItems) {
				if (this._scrollDirectionY == ScrollPaneConstants.DIRECTION_DOWN) {
					item = this.firstPartiallyVisibleItem;
					snapTo = ScrollPaneConstants.SNAP_TO_TOP;
				} else if (this._scrollDirectionY == ScrollPaneConstants.DIRECTION_UP) {
					item = this.latestPartiallyVisibleItem;
					snapTo = ScrollPaneConstants.SNAP_TO_BOTTOM;
				} else {
					snapTo = ScrollPaneConstants.SNAP_TO_BOTTOM;
				}
			} else if (this._scrollDirectionX != ScrollPaneConstants.DIRECTION_NONE && this.totalWidth > this.width && this.numChildren > 1 && this.settings.scrollSnapToItems) {
				if (this._scrollDirectionX == ScrollPaneConstants.DIRECTION_RIGHT) {
					item = this.firstPartiallyVisibleItem;
					snapTo = ScrollPaneConstants.SNAP_TO_LEFT;
				} else if (this._scrollDirectionX == ScrollPaneConstants.DIRECTION_LEFT) {
					item = this.latestPartiallyVisibleItem;
					snapTo = ScrollPaneConstants.SNAP_TO_RIGHT;
				} else {
					snapTo = ScrollPaneConstants.SNAP_TO_RIGHT;
				}
			} else {
				ease = this.settings.scrollOverDragTweenEase;
				duration = this.settings.scrollOverDragTweenDuration;
				
				var currentTop:DisplayObject;
				var currentTopIndex:int;
				var currentBottom:DisplayObject;
				var currentBottomIndex:int;
						
				if (this._latestScrollDeltaY > 0) {
					if (this._latestScrollDeltaY > this.settings.postForceMinDelta) {
						currentTop = this.firstPartiallyVisibleItem;
						currentTopIndex = this.getChildIndex(currentTop);
						
						if (currentTopIndex > 0) {
							currentTopIndex += int(this._latestScrollDeltaY / this.settings.postForceOneItemSize);
							currentTopIndex = currentTopIndex < 0? 0 : currentTopIndex;
							currentTopIndex = currentTopIndex >= this.numChildren? this.numChildren - 1 : currentTopIndex;
						}
						
						item = this.getChildAt(currentTopIndex);
						snapTo = ScrollPaneConstants.SNAP_TO_TOP;
						
						this._postScrollFix = true;
					}
				} else if (this._latestScrollDeltaY < 0) {
					if (this._latestScrollDeltaY < -this.settings.postForceMinDelta) {
						currentBottom = this.latestPartiallyVisibleItem;
						currentBottomIndex = this.getChildIndex(currentBottom);
						
						if (currentBottomIndex < this.numChildren) {
							currentBottomIndex -= int( -this._latestScrollDeltaY / this.settings.postForceOneItemSize);
							currentBottomIndex = currentBottomIndex < 0? 0 : currentBottomIndex;
							currentBottomIndex = currentBottomIndex >= this.numChildren? this.numChildren - 1 : currentBottomIndex;
						}
						
						item = this.getChildAt(currentBottomIndex);
						snapTo = ScrollPaneConstants.SNAP_TO_BOTTOM;
						
						this._postScrollFix = true;
					}
				}
				
				if (this._latestScrollDeltaX > 0) {
					if (this._latestScrollDeltaX > this.settings.postForceMinDelta) {
						currentTop = this.firstPartiallyVisibleItem;
						currentTopIndex = this.getChildIndex(currentTop);
						
						if (currentTopIndex > 0) {
							currentTopIndex += int(this._latestScrollDeltaX / this.settings.postForceOneItemSize);
							currentTopIndex = currentTopIndex < 0? 0 : currentTopIndex;
							currentTopIndex = currentTopIndex >= this.numChildren? this.numChildren - 1 : currentTopIndex;
						}
						
						item = this.getChildAt(currentTopIndex);
						snapTo = ScrollPaneConstants.SNAP_TO_LEFT;
						
						this._postScrollFix = true;
					}
				} else if (this._latestScrollDeltaX < 0) {
					if (this._latestScrollDeltaX < -this.settings.postForceMinDelta) {
						currentBottom = this.latestPartiallyVisibleItem;
						currentBottomIndex = this.getChildIndex(currentBottom);
						
						if (currentBottomIndex < this.numChildren) {
							currentBottomIndex -= int( -this._latestScrollDeltaX / this.settings.postForceOneItemSize);
							currentBottomIndex = currentBottomIndex < 0? 0 : currentBottomIndex;
							currentBottomIndex = currentBottomIndex >= this.numChildren? this.numChildren - 1 : currentBottomIndex;
						}
						
						item = this.getChildAt(currentBottomIndex);
						snapTo = ScrollPaneConstants.SNAP_TO_RIGHT;
						
						this._postScrollFix = true;
					}
				}
			}
			
			if (item) {
				this.snap(item, snapTo, ease, duration);
			}			
		}
		
		private function dragScrollEnabled():void {
			this._control.mouseEnabled = true;
			this.dragScroll = true;
		}
		
		private function dragScrollDisabled():void {
			this._control.mouseEnabled = false;
			this.dragScroll = false;
		}
		
		private function displayAllItems():void {
			var length:uint = this.numChildren;
			var item:DisplayObject;
			
			for (var i:uint = 0; i < length; ++i) {
				item = this.getChildAt(i);
				
				if (!item.parent) {
					this._content.addChild(item);
				}
			}
		}
		
		private function updateItemsInContentContainer():void {
			var length:uint = this.numChildren;
			var item:DisplayObject;
			
			var contentX:Number = this._content.x;
			var contentY:Number = this._content.y;
			var contentWidth:Number = this._width;
			var contentHeight:Number = this._height;
			
			for (var i:uint = 0; i < length; ++i) {
				item = this.getChildAt(i);
				
				if (this.settings.smartUpdateItems) {
					if (
						item.y + item.height < -1 * contentY
					) {
						if (item.parent) {
							this._content.removeChild(item);
						}
						continue;
					} else if (
						item.y > -1 * contentY + contentHeight
					) {
						if (item.parent) {
							this._content.removeChild(item);
						}
						continue;
					} else {
						//
					}
					
					if (
						item.x + item.width < -1 * contentX
					) {
						if (item.parent) {
							this._content.removeChild(item);
						}
						continue;
					} else if (
						item.x > -1 * contentX + contentWidth
					) {
						if (item.parent) {
							this._content.removeChild(item);
						}
						continue;
					} else {
						//
					}
				}
				
				if (!item.parent) {
					this._content.addChild(item);
				}
			}
		}
		
		private function handleTweenComplete():void {
			this._offsetToApply = null;
			this.updateScrollBars();
			
			if (this._postScrollFix) {
				this.ensureScrollOffsets();
				
				this._postScrollFix = false;
			}
		}
		
		private function handleAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage, false, 0, true);
			
			super.addChild(this._background);
			super.addChild(this._content);
			super.addChild(this._mask);
			
			this.cacheAsBitmap = true;
			
			this._background.x = 0;
			this._background.y = 0;
			
			this._content.x = 0;
			this._content.y = 0;
			//this._content.cacheAsBitmap = true;
			
			this._mask.x = 0;
			this._mask.y = 0;
			
			this._control.x = 0;
			this._control.y = 0;
			
			if (!ScrollPane.DEBUG_MODE) {
				this._content.mask = this._mask;
			} else {
				this._mask.alpha = .4;
				this._mask.mouseEnabled = false;
			}
			
			this.updateSize();
			
			this.addEventListener(MouseEvent.MOUSE_WHEEL, this.handleMouseWheel, false, 0, true);
			if (this.settings.dragScrollAuto) {
				super.addChild(this._control);
				
				this._control.addEventListener(MouseEvent.MOUSE_DOWN, this.handleControlMouseDown, false, 0, true);
				this._control.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleControlMouseUp, false, 0, true);
				this._control.addEventListener(MouseEvent.MOUSE_MOVE, this.handleControlMouseMove, false, 0, true);
				
				this.addEventListener(MouseEvent.MOUSE_DOWN, this.handlePreStageMouseDown, false, 0, true);
				this.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleStageMouseUp, false, 0, true);
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleStageMouseMove, false, 0, true);
			}
			this.dragScrollDisabled();
		}
		
		private function handleRemovedFromStage(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage);
			
			this.removeEventListener(MouseEvent.MOUSE_WHEEL, this.handleMouseWheel);
			if (this.settings.dragScrollAuto) {
				this._control.removeEventListener(MouseEvent.MOUSE_DOWN, this.handleControlMouseDown);
				this._control.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleControlMouseUp);
				this._control.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleControlMouseMove);
				
				super.removeChild(this._control);
				
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
			
			this.ensureScrollOffsets(true);
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
				this.ensureScrollOffsets();
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
				} else {
					this._scrollDirectionX = ScrollPaneConstants.DIRECTION_NONE;
				}
				if (!this.settings.scrollLockY) {
					this.scrollY += deltaY;
					if (deltaY > 0) {
						this._scrollDirectionY = ScrollPaneConstants.DIRECTION_UP;
					} else {
						this._scrollDirectionY = ScrollPaneConstants.DIRECTION_DOWN;
					}
					this._latestScrollDeltaY = deltaY;
				} else {
					this._scrollDirectionY = ScrollPaneConstants.DIRECTION_NONE;
				}
				
				this.updateScrollBars();
			}
		}
	}

}