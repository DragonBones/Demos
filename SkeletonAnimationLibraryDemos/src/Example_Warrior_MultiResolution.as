package  {
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class Example_Warrior_MultiResolution extends flash.display.Sprite 
	{
		[Embed(source = "../assets/Warrior_output/texture.png")]
		public static const WarriorTextureHDData:Class;
	
		public var myStage:Stage;
		public function Example_Warrior_MultiResolution()
		{
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

		private function starlingInit():void 
		{
			myStage = (stage!= null)? stage : this.parent.stage;
			var _starling:Starling = new Starling(StarlingGame, myStage);
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
		}
	}
}

import flash.geom.Point;

import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.TouchEvent;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

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
	
	[Embed(source = "../assets/Warrior_output/texture_sd@0.3.xml", mimeType = "application/octet-stream")]
	public static const WarriorTextureXMLSD2Data:Class;
	
	[Embed(source = "../assets/Warrior_output/texture.png")]
	public static const WarriorTextureHDData:Class;
	
	[Embed(source = "../assets/Warrior_output/texture_sd@0.5x.png")]
	public static const WarriorTextureSD1Data:Class;
	
	[Embed(source = "../assets/Warrior_output/texture_sd@0.3x.png")]
	public static const WarriorTextureSD2Data:Class;

	public static var instance:StarlingGame;

	private var factory:StarlingFactory;
	private var armatures:Vector.<Armature>;
	private var currentMovementIndex:int = 0;
	
	public function StarlingGame() {
		instance = this;
		
		armatures = new Vector.<Armature>;
		
		factory = new StarlingFactory();
		
		//skeletonData
		var skeletonData:SkeletonData = XMLDataParser.parseSkeletonData(XML(new WarriorSkeletonXMLData()));
		factory.addSkeletonData(skeletonData, "warrior");
		
		var textureAtlas:TextureAtlas;
		
		//HD
		textureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureHDData().bitmapData), 
			XML(new WarriorTextureXMLData())
		);
		factory.addTextureAtlas(textureAtlas, "warriorHD");
		
		//SD1 with same textureXML
		textureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureSD1Data().bitmapData, true, false, 0.5), 
			XML(new WarriorTextureXMLData())
		);
		factory.addTextureAtlas(textureAtlas, "warriorSD1");
		
		//SD2 with different textureXML
		/*
		textureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureSD1Data().bitmapData, true, false, 0.5), 
			XML(new WarriorTextureXMLData()),
			true
		);
		*/
		textureAtlas = new TextureAtlas(
			Texture.fromBitmapData(new WarriorTextureSD2Data().bitmapData, true, false, 0.3), 
			XML(new WarriorTextureXMLSD2Data())
		);
		factory.addTextureAtlas(textureAtlas, "warriorSD2");
		
		//
		var armature:Armature;
		
		armature = factory.buildArmature("warrior", null, "warrior", "warriorSD2");
		armature.display.x = 100;
		armature.display.y = 300;
		armature.display.scaleX = armature.display.scaleY = 0.3;
		addChild(armature.display as Sprite);
		WorldClock.clock.add(armature);
		armatures.push(armature);
		
		armature = factory.buildArmature("warrior", null, "warrior", "warriorSD1");
		armature.display.x = 270;
		armature.display.y = 300;
		armature.display.scaleX = armature.display.scaleY = 0.5;
		addChild(armature.display as Sprite);
		WorldClock.clock.add(armature);
		armatures.push(armature);
		
		armature = factory.buildArmature("warrior", null, "warrior", "warriorHD");
		armature.display.x = 600;
		armature.display.y = 300;
		addChild(armature.display as Sprite);
		WorldClock.clock.add(armature);
		armatures.push(armature);
		
		changeMovement();
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}

	public function changeMovement():void 
	{
		var armature:Armature = armatures[0];
		var _movement:String = armature.animation.movementList[currentMovementIndex % armature.animation.movementList.length];
		for each(armature in armatures){
			armature.animation.gotoAndPlay(_movement);
		}
		currentMovementIndex++;
	}

	private function onEnterFrameHandler(_e:EnterFrameEvent):void {

		WorldClock.clock.advanceTime(-1);
	}
}