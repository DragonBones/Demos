package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import starling.core.Starling;

	[SWF(width = "800", height = "600", frameRate = "30", backgroundColor = "#cccccc")]
	public class Example_AnimationCopy extends flash.display.Sprite
	{

		public function Example_AnimationCopy()
		{
			stage.addEventListener(MouseEvent.CLICK, mouseHandler);
			starlingInit();
		}

		private function mouseHandler(e: MouseEvent): void
		{
			switch(e.type)
			{
				case MouseEvent.CLICK:
					StarlingGame.instance.changeAnimation();
					break;
			}
		}

		private function starlingInit(): void
		{
			var _starling: Starling = new Starling(StarlingGame, stage);
			_starling.showStats = true;
			_starling.start();
		}
	}
}
import flash.events.Event;

import dragonBones.Armature;
import dragonBones.animation.WorldClock;
import dragonBones.factories.StarlingFactory;
import dragonBones.objects.ArmatureData;
import dragonBones.objects.DragonBonesData;

import starling.display.Sprite;
import starling.events.EnterFrameEvent;

class StarlingGame extends Sprite
{
	[Embed(source = "../assets/Zombie_output.png", mimeType = "application/octet-stream")]
	private static const ResourcesData: Class;

	public static var instance: StarlingGame;

	private var _factory: StarlingFactory;
	private var _armature1: Armature;
	private var _armature12: Armature;
	
	private var _armature2: Armature;
	private var _armature21: Armature;

	public function StarlingGame()
	{
		instance = this;

		_factory = new StarlingFactory();
		_factory.parseData(new ResourcesData());
		_factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e: Event): void
	{
		var skeletonData:DragonBonesData = _factory.getSkeletonData("Zombie");
		var armatures:Vector.<ArmatureData> = skeletonData.armatureDataList.concat();
		
		var armatureName1: String = armatures.splice(int(Math.random() * armatures.length), 1)[0].name;
		var armatureName2: String = armatures.splice(int(Math.random() * armatures.length), 1)[0].name;

		_armature1 = _factory.buildArmature(armatureName1);
		_armature2 = _factory.buildArmature(armatureName2);
		
		_armature12 = _factory.buildArmature(armatureName1);
		_factory.copyAnimationsToArmature(_armature12,armatureName2);
		
		_armature21 = _factory.buildArmature(armatureName2);
		_factory.copyAnimationsToArmature(_armature21,armatureName1);
		
//		_armature11 = _factory.buildArmature(armatureName1);
//		_armature21 = _factory.buildArmature(armatureName2, armatureName1);
//		_armature22 = _factory.buildArmature(armatureName2);
//		_armature12 = _factory.buildArmature(armatureName1, armatureName2);

		var display: Sprite;
		display = _armature1.display as Sprite;
		display.x = 300;
		display.y = 200;
		this.addChild(display);
		display = _armature2.display as Sprite;
		display.x = 500;
		display.y = 200;
		this.addChild(display);
		display = _armature21.display as Sprite;
		display.x = 300;
		display.y = 400;
		this.addChild(display);
		display = _armature12.display as Sprite;
		display.x = 500;
		display.y = 400;
		this.addChild(display);

		WorldClock.clock.add(_armature1);
		WorldClock.clock.add(_armature21);
		WorldClock.clock.add(_armature2);
		WorldClock.clock.add(_armature12);

		changeAnimation();
		
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);
	}

	public function changeAnimation(): void
	{
		var animationName: String;

		do {
			animationName = _armature1.animation.animationList[int(Math.random() * _armature1.animation.animationList.length)];
		} while (animationName == _armature1.animation.lastAnimationName);
		_armature1.animation.gotoAndPlay(animationName);
		_armature21.animation.gotoAndPlay(animationName);

		animationName = null;

		do {
			animationName = _armature2.animation.animationList[int(Math.random() * _armature2.animation.animationList.length)];
		} while (animationName == _armature2.animation.lastAnimationName);
		_armature2.animation.gotoAndPlay(animationName);
		_armature12.animation.gotoAndPlay(animationName);

	}

	private function enterFrameHandler(_e: EnterFrameEvent): void
	{
		WorldClock.clock.advanceTime(-1);
	}
}