package  
{
	import flash.display.Sprite;
	
	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class Example_Robot_AnimationMixing extends flash.display.Sprite 
	{
		public function Example_Robot_AnimationMixing() 
		{
			starlingInit();
		}

		private function starlingInit():void 
		{
			var starling:Starling = new Starling(StarlingGame, stage);
			starling.showStats = true;
			starling.start();
		}
	}
}

import flash.events.Event;

import dragonBones.Armature;
import dragonBones.animation.WorldClock;
import dragonBones.factories.StarlingFactory;

import starling.display.Sprite;
import starling.events.EnterFrameEvent;

class StarlingGame extends Sprite 
{
	[Embed(source = "../assets/Robot.dbswf", mimeType = "application/octet-stream")]
	private static const ResourcesData:Class;
	
	private var _factory:StarlingFactory;
	private var _armature:Armature;
	
	public function StarlingGame() 
	{

		_factory = new StarlingFactory();
		
		_factory.parseData(new ResourcesData());
		_factory.addEventListener(flash.events.Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e:flash.events.Event):void 
	{
		_armature = _factory.buildArmature("robot");
		_armature.animation.gotoAndPlay("stop");
		_armature.animation.gotoAndPlay("run2", -1, -1, NaN, 1)
			.addBoneMask("innerarm_upper")
			.addBoneMask("outerarm_upper");
		
		WorldClock.clock.add(_armature);
		
		var display:Sprite = _armature.display as Sprite;
		display.x = 400;
		display.y = 300;
		this.addChild(display);
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);
	}
	
	private function enterFrameHandler(e:EnterFrameEvent):void 
	{
		WorldClock.clock.advanceTime(-1);
	}
}