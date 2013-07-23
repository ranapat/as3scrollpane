package org.ranapat.scrollpane.examples {
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
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
			
			var scrollPane:ScrollPane = new ScrollPane();
			scrollPane.x = 50;
			scrollPane.y = 50;
			scrollPane.width = 700;
			scrollPane.height = 500;
			addChild(scrollPane);
			
			var something:Vector.<Sprite> = new Vector.<Sprite>();
			for (var i:uint = 0; i < 20; ++i) {
				var s:Sprite = new Sprite();
					
				s.graphics.beginFill(Math.random() * 0xffffff, 1);
				s.graphics.drawRect(0, 0, 300 - 20, 50);
				s.graphics.endFill();
				
				
				
				s.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
					trace("we are here " + e.target.name)
				});
				
				//s.x = 10;
				//s.y = 10 + i * 70;
				s.width = 700 - 20;
				s.height = 50 + Math.random() * 100;
				
				/*
				var tt:TextField = new TextField();
				tt.text = "sprite " + i;
				tt.width = s.width;
				tt.height = s.height;
				s.addChild(tt);
				*/
				
				scrollPane.appendChild(s);
				
				something.push(s);
			}
			//scrollPane.scrollX = -425;
			//scrollPane.scrollY = 140;
			
			//scrollPane.scrollYTo(420);
			
			//scrollPane.focus(something[10], Elastic.easeInOut);
			scrollPane.snap(something[19], ScrollPaneConstants.SNAP_TO_BOTTOM, Elastic.easeInOut);
			
			//scrollPane.scroll(-1);
			//scrollPane.scrollY = 425;
		}
	}
	
}