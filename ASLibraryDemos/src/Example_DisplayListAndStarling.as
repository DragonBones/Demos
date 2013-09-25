package  {
	import flash.display.Sprite;
	import flash.events.Event;
	
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	import dragonBones.factorys.NativeFactory;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="30", backgroundColor="#cccccc")]
	public class Example_DisplayListAndStarling extends flash.display.Sprite {
		[Embed(source = "../assets/Knight_output.swf", mimeType = "application/octet-stream")]
		public static const KnightData:Class;

		[Embed(source = "../assets/Cyborg_output.swf", mimeType = "application/octet-stream")]
		public static const CyborgData:Class;

		public function Example_DisplayListAndStarling() {
			baseInit();
			starlingInit();
		}
		
		private var factory:NativeFactory;
		private var knight:Armature;
		private var cyborg:Armature;
		private function baseInit():void {
			factory = new NativeFactory();
			factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
			
			factory.parseData(new KnightData());
			factory.parseData(new CyborgData());
		}
		
		private function textureCompleteHandler(e:Event):void {
			knight = factory.buildArmature("knight");
			knight.display.x = 250;
			knight.display.y = 200;
			knight.animation.gotoAndPlay("run");
			addChild(knight.display as Sprite);			

		    cyborg = factory.buildArmature("cyborg");
			cyborg.display.x = 550;
			cyborg.display.y = 200;
			cyborg.animation.gotoAndPlay("run");
			addChild(cyborg.display as Sprite);
			
			WorldClock.clock.add(knight);
			WorldClock.clock.add(cyborg);
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler2);
			
		}
		
		private function onEnterFrameHandler2(_e:Event):void {
			WorldClock.clock.advanceTime(-1);
		}

		
		private function starlingInit():void {
			var _starling:Starling = new Starling(StarlingGame, stage);
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
		}
		
	}
}

import flash.events.Event;

import starling.display.Sprite;
import starling.events.EnterFrameEvent;

import dragonBones.Armature;
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;

class StarlingGame extends Sprite {
	
	
	private var factory:StarlingFactory;
	private var knight:Armature;
	private var cyborg:Armature;
	public function StarlingGame() {
		factory = new StarlingFactory();
		factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
			
		factory.parseData(new Example_DisplayListAndStarling.KnightData());
		factory.parseData(new Example_DisplayListAndStarling.CyborgData());
	}

	private function textureCompleteHandler(e:Event):void {
		
		knight = factory.buildArmature("knight");
		knight.display.x = 250;
		knight.display.y = 400;
		knight.animation.gotoAndPlay("run");
		addChild(knight.display as Sprite);

		cyborg = factory.buildArmature("cyborg");
		cyborg.display.x = 550;
		cyborg.display.y = 400;
		cyborg.animation.gotoAndPlay("run");
		addChild(cyborg.display as Sprite);
		
		WorldClock.clock.add(knight);
		WorldClock.clock.add(cyborg);

		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}

	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		WorldClock.clock.advanceTime(-1);
	}
}
