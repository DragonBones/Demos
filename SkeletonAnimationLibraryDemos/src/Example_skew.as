package  {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import dragonBones.utils.uncompressionData;
	import dragonBones.objects.SkeletonAndTextureRawData;
	import dragonBones.objects.SkeletonData;
	import dragonBones.objects.TextureData;
	
	import dragonBones.factorys.BaseFactory;
	
	import dragonBones.Armature;
	
	import starling.core.Starling;
	
    [SWF(width="800", height="600", frameRate="30", backgroundColor="#999999")]
	public class Example_skew extends flash.display.Sprite {
		[Embed(source = "../assets/Zombie_yeti.swf", mimeType = "application/octet-stream")]
		private static const ResourcesData:Class;
		
		private var factory:BaseFactory;
		
		public function Example_skew() {
			var _sat:SkeletonAndTextureRawData = uncompressionData(new ResourcesData());
			
			factory = new BaseFactory();
			
			StarlingGame.factory.skeletonData =
			factory .skeletonData =
				new SkeletonData(_sat.skeletonXML);
				
			StarlingGame.factory.textureData =
			factory .textureData =
				new TextureData(_sat.textureAtlasXML, _sat.textureBytes, init);
				
			_sat.dispose();
		}
		
		private function init():void {
			baseInit();
			starlingInit();
		}
		
		private var armature:Armature;
		private function baseInit():void {
			armature = factory.buildArmature("Zombie_yeti");
		
			armature.display.x = 200;
			armature.display.y = 300;
			armature.animation.gotoAndPlay("anim_death");
			//armature.animation.gotoAndPlay("anim_eat");
			//armature.animation.gotoAndPlay("anim_walk");
			//armature.animation.gotoAndPlay("anim_idle");
			addChild(armature.display as Sprite);
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		
		private function onEnterFrameHandler(_e:Event):void {
			armature.update();
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
import dragonBones.factorys.StarlingFactory;

class StarlingGame extends Sprite {
	public static var factory:StarlingFactory = new StarlingFactory();
	private var armature:Armature;
	public function StarlingGame() {
		armature = factory.buildArmature("Zombie_yeti");
		
		armature.display.x = 600;
		armature.display.y = 300;
		armature.animation.gotoAndPlay("anim_death");
		//armature.animation.gotoAndPlay("anim_eat");
		//armature.animation.gotoAndPlay("anim_walk");
		//armature.animation.gotoAndPlay("anim_idle");
		addChild(armature.display as Sprite);
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		armature.update();
	}
}
