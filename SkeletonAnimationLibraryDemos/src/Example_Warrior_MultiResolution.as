package  {
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import flash.events.MouseEvent;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class Example_Warrior_MultiResolution extends flash.display.Sprite 
	{
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
			var _starling:Starling = new Starling(StarlingGame, stage);
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
	
	[Embed(source = "../assets/Warrior_output/texture@2x.xml", mimeType = "application/octet-stream")]
	public static const WarriorTextureHDXMLData:Class;
	
	[Embed(source = "../assets/Warrior_output/texture.xml", mimeType = "application/octet-stream")]
	public static const WarriorTextureSDXMLData:Class;
	
	[Embed(source = "../assets/Warrior_output/texture@0.3x.xml", mimeType = "application/octet-stream")]
	public static const WarriorTextureSD2XMLData:Class;
	
	[Embed(source = "../assets/Warrior_output/texture@2x.png")]
	public static const WarriorTextureHDData:Class;
	
	[Embed(source = "../assets/Warrior_output/texture.png")]
	public static const WarriorTextureSDData:Class;
	
	[Embed(source = "../assets/Warrior_output/texture@0.5x.png")]
	public static const WarriorTextureSD1Data:Class;
	
	[Embed(source = "../assets/Warrior_output/texture@0.3x.png")]
	public static const WarriorTextureSD2Data:Class;

	public static var instance:StarlingGame;

	private var factory:StarlingFactory;
	private var armatures:Vector.<Armature>;
	private var currentMovementIndex:int = 0;
	private var textField:TextField;
	
	public function StarlingGame() {
		instance = this;
		
		armatures = new Vector.<Armature>;
		
		factory = new StarlingFactory();
		
		//skeletonData
		var skeletonData:SkeletonData = XMLDataParser.parseSkeletonData(XML(new WarriorSkeletonXMLData()));
		factory.addSkeletonData(skeletonData, "warrior");
		
		var textureAtlas:TextureAtlas;
		
		//contentScaleFactor == 2
		//HD 2x(use different textureXML 2x)
		//高清贴图，由面板导出时设置scale为2输出，textureXML与texture对应
		textureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureHDData().bitmapData, false, false, 2), 
			XML(new WarriorTextureHDXMLData()),
			true
		);
		/*
		textureAtlas = new TextureAtlas(
			Texture.fromBitmapData(new WarriorTextureHDData().bitmapData, false, false, 2), 
			XML(new WarriorTextureHDXMLData())
		);
		*/
		factory.addTextureAtlas(textureAtlas, "warriorHD");
		
		//contentScaleFactor == 1
		//SD 1x
		//标准贴图，由面板导出时设置scale为1输出，textureXML与texture对应
		textureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureSDData().bitmapData, false, false, 1), 
			XML(new WarriorTextureSDXMLData()), 
			false
		);
		factory.addTextureAtlas(textureAtlas, "warriorSD");
		
		//contentScaleFactor == 0.5
		//SD1 0.5x(use same textureXML 1x)
		//缩放为0.5的贴图，由1x的texture缩放直接缩放得到，使用1x的textureXML
		textureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureSD1Data().bitmapData, false, false, 0.5), 
			XML(new WarriorTextureSDXMLData()), 
			false
		);
		factory.addTextureAtlas(textureAtlas, "warriorSD1");
		
		//contentScaleFactor == 0.3
		//SD2 0.3x(use different textureXML 0.3x)
		//缩放为0.3的贴图，由面板导出时设置scale为0.3输出，textureXML与texture对应
		
		/*textureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureSD2Data().bitmapData, false, false, 0.3), 
			XML(new WarriorTextureSD2XMLData()),
			true
		);*/
		textureAtlas = new TextureAtlas(
			Texture.fromBitmapData(new WarriorTextureSD2Data().bitmapData, false, false, 0.3), 
			XML(new WarriorTextureSD2XMLData())
		);
		
		factory.addTextureAtlas(textureAtlas, "warriorSD2");
		
		//
		var armature:Armature;
		
		armature = factory.buildArmature("warrior", null, "warrior", "warriorHD");
		armature.display.x = 150;
		armature.display.y = 300;
		//armature.display.scaleX = armature.display.scaleY = 0.3;
		addChild(armature.display as Sprite);
		WorldClock.clock.add(armature);
		armatures.push(armature);
		
		armature = factory.buildArmature("warrior", null, "warrior", "warriorSD");
		armature.display.x = 300;
		armature.display.y = 300;
		//armature.display.scaleX = armature.display.scaleY = 0.3;
		addChild(armature.display as Sprite);
		WorldClock.clock.add(armature);
		armatures.push(armature);
		
		armature = factory.buildArmature("warrior", null, "warrior", "warriorSD1");
		armature.display.x = 450;
		armature.display.y = 300;
		//armature.display.scaleX = armature.display.scaleY = 0.5;
		addChild(armature.display as Sprite);
		WorldClock.clock.add(armature);
		armatures.push(armature);
		
		armature = factory.buildArmature("warrior", null, "warrior", "warriorSD2");
		armature.display.x = 600;
		armature.display.y = 300;
		addChild(armature.display as Sprite);
		WorldClock.clock.add(armature);
		armatures.push(armature);
		
		changeMovement();
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
		
		textField = new TextField(700, 50, "Multi-Resolution support. Click mouse to switch animation\nHD  SD  SD1  SD2", "Verdana", 16, 0, true);
		textField.x = 75;
		textField.y = 5;
		addChild(textField);
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