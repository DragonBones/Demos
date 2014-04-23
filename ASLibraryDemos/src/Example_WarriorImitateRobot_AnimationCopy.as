package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import starling.core.Starling;

	[SWF(width = "800", height = "600", frameRate = "60", backgroundColor = "#cccccc")]
	public class Example_WarriorImitateRobot_AnimationCopy extends flash.display.Sprite
	{

		public function Example_WarriorImitateRobot_AnimationCopy()
		{
			starlingInit();
			stage.addEventListener(MouseEvent.CLICK, mouseHandler);
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
			var starling: Starling = new Starling(StarlingGame, stage);
			starling.showStats = true;
			starling.start();
		}
	}
}

import flash.geom.Point;
import flash.events.Event;

import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.TouchEvent;
import starling.textures.Texture;
import starling.text.TextField;

import dragonBones.Armature;
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;
import dragonBones.objects.XMLDataParser;
import dragonBones.objects.SkeletonData;
import dragonBones.textures.StarlingTextureAtlas;

class StarlingGame extends Sprite
{
	[Embed(source = "../assets/Warrior_output/skeleton.xml", mimeType = "application/octet-stream")]
	public static const WarriorSkeletonXMLData: Class;

	[Embed(source = "../assets/Warrior_output/texture.xml", mimeType = "application/octet-stream")]
	public static const WarriorTextureXMLData: Class;

	[Embed(source = "../assets/Warrior_output/texture@0.5x.png")]
	public static const WarriorTextureData: Class;

	[Embed(source = "../assets/Robot.dbswf", mimeType = "application/octet-stream")]
	public static const RobotData: Class;

	public static var instance: StarlingGame;

	private var _factory: StarlingFactory;

	private var _armatureRobot: Armature;
	private var _armatureWarriorWithRobotAnimation: Armature;
	private var _currentAnimationIndex: int = 0;
	private var _textField: TextField;

	public function StarlingGame()
	{
		instance = this;

		_factory = new StarlingFactory();

		//skeletonData
		var skeletonData: SkeletonData = XMLDataParser.parseSkeletonData(XML(new WarriorSkeletonXMLData()));
		_factory.addSkeletonData(skeletonData, "warriorData");

		var textureAtlas: StarlingTextureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureData().bitmapData, true, false, 0.5),
			XML(new WarriorTextureXMLData()),
			false
		);
		_factory.addTextureAtlas(textureAtlas, "warriorData");

		_factory.parseData(new RobotData());
		_factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e: Event): void
	{
		_textField = new TextField(700, 30, "The Warrior will imitate the Robot. Click mouse to switch animation.", "Verdana", 16, 0, true);
		_textField.x = 75;
		_textField.y = 5;
		this.addChild(_textField);

		var armatureWarriorName: String = "warrior";
		var armatureRobotName: String = "robot";

		_armatureRobot = _factory.buildArmature(armatureRobotName);
		_armatureWarriorWithRobotAnimation = _factory.buildArmature(armatureWarriorName, armatureRobotName);

		var display: Sprite;
		display = _armatureWarriorWithRobotAnimation.display as Sprite;
		display.scaleX = display.scaleY = 0.5;
		display.x = 600;
		display.y = 370;
		this.addChild(display);

		display = _armatureRobot.display as Sprite;
		//display.scaleX = display.scaleY = 0.7;
		display.x = 220;
		display.y = 300;
		this.addChild(display);

		WorldClock.clock.add(_armatureRobot);
		WorldClock.clock.add(_armatureWarriorWithRobotAnimation);

		changeAnimation();

		this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);
	}

	public function changeAnimation(): void
	{
		var movement: String = _armatureRobot.animation.movementList[_currentAnimationIndex % _armatureRobot.animation.movementList.length];
		_currentAnimationIndex++;

		_armatureRobot.animation.gotoAndPlay(movement);
		_armatureWarriorWithRobotAnimation.animation.gotoAndPlay(movement);
	}

	private function enterFrameHandler(e: EnterFrameEvent): void
	{
		WorldClock.clock.advanceTime(-1);
	}
}