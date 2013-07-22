package org.ranapat.scrollpane {
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ScrollPane extends Sprite {
		private var _background:Sprite;
		private var _content:Sprite;
		private var _mask:Sprite;
		
		private var _width:Number;
		private var _height:Number;
		
		public function ScrollPane() {
			this._background = new Sprite();
			this._content = new Sprite();
			this._mask = new Sprite();
			
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
				item.x = ScrollPaneSettings.PADDING_LEFT;
				item.y = ScrollPaneSettings.PADDING_TOP;
			} else {
				var prevItem:DisplayObject;
				
				if (mode == ScrollPaneConstants.APPEND_MODE_COLUMN) {
					prevItem = this._content.getChildAt(this._content.numChildren - 1);
					item.x = ScrollPaneSettings.PADDING_LEFT;
					item.y = prevItem.y + prevItem.height + ScrollPaneSettings.Y_SPACE_BETWEEN_ITEMS;
				} else if (mode == ScrollPaneConstants.APPEND_MODE_ROW) {
					prevItem = this._content.getChildAt(this._content.numChildren - 1);
					item.y = ScrollPaneSettings.PADDING_TOP;
					item.x = prevItem.x + prevItem.width + ScrollPaneSettings.X_SPACE_BETWEEN_ITEMS;
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
		
		public function set scrollY(value:Number):void {
			this._content.y = -value;
		}
		
		public function focus(item:DisplayObject, duration:Number = Number.NaN, ease:Function = null, easeParams:Array = null):void {
			if (item.parent == this._content) {
				if (!this.isItemFullyVisibile(item)) {
					var deltaX:Number = 0;
					var deltaY:Number = 0;
					
					if (item.x + this._content.x < 0) {
						deltaX = ScrollPaneSettings.PADDING_LEFT - this._content.x - item.x;
					} else if (item.x + item.width + this._content.x > this.width) {
						deltaX = this.width - item.x - item.width - this._content.x - ScrollPaneSettings.PADDING_RIGHT;
					}
					
					if (item.y + this._content.y < 0) {
						deltaY = ScrollPaneSettings.PADDING_TOP - this._content.y - item.y;
					} else if (item.y + item.height + this._content.y > this.height) {
						deltaY = this.height - item.y - item.height - this._content.y - ScrollPaneSettings.PADDING_BOTTOM;
					}
					
					TweenLite.to(
						this._content,
						!isNaN(duration)? duration : .6,
						{
							x: this._content.x + deltaX,
							y: this._content.y + deltaY,
							ease: ease != null? ease : Linear.easeNone,
							easeParams: easeParams
						}
					);
				}
			}
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
				
				super.width = this.width;
				super.height = this.height;
				
				this._background.width = this.width;
				this._content.width = this.width;
				this._mask.width = this.width;
				
				this._background.height = this.height;
				this._content.height = this.height;
				this._mask.height = this.height;
			}
		}
		
		private function handleAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
			
			super.addChild(this._background);
			super.addChild(this._content);
			super.addChild(this._mask);
			
			this._background.x = 0;
			this._background.y = 0;
			
			this._content.x = 0;
			this._content.y = 0;
			
			this._mask.x = 0;
			this._mask.y = 0;
			
			//this._content.mask = this._mask;
			this._mask.visible = false;
			
			this.updateSize();
		}
		
	}

}