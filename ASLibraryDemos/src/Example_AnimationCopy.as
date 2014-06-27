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

import starling.display.Sprite;
import starling.events.EnterFrameEvent;

import dragonBones.Armature;
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;
import dragonBones.objects.SkeletonData;

class StarlingGame extends Sprite
{
	[Embed(source = "../assets/Zombie_output.png", mimeType = "application/octet-stream")]
	private static const ResourcesData: Class;

	public static var instance: StarlingGame;

	private var _factory: StarlingFactory;
	private var _armature11: Armature;
	private var _armature21: Armature;
	private var _armature22: Armature;
	private var _armature12: Armature;

	public function StarlingGame()
	{
		instance = this;

		_factory = new StarlingFactory();
		_factory.parseData(new ResourcesData());
		_factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e: Event): void
	{
		var skeletonData: SkeletonData = _factory.getSkeletonData("Zombie");
		var armatureNames: Vector.<String> = skeletonData.armatureNames;

		var armatureName1: String = armatureNames.splice(int(Math.random() * armatureNames.length), 1)[0];
		var armatureName2: String = armatureNames.splice(int(Math.random() * armatureNames.length), 1)[0];

		_armature11 = _factory.buildArmature(armatureName1);
		_armature21 = _factory.buildArmature(armatureName2, armatureName1);
		_armature22 = _factory.buildArmature(armatureName2);
		_armature12 = _factory.buildArmature(armatureName1, armatureName2);

		var display: Sprite;
		display = _armature11.display as Sprite;
		display.x = 300;
		display.y = 200;
		this.addChild(display);
		display = _armature21.display as Sprite;
		display.x = 500;
		display.y = 200;
		this.addChild(display);
		display = _armature22.display as Sprite;
		display.x = 300;
		display.y = 400;
		this.addChild(display);
		display = _armature12.display as Sprite;
		display.x = 500;
		display.y = 400;
		this.addChild(display);

		WorldClock.clock.add(_armature11);
		WorldClock.clock.add(_armature21);
		WorldClock.clock.add(_armature22);
		WorldClock.clock.add(_armature12);

		changeAnimation();
		
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);
	}

	public function changeAnimation(): void
	{
		var animationName: String;

		do {
			animationName = _armature11.animation.animationList[int(Math.random() * _armature11.animation.animationList.length)];
		} while (animationName == _armature11.animation.lastAnimationName);
		_armature11.animation.gotoAndPlay(animationName);
		_armature21.animation.gotoAndPlay(animationName);

		animationName = null;

		do {
			animationName = _armature22.animation.animationList[int(Math.random() * _armature22.animation.animationList.length)];
		} while (animationName == _armature22.animation.lastAnimationName);
		_armature22.animation.gotoAndPlay(animationName);
		_armature12.animation.gotoAndPlay(animationName);

	}

	private function enterFrameHandler(_e: EnterFrameEvent): void
	{
		WorldClock.clock.advanceTime(-1);
	}
}