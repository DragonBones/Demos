package  {
	import flash.display.Sprite;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class Example_WarriorFight_ColorAndZOrder extends flash.display.Sprite {

		public function Example_WarriorFight_ColorAndZOrder() {
			starlingInit();
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
import starling.textures.Texture;
import starling.text.TextField;

import dragonBones.Armature;
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;
import dragonBones.objects.XMLDataParser;
import dragonBones.objects.SkeletonData;
import dragonBones.textures.StarlingTextureAtlas;
import dragonBones.events.FrameEvent;
import dragonBones.events.AnimationEvent;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Warrior_output/skeleton.xml", mimeType = "application/octet-stream")]
	public static const WarriorSkeletonXMLData:Class;
	
	[Embed(source = "../assets/Warrior_output/texture.xml", mimeType = "application/octet-stream")]
	public static const WarriorTextureXMLData:Class;
	
	[Embed(source = "../assets/Warrior_output/texture.png")]
	public static const WarriorTextureData:Class;

	private var factory:StarlingFactory;
	
	private var armature1:Armature;
	private var armature2:Armature;
	private var textField:TextField;
	
	public function StarlingGame() {
		factory = new StarlingFactory();
		
		//skeletonData
		var skeletonData:SkeletonData = XMLDataParser.parseSkeletonData(XML(new WarriorSkeletonXMLData()));
		factory.addSkeletonData(skeletonData, "warriorData");
		
		var textureAtlas:StarlingTextureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new WarriorTextureData().bitmapData), 
			XML(new WarriorTextureXMLData())
		);
		factory.addTextureAtlas(textureAtlas, "warriorData");
		
		armature1 = factory.buildArmature("warrior");
		armature2 = factory.buildArmature("warrior");
		
		armature1.animation.gotoAndPlay("ready");
		armature2.animation.gotoAndPlay("ready");
		
		armature1.addEventListener(AnimationEvent.LOOP_COMPLETE, animationEventHandler);
		armature1.addEventListener(FrameEvent.MOVEMENT_FRAME_EVENT, frameEventHandler);
		armature2.addEventListener(AnimationEvent.LOOP_COMPLETE, animationEventHandler);
		armature2.addEventListener(FrameEvent.MOVEMENT_FRAME_EVENT, frameEventHandler);
		
		var _display:Sprite;
		_display = armature1.display as Sprite;
		_display.scaleX = -1;
		_display.x = 200;
		_display.y = 350;
		addChild(_display);
		
		_display = armature2.display as Sprite;
		_display.x = 600;
		_display.y = 350;
		addChild(_display);
		
		WorldClock.clock.add(armature1);
		WorldClock.clock.add(armature2);
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
		/*
		textField = new TextField(700, 30, "Two arriors attack each other. Watch the sword's display Z-Order.", "Verdana", 16, 0, true);
		textField.x = 75;
		textField.y = 5;
		addChild(textField);*/
		
		this.alpha = 0.999999;
	}

	private function animationEventHandler(e:AnimationEvent):void 
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
	private function frameEventHandler(e:FrameEvent):void 
	{
		if(e.frameLabel == "hitTarget")
		{
			var target:Armature = e.armature == armature1?armature2:armature1;
			target.animation.gotoAndPlay("hit");
		}
	}

	private function onEnterFrameHandler(_e:EnterFrameEvent):void {

		WorldClock.clock.advanceTime(-1);
	}
}