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
	public class Example_DisplayListAndStarling extends flash.display.Sprite {
		[Embed(source = "../assets/Knight_output.png", mimeType = "application/octet-stream")]
		private static const KnightData:Class;
		
		[Embed(source = "../assets/Cyborg_output.swf", mimeType = "application/octet-stream")]
		private static const CyborgData:Class;
		
		public static var skeletonDatas:Object = {};
		public static var textureDatas:Object = {};
		
		public static function buildArmature(_factory:BaseFactory, _armatureName:String):Armature {
			for each(var _skeletonData:SkeletonData in skeletonDatas) {
				if (_skeletonData.getArmatureData(_armatureName)) {
					_factory.skeletonData = _skeletonData;
					_factory.textureData = textureDatas[_skeletonData.name];
					return _factory.buildArmature(_armatureName);
				}
			}
			return null;
		}
		
		private var factory:BaseFactory = new BaseFactory();
		
		public function Example_DisplayListAndStarling() {
			//
			var _knightData:SkeletonAndTextureRawData = uncompressionData(new KnightData());
			var _cyborgData:SkeletonAndTextureRawData = uncompressionData(new CyborgData());
			
			//
			var _skeletonData:SkeletonData;
			
			_skeletonData = new SkeletonData(_knightData.skeletonXML);
			skeletonDatas[_skeletonData.name] = _skeletonData;
			
			_skeletonData = new SkeletonData(_cyborgData.skeletonXML);
			skeletonDatas[_skeletonData.name] = _skeletonData;
			
			//
			new TextureData(_knightData.textureAtlasXML, _knightData.textureBytes, textureHandler);
			new TextureData(_cyborgData.textureAtlasXML, _cyborgData.textureBytes, textureHandler);
			
			
			//
			_knightData.dispose();
			_cyborgData.dispose();
		}
		
		private function textureHandler(_textureData:TextureData):void {
			textureDatas[_textureData.name] = _textureData;
			//
			for each(var _skeletonData:SkeletonData in skeletonDatas) {
				if (!textureDatas[_skeletonData.name]) {
					return;
				}
			}
			baseInit();
			starlingInit();
		}
		
		private var knight:Armature;
		private var cyborg:Armature;
		private function baseInit():void {
			knight = buildArmature(factory, "knight");
			knight.display.x = 250;
			knight.display.y = 200;
			knight.animation.gotoAndPlay("run");
			addChild(knight.display as Sprite);
		
			cyborg = buildArmature(factory, "cyborg");
			cyborg.display.x = 550;
			cyborg.display.y = 200;
			cyborg.animation.gotoAndPlay("run");
			addChild(cyborg.display as Sprite);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		
		private function onEnterFrameHandler(_e:Event):void {
			knight.update();
			cyborg.update();
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
	factory.autoDisposeBitmapData = false;
	
	private var knight:Armature;
	private var cyborg:Armature;
	public function StarlingGame() {
		knight = Example_DisplayListAndStarling.buildArmature(factory, "knight");
		knight.display.x = 250;
		knight.display.y = 400;
		knight.animation.gotoAndPlay("run");
		addChild(knight.display as Sprite);
	
		cyborg = Example_DisplayListAndStarling.buildArmature(factory, "cyborg");
		cyborg.display.x = 550;
		cyborg.display.y = 400;
		cyborg.animation.gotoAndPlay("run");
		addChild(cyborg.display as Sprite);
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		knight.update();
		cyborg.update();
	}
}
