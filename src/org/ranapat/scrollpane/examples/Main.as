package org.ranapat.scrollpane.examples {
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import org.ranapat.scrollpane.ScrollBar;
	import org.ranapat.scrollpane.ScrollBarConstants;
	import org.ranapat.scrollpane.ScrollPane;
	import org.ranapat.scrollpane.ScrollPaneConstants;
	import org.ranapat.scrollpane.ScrollPaneSettings;
	
	public class Main extends Sprite {
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			test();
		}
		
		private function test():void {
			/*
			var background:Sprite = new Sprite();
			
			background.graphics.beginFill(0xff0000, 1);
			background.graphics.drawRect(0, 0, 300, 300);
			background.graphics.endFill();
			
			addChild(background);
			background.x = 10;
			background.y = 10;
			background.width = 300;
			background.height = 300;
			
			var r:Sprite = new Sprite();
			//r.graphics.beginFill(0x000000, 1);
			r.graphics.drawRect(0, 0, 300, 300);
			//r.graphics.endFill();
			addChild(r);
			r.x = 10;
			r.y = 10;
			r.width = 300;
			r.height = 300;
			
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0xffffff, 1);
			mask.graphics.drawRect(0, 0, 300, 300);
			mask.graphics.endFill();
			addChild(mask);
			mask.width = 300;
			mask.height = 300;
			mask.x = 10;
			mask.y = 10;
			
			//r.mask = mask;
			mask.visible = false;
			
			for (var i:uint = 0; i < 10; ++i) {
				var s:Sprite = new Sprite();
				
				s.graphics.beginFill(Math.random() * 0xffffff, 1);
				s.graphics.drawRect(0, 0, 300 - 20, 50);
				s.graphics.endFill();
				
				r.addChild(s);
				
				s.x = 10;
				s.y = 10 + i * 70;
				s.width = 300 - 20;
				s.height = 50;
			}
			
			//r.y -= 20;
			
			*/
			
			//var scrollPane:ScrollPane = new ScrollPane(ScrollPaneConstants.APPEND_MODE_FREE);
			//var scrollPane:ScrollPane = new ScrollPane(ScrollPaneConstants.APPEND_MODE_ROW, 5);
			var scrollPane:ScrollPane = new ScrollPane(ScrollPaneConstants.APPEND_MODE_COLUMN, 5);
			
			scrollPane.x = 150;
			scrollPane.y = 150;
			scrollPane.width = 520;
			scrollPane.height = 300;
			addChild(scrollPane);
			
			var something:Vector.<Sprite> = new Vector.<Sprite>();
			for (var i:uint = 0; i < 60; ++i) {
				var s:Sprite = new Sprite();
					
				s.graphics.beginFill(Math.random() * 0xffffff, 1);
				s.graphics.drawRect(0, 0, 300 - 20, 50);
				s.graphics.endFill();
				
				//
				var bgRed:Shape = new Shape()
				bgRed.graphics.beginFill( 0xFF0000 );
				bgRed.graphics.drawRect( 0, 0, 200, 30 );
				bgRed.graphics.endFill();
 
				var bgBlack:Sprite = new Sprite();
				bgBlack.graphics.beginFill( 0x000000 );
				bgBlack.graphics.drawRect( 0, 0, 200, 30 );
				bgBlack.graphics.endFill();
				 
				var tf:TextFormat = new TextFormat();
				tf.color = 0xFFFFFF;
				tf.font = "Verdana";
				tf.size = 17;
				tf.align = "center";
				 
				var txt:TextField = new TextField();
				txt.text = "Snipplr Rocks! (" + i + " )";
				txt.x = 0;
				txt.y = 0;
				txt.width = bgRed.width;
				txt.height = bgRed.height;
				txt.setTextFormat( tf );
				 
				var mc:MovieClip = new MovieClip();
				mc.addChild( bgRed );
				mc.addChild( txt );
				 
				var btn:SimpleButton = new SimpleButton();
				btn.upState = mc;
				btn.overState = bgBlack;
				btn.downState = btn.upState;
				btn.hitTestState = btn.upState;
				btn.x = stage.stageWidth / 2 - btn.width;
				btn.y = stage.stageHeight / 2 - btn.height;
				//
				
				/*
				s.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
					trace("we are here " + e.target.name)
				}, false, 0, true);
				s.addEventListener(MouseEvent.MOUSE_OVER, function (e:MouseEvent):void {
					trace("we are here mouse_over " + e.target.name)
				}, false, 0, true);
				s.addEventListener(MouseEvent.MOUSE_OUT, function (e:MouseEvent):void {
					trace("we are here mouse_out " + e.target.name)
				}, false, 0, true);
				*/
				
				btn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
					trace("we are here click " + e.target.name)
				});
				btn.addEventListener(MouseEvent.MOUSE_OVER, function (e:MouseEvent):void {
					trace("we are here mouse_over " + e.target.name)
				});
				btn.addEventListener(MouseEvent.MOUSE_OUT, function (e:MouseEvent):void {
					trace("we are here mouse_out " + e.target.name)
				});
				
				//s.x = 10;
				//s.y = 10 + i * 70;
				s.width = 700 - 20;
				s.height = 20 + Math.random() * 100;
				
				/*
				var tt:TextField = new TextField();
				tt.text = "sprite " + i;
				tt.width = s.width;
				tt.height = s.height;
				s.addChild(tt);
				*/
				
				//scrollPane.appendChild(s);
				//scrollPane.appendChild(btn);
				
				something.push(s);
				
				
				var ss:Sprite = new Sprite();
					
				ss.graphics.beginFill(Math.random() * 0xffffff, 1);
				ss.graphics.drawRect(0, 0, 100, 50);
				ss.graphics.endFill();
				
				var tttt:TextField = new TextField();
				tttt.name = "tttt";
				tttt.width = ss.width;
				tttt.height = ss.height;
				tttt.mouseEnabled = false;
				var ttttf:TextFormat = new TextFormat();
				ttttf.align = TextFormatAlign.CENTER;
				ttttf.color = 0xffffff;
				ttttf.size = 20;
				tttt.defaultTextFormat = ttttf;
				tttt.text = i.toString();
				ss.addChild(tttt);
				
				ss.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
					/*
					e.target.graphics.beginFill(Math.random() * 0xffffff, 1);
					e.target.graphics.drawRect(0, 0, 100, 50);
					e.target.graphics.endFill();
					*/
					//trace(scrollPane.removeAllChildren().length);
					scrollPane.removeChild(e.target as DisplayObject);
				});
				
				//TweenLite.delayedCall(0, scrollPane.appendChild, [ ss ]);
				scrollPane.appendChild(ss);
			}
			
			//scrollPane.focus(scrollPane.getChildAt(150));
			
			//scrollPane.scrollX = -425;
			//scrollPane.scrollY = 140;
			
			//scrollPane.scrollYTo(420);
			
			//scrollPane.focus(something[10], Elastic.easeInOut);
			//scrollPane.snap(something[19], ScrollPaneConstants.SNAP_TO_BOTTOM, Elastic.easeInOut);
			
			//scrollPane.scroll(-1);
			//scrollPane.scrollY = 425;
			
			var scroll1:ScrollBar = new ScrollBar(ScrollBarConstants.MODE_HORIZONTAL);
			scroll1.x = scrollPane.x;
			scroll1.y = scrollPane.y + scrollPane.height + 10;
			scroll1.width = scrollPane.width;
			scroll1.height = 10;
			addChild(scroll1);
			scrollPane.addScrollBar(scroll1);
			
			var scroll2:ScrollBar = new ScrollBar(ScrollBarConstants.MODE_VERTICAL);
			scroll2.x = scrollPane.x - 20;
			scroll2.y = scrollPane.y;
			scroll2.width = 10;
			scroll2.height = scrollPane.height;
			addChild(scroll2);
			scrollPane.addScrollBar(scroll2);
			
			//scroll.offset = scrollPane.scrollYPercents;
			//scroll.percents = scrollPane.visibilityYProportion;
			
			
			
		}
	}
	
}