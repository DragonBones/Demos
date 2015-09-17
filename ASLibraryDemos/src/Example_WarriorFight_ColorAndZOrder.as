package
{
	import flash.display.Sprite;
	
	import starling.core.Starling;

	[SWF(width = "800", height = "600", frameRate = "60", backgroundColor = "#cccccc")]
	public class Example_WarriorFight_ColorAndZOrder extends flash.display.Sprite
	{

		public function Example_WarriorFight_ColorAndZOrder()
		{
			starlingInit();
		}

		private function starlingInit(): void
		{
			var starling: Starling = new Starling(StarlingGame, stage);
			starling.showStats = true;
			starling.start();
		}
	}
}

import dragonBones.Armature;
import dragonBones.animation.WorldClock;
import dragonBones.events.AnimationEvent;
import dragonBones.events.FrameEvent;
import dragonBones.factories.StarlingFactory;
import dragonBones.objects.DragonBonesData;
import dragonBones.objects.XMLDataParser;
import dragonBones.textures.StarlingTextureAtlas;

import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.textures.Texture;

class StarlingGame extends Sprite
{
	[Embed(source = "../assets/Warrior_output/skeleton.xml", mimeType = "application/octet-stream")]
	public static const WarriorSkeletonXMLData: Class;

	[Embed(source = "../assets/Warrior_output/texture.xml", mimeType = "application/octet-stream")]
	public static const WarriorTextureXMLData: Class;

	[Embed(source = "../assets/Warrior_output/texture.png")]
	public static const WarriorTextureData: Class;

	private var _factory: StarlingFactory;

	private var _armature1: Armature;
	private var _armature2: Armature;

	public function StarlingGame()
	{
		_factory = new StarlingFactory();

		var skeletonData:DragonBonesData = XMLDataParser.parseDragonBonesData(XML(new WarriorSkeletonXMLData()));
		_factory.addSkeletonData(skeletonData, "warriorData");

		var textureAtlas: StarlingTextureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureData().bitmapData),
			XML(new WarriorTextureXMLData())
		);
		_factory.addTextureAtlas(textureAtlas, "warriorData");

		_armature1 = _factory.buildArmature("warrior");
		_armature2 = _factory.buildArmature("warrior");

		_armature1.animation.gotoAndPlay("ready");
		_armature2.animation.gotoAndPlay("ready");

		_armature1.addEventListener(AnimationEvent.LOOP_COMPLETE, animationEventHandler);
		_armature1.addEventListener(FrameEvent.ANIMATION_FRAME_EVENT, frameEventHandler);
		_armature2.addEventListener(AnimationEvent.LOOP_COMPLETE, animationEventHandler);
		_armature2.addEventListener(FrameEvent.ANIMATION_FRAME_EVENT, frameEventHandler);

		var display: Sprite;
		display = _armature1.display as Sprite;
		display.scaleX = -1;
		display.x = 200;
		display.y = 350;
		this.addChild(display);

		display = _armature2.display as Sprite;
		display.x = 600;
		display.y = 350;
		this.addChild(display);

		WorldClock.clock.add(_armature1);
		WorldClock.clock.add(_armature2);

		this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);
		this.alpha = 0.999999;
	}

	private function animationEventHandler(e: AnimationEvent): void
	{
		switch(e.type)
		{
			case AnimationEvent.COMPLETE:
				break;
			
			case AnimationEvent.LOOP_COMPLETE:
				if(Math.random() > 0.5)
				{
					e.armature.animation.gotoAndPlay("attack");
				}
				break;
		}
	}
	private function frameEventHandler(e: FrameEvent): void
	{
		if(e.frameLabel == "hitTarget")
		{
			var target: Armature = e.armature == _armature1 ? _armature2 : _armature1;
			target.animation.gotoAndPlay("hit");
		}
	}

	private function enterFrameHandler(e: EnterFrameEvent): void
	{
		WorldClock.clock.advanceTime(-1);
	}
}