package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class Example_WarriorAndRobot extends flash.display.Sprite {

		public function Example_WarriorAndRobot() {
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
	
	private var armature11:Armature;
	private var armature21:Armature;
	private var armature22:Armature;
	private var armature12:Armature;

	public function StarlingGame() {
		instance = this;
		
		factory = new StarlingFactory();
		
		
		//skeletonData
		var skeletonData:SkeletonData = XMLDataParser.parseSkeletonData(XML(new WarriorSkeletonXMLData()));
		factory.addSkeletonData(skeletonData, "warriorData");
		
		var textureAtlas:StarlingTextureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureData().bitmapData, true, false, 0.5), 
			XML(new WarriorTextureXMLData())
		);
		factory.addTextureAtlas(textureAtlas, "warriorData");
		
		factory.parseData(new RobotData());
		factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}
	
	private function textureCompleteHandler(e:Event):void
	{
		
		var armatureName1:String = "warrior";
		var armatureName2:String = "robot";
		
		armature11 = factory.buildArmature(armatureName1);
		armature21 = factory.buildArmature(armatureName2, armatureName1);
		armature22 = factory.buildArmature(armatureName2);
		armature12 = factory.buildArmature(armatureName1, armatureName2);
		
		var _display:Sprite;
		_display = armature11.display as Sprite;
		_display.scaleX = _display.scaleY = 0.5;
		_display.x = 300;
		_display.y = 170;
		addChild(_display);
		
		_display = armature12.display as Sprite;
		_display.scaleX = _display.scaleY = 0.5;
		_display.x = 500;
		_display.y = 430;
		addChild(_display);
		
		_display = armature21.display as Sprite;
		_display.scaleX = _display.scaleY = 0.7;
		_display.x = 500;
		_display.y = 170;
		addChild(_display);
		
		_display = armature22.display as Sprite;
		_display.scaleX = _display.scaleY = 0.7;
		_display.x = 300;
		_display.y = 430;
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