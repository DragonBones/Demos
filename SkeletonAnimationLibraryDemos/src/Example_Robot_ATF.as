package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import starling.core.Starling;
	/**
	 * flash player 11.4 and air 3.4
	 */
	
    [SWF(width="800", height="600", frameRate="30", backgroundColor="#999999")]
	public class Example_Robot_ATF extends flash.display.Sprite {
		
		public function Example_Robot_ATF() {
			starlingInit();
			stage.addEventListener(MouseEvent.CLICK, mouseHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseHandler);
		}
		
		private function mouseHandler(e:MouseEvent):void 
		{
			switch(e.type) {
				case MouseEvent.CLICK:
					StarlingGame.instance.changeMovement();
					break;
				case MouseEvent.MOUSE_WHEEL:
					StarlingGame.instance.changeAnimationScale(e.delta > 0?1: -1);
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

import starling.display.Sprite;
import starling.events.EnterFrameEvent;

import dragonBones.Armature;
import dragonBones.objects.SkeletonData;
import dragonBones.objects.TextureData;
import dragonBones.factorys.StarlingFactory;

import dragonBones.events.Event;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/robot/texture.atf", mimeType = "application/octet-stream")]
	private static const ATFData:Class;
	
	[Embed(source = "../assets/robot/texture.xml", mimeType = "application/octet-stream")]
	private static const TextureXMLData:Class;
	
	[Embed(source = "../assets/robot/skeleton.xml", mimeType = "application/octet-stream")]
	private static const SkeletonXMLData:Class;
		
	public static var instance:StarlingGame;
	
	private var factory:StarlingFactory;
	private var armature:Armature;
	
	public function StarlingGame() {
		instance = this;
		init();
	}
	
	public function changeMovement():void 
	{
		do{
			var _movement:String = armature.animation.movementList[int(Math.random() * armature.animation.movementList.length)];
		}while (_movement == armature.animation.movementID);
		armature.animation.gotoAndPlay(_movement);
	}
	
	public function changeAnimationScale(_dir:int):void 
	{
		if (_dir > 0) {
			if (armature.animation.scale < 10) {
				armature.animation.scale += 0.1;
			}
		}else {
			if (armature.animation.scale > 0.2) {
				armature.animation.scale -= 0.1;
			}
		}
	}
	
	private function init():void {
		var _skeletonData:SkeletonData = new SkeletonData(XML(new SkeletonXMLData()));
		var _textureData:TextureData = new TextureData(XML(new TextureXMLData()), new ATFData());
		factory = new StarlingFactory(_skeletonData, _textureData);
		
		armature = factory.buildArmature("robot");
		var _display:Sprite = armature.display as Sprite;
		_display.x = 400;
		_display.y = 300;
		addChild(_display);
		armature.animation.gotoAndPlay("stop");
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		armature.update();
	}
}