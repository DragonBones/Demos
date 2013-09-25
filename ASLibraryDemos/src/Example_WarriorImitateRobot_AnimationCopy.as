package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class Example_WarriorImitateRobot_AnimationCopy extends flash.display.Sprite {

		public function Example_WarriorImitateRobot_AnimationCopy() {
			starlingInit();
			stage.addEventListener(MouseEvent.CLICK, mouseHandler);
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
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
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

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Warrior_output/skeleton.xml", mimeType = "application/octet-stream")]
	public static const WarriorSkeletonXMLData:Class;
	
	[Embed(source = "../assets/Warrior_output/texture.xml", mimeType = "application/octet-stream")]
	public static const WarriorTextureXMLData:Class;
	
	[Embed(source = "../assets/Warrior_output/texture@0.5x.png")]
	public static const WarriorTextureData:Class;
	
	[Embed(source = "../assets/Robot_output.swf", mimeType = "application/octet-stream")]
	public static const RobotData:Class;

	public static var instance:StarlingGame;

	private var factory:StarlingFactory;
	
	private var armatureRobot:Armature;
	private var armatureWarriorWithRobotAnimation:Armature;
	private var currentMovementIndex:int = 0;
	private var textField:TextField;
	
	public function StarlingGame() {
		instance = this;
		
		factory = new StarlingFactory();

		//skeletonData
		var skeletonData:SkeletonData = XMLDataParser.parseSkeletonData(XML(new WarriorSkeletonXMLData()));
		factory.addSkeletonData(skeletonData, "warriorData");
		
		var textureAtlas:StarlingTextureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureData().bitmapData, true, false, 0.5), 
			XML(new WarriorTextureXMLData()),
			false
		);
		factory.addTextureAtlas(textureAtlas, "warriorData");
		
		factory.parseData(new RobotData());
		factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}
	
	private function textureCompleteHandler(e:Event):void
	{
		textField = new TextField(700, 30, "The Warrior will imitate the Robot. Click mouse to switch animation.", "Verdana", 16, 0, true);
		textField.x = 75;
		textField.y = 5;
		addChild(textField);
		
		var armatureWarriorName:String = "warrior";
		var armatureRobotName:String = "robot";
		
		armatureRobot = factory.buildArmature(armatureRobotName);
		armatureWarriorWithRobotAnimation = factory.buildArmature(armatureWarriorName, armatureRobotName);
		
		var _display:Sprite;
		_display = armatureWarriorWithRobotAnimation.display as Sprite;
		_display.scaleX = _display.scaleY = 0.5;
		_display.x = 600;
		_display.y = 370;
		addChild(_display);
		
		_display = armatureRobot.display as Sprite;
		//_display.scaleX = _display.scaleY = 0.7;
		_display.x = 220;
		_display.y = 300;
		addChild(_display);
		
		WorldClock.clock.add(armatureRobot);
		WorldClock.clock.add(armatureWarriorWithRobotAnimation);
		
		changeMovement();
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}

	public function changeMovement():void 
	{
		var movement:String = armatureRobot.animation.movementList[currentMovementIndex % armatureRobot.animation.movementList.length];
		currentMovementIndex++;
		
		armatureRobot.animation.gotoAndPlay(movement);
		armatureWarriorWithRobotAnimation.animation.gotoAndPlay(movement);
	}

	private function onEnterFrameHandler(_e:EnterFrameEvent):void 
	{
		WorldClock.clock.advanceTime(-1);
	}
}