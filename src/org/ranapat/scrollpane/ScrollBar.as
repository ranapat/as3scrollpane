package org.ranapat.scrollpane {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class ScrollBar extends Sprite {
		private var _mode:uint;
		private var _offset:Number;
		private var _percents:Number;
		
		private var _width:Number;
		private var _height:Number;
		
		private var _partA:Sprite;
		private var _partB:Sprite;
		private var _partC:Sprite;
		
		private var _mouseDownMode:Boolean;
		private var _mouseMoved:Boolean;
		private var _modeDirectionIncrease:Boolean;
		private var _latestMouseDownPoint:Point;
		
		public var scrollPane:ScrollPane;
		
		public function ScrollBar(_mode:uint) {
			super();
			
			this._partA = new Sprite();
			this._partB = new Sprite();
			this._partC = new Sprite();
			
			this.mode = _mode;
			
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
			
			this.redraw();
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
			
			if (toRedraw) {
				this.redraw();
			}
		}
		
		public function get percents():Number {
			return this._percents;
		}
		
		public function redraw():void {
			if (
				(this._mode == ScrollBarConstants.MODE_HORIZONTAL || this._mode == ScrollBarConstants.MODE_VERTICAL)
				&& this._percents > 0 && this._percents <= 100
				&& this._offset >= 0 && this._offset <= 100
				&& !isNaN(this.width) && !isNaN(this.height)
			) {
				this.redrawAssets();
				
				super.width = this.width;
				super.height = this.height;
				
				this.reposition();
			}
		}
		
		override public function set width(value:Number):void {
			super.width = value;
			
			this._width = value;
			
			this.redraw();
		}
		
		override public function get width():Number {
			return this._width;
		}
		
		override public function set height(value:Number):void {
			super.height = value;
			
			this._height = value;
			
			this.redraw();
		}
		
		override public function get height():Number {
			return this._height;
		}
		
		protected function redrawAssets():void {
			this.graphics.beginFill(0xffffff, 1);
			this.graphics.drawRect(0, 0, this.width, this.height);
			this.graphics.endFill();
			
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
			
			this._partA.width = this.partAWidth;
			this._partA.height = this.partAHeight;
			
			this._partB.width = this.partBWidth;
			this._partB.height = this.partBHeight;
			
			this._partC.width = this.partCWidth;
			this._partC.height = this.partCHeight;			
		}
		
		private function reposition():void {
			if (this.mode == ScrollBarConstants.MODE_VERTICAL) {
				this._partA.y = (this.height - this._partA.height - this._partB.height - this._partC.height) * this.offset / 100;
				this._partB.y = this._partA.y + this._partA.height;
				this._partC.y = this._partA.y + this._partA.height + this._partB.height;
			} else {
				this._partA.x = (this.width - this._partA.width - this._partB.width - this._partC.width) * this.offset / 100;
				this._partB.x = this._partA.x + this._partA.width;
				this._partC.x = this._partA.x + this._partA.width + this._partB.width;
			}
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
			
			this._partA.addEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown, false, 0, true);
			this._partA.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp, false, 0, true);
			this._partA.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove, false, 0, true);
			
			this._partB.addEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown, false, 0, true);
			this._partB.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp, false, 0, true);
			this._partB.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove, false, 0, true);
			
			this._partC.addEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown, false, 0, true);
			this._partC.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp, false, 0, true);
			this._partC.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove, false, 0, true);
			
			this._partA.buttonMode = true;
			this._partB.buttonMode = true;
			this._partC.buttonMode = true;
		}
		
		private function handleRemovedFromStage(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage);
			
			this._partA.removeEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown);
			this._partA.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp);
			this._partA.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove);
			
			this._partB.removeEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown);
			this._partB.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp);
			this._partB.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove);
			
			this._partC.removeEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown);
			this._partC.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp);
			this._partC.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove);
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
					this.offset += deltaX / (this.width - this._partA.width - this._partB.width - this._partC.width) * 100;
					this._modeDirectionIncrease = deltaX > 0;
				} else {
					this.offset += deltaY / (this.height - this._partA.height - this._partB.height - this._partC.height) * 100;
					this._modeDirectionIncrease = deltaY > 0;
				}
				
				if (this.scrollPane) {
					if (this.mode == ScrollBarConstants.MODE_HORIZONTAL) {
						this.scrollPane.scrollXPercents = this.offset;
					} else {
						this.scrollPane.scrollYPercents = this.offset;
					}
				}
				
				this._latestMouseDownPoint = point;
			}
		}
		
	}

}