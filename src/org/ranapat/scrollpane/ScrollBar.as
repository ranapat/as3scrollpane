package org.ranapat.scrollpane {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	[Event(name = "scrollChanged", type = "org.ranapat.scrollpane.ScrollBarEvent")]
	public class ScrollBar extends Sprite {
		private var _mode:uint;
		private var _offset:Number;
		private var _percents:Number;
		
		private var _width:Number;
		private var _height:Number;
		
		private var _mouseDownMode:Boolean;
		private var _mouseMoved:Boolean;
		private var _modeDirectionIncrease:Boolean;
		private var _latestMouseDownPoint:Point;
		
		protected var _partA:DisplayObject;
		protected var _partB:DisplayObject;
		protected var _partC:DisplayObject;
		
		public var scrollPane:ScrollPane;
		
		public function ScrollBar(_mode:uint) {
			super();
			
			this._partA = new Sprite();
			this._partB = new Sprite();
			this._partC = new Sprite();
			
			this.mode = _mode;
			this.percents = 100;
			
			this.addEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage, false, 0, true);
		}
		
		public function set mode(value:uint):void {
			this._mode = value;
			
			this.redraw();
		}
		
		public function get mode():uint {
			return this._mode;
		}
		
		public function set offset(value:Number):void {
			this._offset = value;
			
			if (this.allowUIUpdateComplete) {
				this.reposition();
			}
		}
		
		public function get offset():Number {
			return this._offset > 100? 100 : this._offset > 0? this._offset : 0;
		}
		
		public function set percents(value:Number):void {
			var toRedraw:Boolean;
			if (this._percents != value) {
				toRedraw = true;
			}
			this._percents = value;
			
			if (toRedraw && this.allowUIUpdateComplete) {
				this.redrawAssets();
			}
		}
		
		public function get percents():Number {
			return this._percents;
		}
		
		public function redraw():void {
			if (!isNaN(this.width) && !isNaN(this.height)) {
				this.redrawBackground();
				
				if (
					(this._mode == ScrollBarConstants.MODE_HORIZONTAL || this._mode == ScrollBarConstants.MODE_VERTICAL)
					&& this._percents > 0 && this._percents <= 100
					&& this._offset >= 0 && this._offset <= 100
				) {
					this.redrawAssets();
					this.reposition();
				}
			}
		}
		
		public function resetEvents():void {
			this.handleMouseUp(null);
		}
		
		override public function set width(value:Number):void {
			this._width = value;
			
			this.redraw();
		}
		
		override public function get width():Number {
			return this._width;
		}
		
		override public function set height(value:Number):void {
			this._height = value;
			
			this.redraw();
		}
		
		override public function get height():Number {
			return this._height;
		}
		
		protected function redrawBackground():void {
			/*
			this.graphics.beginFill(0xff00ff, 1);
			this.graphics.drawRect(0, 0, this.width, this.height);
			this.graphics.endFill();				
			*/
		}
		
		protected function redrawAssets():void {
			/*
			this._partA.graphics.beginFill(0x0000ff, .7);
			this._partA.graphics.drawRect(0, 0, this.partAWidth, this.partAHeight);
			this._partA.graphics.endFill();
			this._partA.width = 10;
			this._partA.height = 10;
			
			this._partB.graphics.beginFill(0xff0000, .7);
			this._partB.graphics.drawRect(0, 0, this.partBWidth, this.partBHeight);
			this._partB.graphics.endFill();
			
			this._partC.graphics.beginFill(0x00ff00, .7);
			this._partC.graphics.drawRect(0, 0, this.partCWidth, this.partCHeight);
			this._partC.graphics.endFill();
			*/
			
			this._partA.width = this.partAWidth;
			this._partA.height = this.partAHeight;
			
			this._partB.width = this.partBWidth;
			this._partB.height = this.partBHeight;
			
			this._partC.width = this.partCWidth;
			this._partC.height = this.partCHeight;			
		}
		
		protected function reposition():void {
			if (this.mode == ScrollBarConstants.MODE_VERTICAL) {
				this._partA.y = this.usefulHeight * this.offset / 100;
				this._partB.y = this._partA.y + this._partA.height;
				this._partC.y = this._partA.y + this._partA.height + this._partB.height;
			} else {
				this._partA.x = this.usefulWidth * this.offset / 100;
				this._partB.x = this._partA.x + this._partA.width;
				this._partC.x = this._partA.x + this._partA.width + this._partB.width;
			}
		}
		
		protected function get usefulWidth():Number {
			return this.width - this._partA.width - this._partB.width - this._partC.width;
		}
		
		protected function get usefulHeight():Number {
			return this.height - this._partA.height - this._partB.height - this._partC.height;
		}
		
		protected function get allowUIUpdateComplete():Boolean {
			if (
				!isNaN(this.width) && !isNaN(this.height)
				&& (this._mode == ScrollBarConstants.MODE_HORIZONTAL || this._mode == ScrollBarConstants.MODE_VERTICAL)
				&& this._percents > 0 && this._percents <= 100
				&& this._offset >= 0 && this._offset <= 100
			) {
				return true;
			} else {
				return false;
			}
		}
		
		protected function addScrollComponentEventListeners(element:DisplayObject):void {
			element.addEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown, false, 0, true);
			element.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp, false, 0, true);
			element.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove, false, 0, true);
		}
		
		protected function removeScrollComponentEventListeners(element:DisplayObject):void {
			element.removeEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown);
			element.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp);
			element.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove);
		}
		
		private function get partAWidth():Number {
			return this.mode == ScrollBarConstants.MODE_VERTICAL? this.width : this.height;
		}
		
		private function get partAHeight():Number {
			return this.mode == ScrollBarConstants.MODE_VERTICAL? this.width : this.height;
		}
		
		private function get partBWidth():Number {
			return this.mode == ScrollBarConstants.MODE_VERTICAL? this.width : (this.width - this.partAWidth - this.partCWidth) * this.percents / 100;
		}
		
		private function get partBHeight():Number {
			return this.mode == ScrollBarConstants.MODE_VERTICAL? (this.height - this.partAHeight - this.partCHeight) * this.percents / 100 : this.height;
		}
		
		private function get partCWidth():Number {
			return this.mode == ScrollBarConstants.MODE_VERTICAL? this.width : this.height;
		}
		
		private function get partCHeight():Number {
			return this.mode == ScrollBarConstants.MODE_VERTICAL? this.width : this.height;
		}
		
		private function handleAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage, false, 0, true);
			
			this.addChild(this._partA);
			this.addChild(this._partB);
			this.addChild(this._partC);
			
			this.addScrollComponentEventListeners(this._partA);
			this.addScrollComponentEventListeners(this._partB);
			this.addScrollComponentEventListeners(this._partC);
			
			/*
			this._partA.buttonMode = true;
			this._partB.buttonMode = true;
			this._partC.buttonMode = true;
			*/
		}
		
		private function handleRemovedFromStage(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage);
			
			this.removeScrollComponentEventListeners(this._partA);
			this.removeScrollComponentEventListeners(this._partB);
			this.removeScrollComponentEventListeners(this._partC);
		}
		
		private function handleMouseDown(e:MouseEvent):void {
			this._mouseDownMode = true;
			this._mouseMoved = false;
			
			this._latestMouseDownPoint = e.target.localToGlobal(new Point(e.localX, e.localY));
		}
		
		private function handleMouseUp(e:MouseEvent):void {
			this._mouseDownMode = false;
			
			this._latestMouseDownPoint = null;
			
			if (this.scrollPane && this._mouseMoved) {
				if (this.mode == ScrollBarConstants.MODE_HORIZONTAL) {
					this.scrollPane.invalidate(this._modeDirectionIncrease? ScrollPaneConstants.DIRECTION_RIGHT : ScrollPaneConstants.DIRECTION_LEFT);
				} else {
					this.scrollPane.invalidate(ScrollPaneConstants.DIRECTION_NONE, this._modeDirectionIncrease? ScrollPaneConstants.DIRECTION_UP: ScrollPaneConstants.DIRECTION_DOWN);
				}
			}
			
			this._mouseMoved = false;
		}
		
		private function handleMouseMove(e:MouseEvent):void {
			if (this._mouseDownMode) {
				this._mouseMoved = true;
				
				var point:Point = e.target.localToGlobal(new Point(e.localX, e.localY));
				
				var deltaX:Number = point.x - this._latestMouseDownPoint.x;
				var deltaY:Number = point.y - this._latestMouseDownPoint.y;
				
				if (this.mode == ScrollBarConstants.MODE_HORIZONTAL) {
					this.offset += deltaX / this.usefulWidth * 100;
					this._modeDirectionIncrease = deltaX > 0;
				} else {
					this.offset += deltaY / this.usefulHeight * 100;
					this._modeDirectionIncrease = deltaY > 0;
				}
				
				if (this.scrollPane) {
					if (this.mode == ScrollBarConstants.MODE_HORIZONTAL) {
						this.scrollPane.scrollXPercents = this.offset;
					} else {
						this.scrollPane.scrollYPercents = this.offset;
					}
				} else {
					this.dispatchEvent(new ScrollBarEvent(ScrollBarEvent.SCROLL_CHANGED, this.offset));
				}
				
				this._latestMouseDownPoint = point;
			}
		}
		
	}

}