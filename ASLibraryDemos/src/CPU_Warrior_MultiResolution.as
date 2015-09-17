package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	import dragonBones.factories.NativeFactory;
	import dragonBones.objects.DragonBonesData;
	import dragonBones.objects.XMLDataParser;
	import dragonBones.textures.NativeTextureAtlas;

	/**
	 * 模块功能：
	 * 修改时间：2014-2-24 下午5:13:28
	 * 程序编制：Rich.Lee
	 *
	 */
	public class CPU_Warrior_MultiResolution extends Sprite
	{

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

		public static var instance:CPU_Warrior_MultiResolution;

		private var factory:NativeFactory;
		private var armatures:Vector.<Armature>;
		private var currentAnimationIndex:int = 0;
		private var textField:TextField;

		public function CPU_Warrior_MultiResolution()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
			//stage.addChild(new FPS());
			
			stage.addEventListener(MouseEvent.CLICK, onStageClick);

			instance = this;

			armatures = new Vector.<Armature>;

			factory = new NativeFactory();
			factory.fillBitmapSmooth = true;

			//skeletonData
			var skeletonData:DragonBonesData = XMLDataParser.parseDragonBonesData(XML(new WarriorSkeletonXMLData()));
			factory.addSkeletonData(skeletonData, "warrior");

//			var textureAtlas:TextureAtlas;
//
//			//contentScaleFactor == 2
//			//HD 2x(use different textureXML 2x)
//			//高清贴图，由面板导出时设置scale为2输出，textureXML与texture对应
//			textureAtlas = new StarlingTextureAtlas(Texture.fromBitmapData(new WarriorTextureHDData().bitmapData, false, false, 2), XML(new WarriorTextureHDXMLData()), true);
//			/*
//			textureAtlas = new TextureAtlas(
//			Texture.fromBitmapData(new WarriorTextureHDData().bitmapData, false, false, 2),
//			XML(new WarriorTextureHDXMLData())
//			);
//			*/
//			factory.addTextureAtlas(textureAtlas, "warriorHD");
//
//			//contentScaleFactor == 1
//			//SD 1x
//			//标准贴图，由面板导出时设置scale为1输出，textureXML与texture对应
//			textureAtlas = new StarlingTextureAtlas(Texture.fromBitmapData(new WarriorTextureSDData().bitmapData, false, false, 1), XML(new WarriorTextureSDXMLData()), false);
//			factory.addTextureAtlas(textureAtlas, "warriorSD");
//
//			//contentScaleFactor == 0.5
//			//SD1 0.5x(use same textureXML 1x)
//			//缩放为0.5的贴图，由1x的texture缩放直接缩放得到，使用1x的textureXML
//			textureAtlas = new StarlingTextureAtlas(Texture.fromBitmapData(new WarriorTextureSD1Data().bitmapData, false, false, 0.5), XML(new WarriorTextureSDXMLData()), false);
//			factory.addTextureAtlas(textureAtlas, "warriorSD1");
//
//			//contentScaleFactor == 0.3
//			//SD2 0.3x(use different textureXML 0.3x)
//			//缩放为0.3的贴图，由面板导出时设置scale为0.3输出，textureXML与texture对应
//
//			/*textureAtlas = new StarlingTextureAtlas(
//			Texture.fromBitmapData(new WarriorTextureSD2Data().bitmapData, false, false, 0.3),
//			XML(new WarriorTextureSD2XMLData()),
//			true
//			);*/
//			textureAtlas = new TextureAtlas(Texture.fromBitmapData(new WarriorTextureSD2Data().bitmapData, false, false, 0.3), XML(new WarriorTextureSD2XMLData()));
//
//			factory.addTextureAtlas(textureAtlas, "warriorSD2");
			
			factory.addTextureAtlas(new NativeTextureAtlas(new WarriorTextureHDData().bitmapData, XML(new WarriorTextureHDXMLData()), 2, true), "warriorHD");
			factory.addTextureAtlas(new NativeTextureAtlas(new WarriorTextureSDData().bitmapData, XML(new WarriorTextureSDXMLData()), 1, false), "warriorSD");
			factory.addTextureAtlas(new NativeTextureAtlas(new WarriorTextureSD1Data().bitmapData, XML(new WarriorTextureSDXMLData()), 0.5, false), "warriorSD1");
			factory.addTextureAtlas(new NativeTextureAtlas(new WarriorTextureSD2Data().bitmapData, XML(new WarriorTextureSD2XMLData()), 0.3, true), "warriorSD2");
			
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

			changeAnimation();

			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);

			textField = new TextField();
			textField.width = 700;
			textField.height = 50;
			textField.text = "Multi-Resolution support. Click mouse to switch animation\nHD  SD  SD1  SD2", "Verdana";
			textField.x = 75;
			textField.y = 5;
			addChild(textField);
		}

		public function changeAnimation():void
		{
			var armature:Armature = armatures[0];
			var _animationName:String = armature.animation.animationList[currentAnimationIndex % armature.animation.animationList.length];
			for each (armature in armatures)
			{
				armature.animation.gotoAndPlay(_animationName);
			}
			currentAnimationIndex++;
		}

		private function onEnterFrameHandler(_e:Event):void
		{

			WorldClock.clock.advanceTime(-1);
		}
		
		private function onStageClick(event:MouseEvent):void
		{
			changeAnimation();
		}
	}
}
