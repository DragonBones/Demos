package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="30", backgroundColor="#cccccc")]
	public class Example_AnimationCopy extends flash.display.Sprite {

		public function Example_AnimationCopy() {
			stage.addEventListener(MouseEvent.CLICK, mouseHandler);
			starlingInit();
		}

		private function mouseHandler(e:MouseEvent):void 
		{
			switch(e.type) {
				case MouseEvent.CLICK:
					StarlingGame.instance.changeMovement();
					break;
			}
		}

		private function starlingInit():void {
			var _starling:Starling = new Starling(StarlingGame, stage);
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
import dragonBones.objects.SkeletonData;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Zombie_output.png", mimeType = "application/octet-stream")]
	private static const ResourcesData:Class;

	public static var instance:StarlingGame;

	private var factory:StarlingFactory;
	private var armature11:Armature;
	private var armature21:Armature;
	private var armature22:Armature;
	private var armature12:Armature;

	public function StarlingGame() {
		instance = this;

		factory = new StarlingFactory();
		factory.parseData(new ResourcesData());
		factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e:Event):void {
		var skeletonData:SkeletonData = factory.getSkeletonData("Zombie");
		var armatureNames:Vector.<String> = skeletonData.armatureNames;
		
		var armatureName1:String = armatureNames.splice(int(Math.random() * armatureNames.length), 1)[0];
		var armatureName2:String = armatureNames.splice(int(Math.random() * armatureNames.length), 1)[0];
		
		armature11 = factory.buildArmature(armatureName1);
		armature21 = factory.buildArmature(armatureName2, armatureName1);
		armature22 = factory.buildArmature(armatureName2);
		armature12 = factory.buildArmature(armatureName1, armatureName2);
		
		var _display:Sprite;
		_display = armature11.display as Sprite;
		_display.x = 300;
		_display.y = 200;
		addChild(_display);
		_display = armature21.display as Sprite;
		_display.x = 500;
		_display.y = 200;
		addChild(_display);
		_display = armature22.display as Sprite;
		_display.x = 300;
		_display.y = 400;
		addChild(_display);
		_display = armature12.display as Sprite;
		_display.x = 500;
		_display.y = 400;
		addChild(_display);
		
		WorldClock.clock.add(armature11);
		WorldClock.clock.add(armature21);
		WorldClock.clock.add(armature22);
		WorldClock.clock.add(armature12);
		
		changeMovement();
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}

	public function changeMovement():void 
	{
		var _movement:String;
		
		do{
			_movement = armature11.animation.movementList[int(Math.random() * armature11.animation.movementList.length)];
		}while (_movement == armature11.animation.movementID);
		armature11.animation.gotoAndPlay(_movement);
		armature21.animation.gotoAndPlay(_movement);
		
		_movement = null;
		
		do{
			_movement = armature22.animation.movementList[int(Math.random() * armature22.animation.movementList.length)];
		}while (_movement == armature22.animation.movementID);
		armature22.animation.gotoAndPlay(_movement);
		armature12.animation.gotoAndPlay(_movement);
		
	}

	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		WorldClock.clock.advanceTime(-1);
	}
}